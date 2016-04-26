
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, BYQ_CameraOutputType) {
    BYQ_CameraOutputType_StillImage,
    BYQ_CameraOutputType_VideoData
};

@protocol BYQ_CameraOutputProtocol <NSObject>

@required
- (BYQ_CameraOutputType)outPutType;

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;

@end

