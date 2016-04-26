 
#import <Foundation/Foundation.h>
#import "BYQ_CameraOutputProtocol.h"

@interface BYQ_CameraOutputStillImage : NSObject <BYQ_CameraOutputProtocol>

@property (nonatomic, copy) void(^didCaptureImage)(UIImage *img);

@end
