 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BYQ_CameraOutputProtocol.h"

typedef NS_ENUM(NSUInteger, BYQ_CameraPosition) {
    BYQ_CameraPosition_Front,
    BYQ_CameraPosition_Back
};

@interface BYQ_Camera : NSObject

@property (nonatomic, strong, readonly) UIView *cameraView;

/**
 *  摄像头位置 （默认后置）
 */
@property (nonatomic, assign) BYQ_CameraPosition cameraPosition;

/**
 *  相机输出处理者 （默认：TTAVCameraOutputVideoData对象）
 */
@property (nonatomic, strong) id<BYQ_CameraOutputProtocol> outputHandler;

/**
 *  相机预设质量 （默认：AVCaptureSessionPresetHigh）
 */
@property (nonatomic, copy) NSString *sessionPreset;

/**
 *  录制的方向 (默认为AVCaptureVideoOrientationPortrait)
 */
@property (nonatomic, assign) AVCaptureVideoOrientation cameraOrientation;

- (instancetype)initWithCameraFrame:(CGRect)frame;

/**
 *  @return 返回TRUE意味授权成功，反之，失败
 */
+ (BOOL)checkDeviceAuthorizationStatus;

- (void)startSession;
- (void)stopSession;

- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExpose;

/**
 *  拍照 
 * @note 只对outputHandler的outPutType为TTAVCameraOutputType_StillImage时，才生效
 */
- (void)capturePhoto;

@end

