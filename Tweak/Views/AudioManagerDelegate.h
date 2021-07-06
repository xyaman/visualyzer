@class AudioManager;

@protocol AudioManagerDelegate
- (void) newAudioDataWasProcessed:(float*)data withLength:(int)length;
@end