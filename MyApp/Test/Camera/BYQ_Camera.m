
#import "BYQ_Camera.h"
#import <AVFoundation/AVFoundation.h>
#import "BYQ_CameraOutputVideoData.h"

#pragma mark - TTAVCameraView
@interface BYQ_CameraView : UIView
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation BYQ_CameraView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

@end
 
#pragma mark - BYQ_Camera
@interface BYQ_Camera () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) BYQ_CameraView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

@property (nonatomic, weak) AVCaptureDeviceInput *currentCameraInput;
@property (nonatomic, weak) AVCaptureOutput *currentCameraOutput;

@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@end

@implementation BYQ_Camera

- (void)dealloc {
    
    NSLog(@"%s",__FUNCTION__);
    
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    return [self initWithCameraFrame:[UIApplication sharedApplication].keyWindow.bounds];
}

#pragma mark - Public
- (instancetype)initWithCameraFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _cameraPreviewView = [[BYQ_CameraView alloc] initWithFrame:frame];
        
        _cameraPosition = BYQ_CameraPosition_Back;
        _cameraOrientation = AVCaptureVideoOrientationPortrait;
        
        _outputHandler = [[BYQ_CameraOutputVideoData alloc] init];
        
        self.sessionQueue = dispatch_queue_create("com.ttavcamera.SessionQueue", DISPATCH_QUEUE_SERIAL);
        self.captureQueue = dispatch_queue_create("com.ttavcamera.CaptureQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (BOOL)checkDeviceAuthorizationStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return status == AVAuthorizationStatusAuthorized;
}

- (UIView *)cameraView {
    return self.cameraPreviewView;
}

- (void)startSession {
    
    BOOL deviceHasAuthorized = [self.class checkDeviceAuthorizationStatus];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (!deviceHasAuthorized) {
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    [self tt_setupSession];
                    
                    dispatch_async(self.sessionQueue, ^{
                        if (![self.session isRunning]) {
                            [self.session startRunning];
                        }
                    });
                }
            }];
        }
        return;
    }
    
    [self tt_setupSession];
    dispatch_async(self.sessionQueue, ^{
        if (![self.session isRunning]) {
            [self.session startRunning];
        }
    });
}

- (void)stopSession {
    dispatch_async(self.sessionQueue, ^{
        if ([self.session isRunning]) {
            [self.session stopRunning];
        }
    });
}

- (void)focusAtPoint:(CGPoint)point {
    if (self.currentCameraInput.device.focusPointOfInterestSupported) {
        [self.currentCameraInput.device lockForConfiguration:nil];
        self.currentCameraInput.device.focusPointOfInterest = [self.cameraPreviewView.previewLayer captureDevicePointOfInterestForPoint:point];
        
        if ([self.currentCameraInput.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            self.currentCameraInput.device.focusMode = AVCaptureFocusModeAutoFocus;
        }
        [self.currentCameraInput.device unlockForConfiguration];
    }
}

- (void)exposeAtPoint:(CGPoint)point {
    // TODO
}

- (void)resetFocusAndExpose {
    [self.currentCameraInput.device lockForConfiguration:nil];
    if ([self.currentCameraInput.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        self.currentCameraInput.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    }
    
    if ([self.currentCameraInput.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        self.currentCameraInput.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    }
    [self.currentCameraInput.device unlockForConfiguration];
}

- (void)setCameraPosition:(BYQ_CameraPosition)cameraPosition {
    if (_cameraPosition == cameraPosition) {
        return;
    }
    _cameraPosition = cameraPosition;
    [self tt_configSession];
}

- (void)setSessionPreset:(NSString *)sessionPreset {
    if ([_sessionPreset isEqualToString:sessionPreset]) {
        return;
    }
    _sessionPreset = [sessionPreset copy];
    [self tt_configSession];
}

- (void)setOutputHandler:(id<BYQ_CameraOutputProtocol>)outputHandler {
    _outputHandler = outputHandler;
    [self tt_configSession];
}

- (void)setCameraOrientation:(AVCaptureVideoOrientation)cameraOrientation {
    if (_cameraOrientation == cameraOrientation) {
        return;
    }
    _cameraOrientation = cameraOrientation;
    AVCaptureConnection *connection = [self.currentCameraOutput connectionWithMediaType:AVMediaTypeVideo];
    [self tt_setOrientationForConnection:connection];
}

- (void)capturePhoto {
    if (!_stillImageOutput || [self.outputHandler outPutType] != BYQ_CameraOutputType_StillImage) {
        return;
    }
    
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        return;
    }
    connection.videoOrientation = [self tt_realVideoOrientation];
    
    id handler = ^(CMSampleBufferRef sampleBuffer, NSError *error) {
        [self.outputHandler captureOutput:self.stillImageOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    };
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:handler];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ([self.outputHandler outPutType] != BYQ_CameraOutputType_VideoData) {
        return;
    }
    
    [self.outputHandler captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([self.outputHandler outPutType] != BYQ_CameraOutputType_MetaData) {
        return;
    }
    
    [self.outputHandler captureOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection];
}

#pragma mark - Private

- (void)tt_setupSession {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [self tt_configSession];
        
        self.cameraPreviewView.previewLayer.session = _session;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_handleSessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_handleSessionInterrupte:) name:AVCaptureSessionWasInterruptedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_handleSessionDidEndInterrupte:) name:AVCaptureSessionInterruptionEndedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_handleAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tt_handleAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)tt_handleSessionRuntimeError:(NSNotification *)ntf {
//    NSError *error = ntf.userInfo[AVCaptureSessionErrorKey];
//    NSLog(@"sessionRuntimeError: %@", [error localizedDescription]);
}

- (void)tt_handleSessionInterrupte:(NSNotification *)ntf {
    [self stopSession];
}

- (void)tt_handleSessionDidEndInterrupte:(NSNotification *)ntf {
    [self startSession];
}

- (void)tt_handleAppWillResignActive:(NSNotification *)ntf {
    [self stopSession];
}

- (void)tt_handleAppDidBecomeActive:(NSNotification *)ntf {
    [self startSession];
}

- (void)tt_configSession {
    if (!_session) {
        return;
    }
    
    [self.session beginConfiguration];
    
    // 配置预设质量
    if ([self.session canSetSessionPreset:self.sessionPreset]) {
        self.session.sessionPreset = self.sessionPreset;
    } else {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    // 添加设备输入
    if (self.currentCameraInput) {
        [self.session removeInput:self.currentCameraInput];
    }
    AVCaptureDeviceInput *needAddedInput = (_cameraPosition == BYQ_CameraPosition_Front) ? self.frontCameraInput : self.backCameraInput;
    if ([self.session canAddInput:needAddedInput]) {
        [self.session addInput:needAddedInput];
    }
    self.currentCameraInput = needAddedInput;
    
    // 添加输出
    if (self.currentCameraOutput) {
        [self.session removeOutput:self.currentCameraOutput];
    }
    AVCaptureOutput *output;
    BYQ_CameraOutputType outputType = [self.outputHandler outPutType];
    switch (outputType) {
        case BYQ_CameraOutputType_MetaData:
            output = self.metadataOutput;
            break;
        case BYQ_CameraOutputType_StillImage:
            output = self.stillImageOutput;
            break;
        case BYQ_CameraOutputType_VideoData:
            output = self.videoDataOutput;
            break;
        default:
            break;
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
        
        if (outputType == BYQ_CameraOutputType_MetaData) {
            if ([[_metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
                [_metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            }
        }
        
        AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
        [self tt_setOrientationForConnection:connection];
    }
    self.currentCameraOutput = output;
    
    [self.session commitConfiguration];
}

- (AVCaptureDevice *)tt_cameraWithPosition:(AVCaptureDevicePosition)position {
    __block AVCaptureDevice *camera = nil;
    [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] enumerateObjectsUsingBlock:^(AVCaptureDevice *device, NSUInteger idx, BOOL * _Nonnull stop) {
        if (device.position == position) {
            camera = device;
            *stop = YES;
        }
    }];
    return camera;
}

- (AVCaptureVideoOrientation)tt_realVideoOrientation {
    AVCaptureVideoOrientation realVideoOrientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            realVideoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            realVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            realVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            realVideoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            realVideoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return realVideoOrientation;
}

- (void)tt_setOrientationForConnection:(AVCaptureConnection *)connection {
    if (!connection) {
        return;
    }
    
    if ([connection isVideoOrientationSupported]) {
        [connection setVideoOrientation:self.cameraOrientation];
    }
}

#pragma mark - Getter
- (AVCaptureDeviceInput *)frontCameraInput {
    if (!_frontCameraInput) {
        AVCaptureDevice *camera = [self tt_cameraWithPosition:AVCaptureDevicePositionFront];
        _frontCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:nil];
    }
    return _frontCameraInput;
}

- (AVCaptureDeviceInput *)backCameraInput {
    if (!_backCameraInput) {
        AVCaptureDevice *camera = [self tt_cameraWithPosition:AVCaptureDevicePositionBack];
        _backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:nil];
    }
    return _backCameraInput;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        [_videoDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _videoDataOutput;
}

- (AVCaptureStillImageOutput *)stillImageOutput {
    if (!_stillImageOutput) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        _stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    }
    return _stillImageOutput;
}

- (AVCaptureMetadataOutput *)metadataOutput {
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.captureQueue];
    }
    return _metadataOutput;
}

@end
