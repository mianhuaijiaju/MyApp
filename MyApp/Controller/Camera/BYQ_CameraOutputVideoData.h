 
#import <Foundation/Foundation.h>
#import "BYQ_CameraOutputProtocol.h"

@interface BYQ_CameraOutputVideoData : NSObject <BYQ_CameraOutputProtocol>

@property (nonatomic, assign) BOOL canContinueHandleVideoData;
@property (nonatomic, copy) void(^didCaptureImage)(UIImage *img);

@end
