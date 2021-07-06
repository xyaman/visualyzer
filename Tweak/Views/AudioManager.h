#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <arpa/inet.h>

#import "AudioManagerDelegate.h"

@interface AudioManager : NSObject {
	// Socket related
	int _sockfd;
	struct sockaddr_in _addr;
	BOOL _isConnected;

	// Audio related
	struct vDSP_DFT_SetupStruct *_fftSetup;
	struct DSPSplitComplex _complex;
	float *_realIn;
	float *_imagIn;
	float *_realOut;
	float *_imagOut;
	float *_magnitudes;
	float _scalingFactor;

}

@property (nonatomic, weak) id <AudioManagerDelegate> delegate;
@property (nonatomic) float refreshRateInSeconds;

-(void) startConnection;
-(void) stopConnection;
@end