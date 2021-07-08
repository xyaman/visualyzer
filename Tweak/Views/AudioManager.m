#import "AudioManager.h"

@interface AudioManager ()
@end

@implementation AudioManager

- (instancetype) init {
	self = [super init];

	// Socket initialization related
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

- (void) startConnection {
	if(_isConnected) return;
	_isConnected = YES;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{	
	
	int sockfd = -1;

	while(_isConnected) {

		// Create socket
		sockfd = socket(AF_INET, SOCK_STREAM, 0);
		if (sockfd == -1) {
			NSLog(@"[Visualyzer] Can't create socket");
			usleep(500000); // Half second
			continue;
		}

		// Connect client to host
		int ok = connect(sockfd, (SA*)&_addr, sizeof(_addr));
		if(ok < 0) {
			NSLog(@"[Visualyzer] Socket can't connect to host");
			usleep(500000); // Half second
			continue;
		}

		// Now we are connected
		NSLog(@"[Visualyzer] Socket is not connected");


    	// Buffer related
		int hello = 1;
    	float dummyData[4]; // Sometimes socket receives a float
    	UInt32 bufferSize = 0;
    	int bufferLength = 0; // bufferSize / sizeof(float)
    	float buffer[MAX_BUFFER_SIZE];


    	while(_isConnected) {
    		// Send initial message.
			int wlen = write(sockfd, &hello, sizeof(hello));
			if(wlen < 0) { // We've lost the connection
				close(sockfd);
				break; 
			}

			// Response -> data bufferSize with size of UInt32.
			int rlen = read(sockfd, &bufferSize, sizeof(bufferSize));
			if(rlen < 0) { // We've lost the connection
				close(sockfd);
				break; 
			}


			// When no data is available, the host sends ONE float.
			if(bufferSize == sizeof(float)) {
				rlen = read(sockfd, dummyData, bufferSize);
				if (rlen < 0) {
					close(sockfd);
					break;
				}
				continue;
			}

			// This shouldn't happens but sometimes happens
			if(bufferSize > MAX_BUFFER_SIZE) {
				close(sockfd);
				break;
			}

			// If we are still here, it means now we have REAL data audio :)
			rlen = read(sockfd, buffer, bufferSize);

			if(rlen < 0) {
				close(sockfd);
				break;
			}

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
			usleep(self.refreshRateInSeconds * 1000000);

	    	}
		}


		// Close the socket
		close(sockfd);
	});

}

-(void) stopConnection {
	_isConnected = NO;
}

@end