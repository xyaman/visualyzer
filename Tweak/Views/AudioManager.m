#import "AudioManager.h"

#define SA struct sockaddr
#define ASSPORT 44333
#define MAX_BUFFER_SIZE 16384
#define FFT_LENGTH 1024

@interface AudioManager ()
@end

@implementation AudioManager

- (instancetype) init {
	self = [super init];

	// Socket initialization related
	// _sockfd = -1;
	_isConnected = NO;	
	
	// Host addr	
	_addr.sin_family = AF_INET;
	_addr.sin_port = htons(ASSPORT);
	_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

	// Audio processing related	
	_fftSetup = vDSP_DFT_zop_CreateSetup(NULL, FFT_LENGTH, vDSP_DFT_FORWARD);
	_realIn = (float *)calloc(FFT_LENGTH, sizeof(float));
	_imagIn = (float *)calloc(FFT_LENGTH, sizeof(float));
	_realOut = (float *)calloc(FFT_LENGTH, sizeof(float));
	_imagOut = (float *)calloc(FFT_LENGTH, sizeof(float));

	_magnitudes = (float *)calloc(FFT_LENGTH/2, sizeof(float));
	_scalingFactor = 5.0f / 1024.0f;

	_complex.realp = _realOut;
	_complex.imagp = _imagOut;

	return self;
}


// In an implementation of dealloc, do not invoke the superclass’s 
// implementation. You should try to avoid managing the lifetime of 
// limited resources such as file descriptors using dealloc.
-(void) dealloc {
	vDSP_DFT_DestroySetup(_fftSetup);
	free(_realIn);
	free(_imagIn);
	free(_realOut);
	free(_imagOut);
	free(_magnitudes);
}

-(void) startConnection {

	if(_isConnected) return;
	_isConnected = YES;
	
	// implement retry	

	// Initialize the client
	_sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (_sockfd == -1) {
		NSLog(@"[Visualyzer] Can't open socket");
		_isConnected = NO;
		return;	
	}

	// Connect client to host
	int ok = connect(_sockfd, (SA*)&_addr, sizeof(_addr));
	if(ok != 0) {
		NSLog(@"[Visualyzer] Socket can't connect to host");
		_isConnected = NO;
		return;
	}

	NSLog(@"[Visualyzer] Socket connected");


	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		int hello = 1;
		float dummyData[4];

		float buffer[MAX_BUFFER_SIZE] __attribute__ ((aligned));
		UInt32 bufferSize = 0;
		int bufferLength = 0; // bufferSize / sizeof(float)

		while(_isConnected) {

			// Send initial message.
			write(_sockfd, &hello, sizeof(hello));

			// Response -> data bufferSize with size of UInt32.
			read(_sockfd, &bufferSize, sizeof(bufferSize));


			// When no data is available, the host sends ONE float.
			if(bufferSize == sizeof(float)) {
				read(_sockfd, dummyData, bufferSize);
				continue;
			}

			// This shouldn't happens but sometimes happens
			if(bufferSize > MAX_BUFFER_SIZE) {
				float *tempBuffer = (float *)malloc(bufferSize);
				read(_sockfd, tempBuffer, bufferSize);
				free(tempBuffer);
				continue;
			}

			// If we are still here, it means now we have REAL data audio :)
			read(_sockfd, buffer, bufferSize);
			bufferLength = bufferSize / sizeof(float);

			// Now we process the audio data

			// First, we compress the audio, only if bigger than our fft length
			// No effect if compression rate is 1
			int compressionRate = bufferLength / FFT_LENGTH;

			// Copy the buffer to our allocated array
			for(int i = 0; i < FFT_LENGTH; i++) {
				_realIn[i] = buffer[i * compressionRate];
			}

			// Execute our Discrete Fourier Transformation to get the audio frequency	
			vDSP_DFT_Execute(_fftSetup, _realIn, _imagIn, _realOut, _imagOut);

			// Calculate the absolute value of the complex number
			// Remember: complex.realp = _realOut, complex.imagp = _imagOut
			// Here we get data / 2;
			vDSP_zvabs(&_complex, 1, _magnitudes, 1, FFT_LENGTH / 2);

			// Now we normalize the magnitudes a little	
			vDSP_vsmul(_magnitudes, 1, &_scalingFactor, _magnitudes, 1, FFT_LENGTH / 2);

			// Now we send to our delegate :D
			[self.delegate newAudioDataWasProcessed:_magnitudes withLength:FFT_LENGTH/2];

			// Zzz
			sleep(self.refreshRateInSeconds);
		}

		// We need to close the connection

		close(_sockfd);
		_sockfd = -1;
		NSLog(@"[Visualyzer] Socket connection ended");
	});
}

-(void) stopConnection {
	_isConnected = NO;
}

@end