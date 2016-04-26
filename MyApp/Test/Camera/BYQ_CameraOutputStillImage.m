
#import "BYQ_CameraOutputStillImage.h"
#import <UIKit/UIKit.h>

@implementation BYQ_CameraOutputStillImage

- (BYQ_CameraOutputType)outPutType {
    return BYQ_CameraOutputType_StillImage;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    dispatch_async(dispatch_get_main_queue(), ^{
        !self.didCaptureImage ?: self.didCaptureImage(image);
    });
}

@end
