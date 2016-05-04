//
//  QRCodeViewController.m
//  MyApp
//
//  Created by wangchong on 16/4/26.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "QRCodeViewController.h"
#import "BYQ_Camera.h"

#pragma mark - QRCode_Camera_OutputHandler
@interface QRCode_Camera_OutputHandler : NSObject <BYQ_CameraOutputProtocol>
@property (nonatomic, copy) void (^handler)(BOOL success, NSString *result);
@end

@implementation QRCode_Camera_OutputHandler

- (BYQ_CameraOutputType)outPutType {
    return BYQ_CameraOutputType_MetaData;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *machineReadableCodeObj = [metadataObjects firstObject];
        NSString *result;
        if ([machineReadableCodeObj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = machineReadableCodeObj.stringValue;
            self.handler(result.length, result);
            return;
        }
    }
    self.handler(NO, nil);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    return;
}

@end

#pragma mark - QRCodeViewController

@interface QRCodeViewController ()
@property (nonatomic, strong) BYQ_Camera *camera;
@end

@implementation QRCodeViewController

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:[self private_initCancelButton]];
    self.navigationItem.leftBarButtonItem = item;
    [self.view addSubview:self.camera.cameraView];
    [self.camera startSession];
}

#pragma mark - private
- (UIButton *)private_initCancelButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"byq_close"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"byq_close"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(private_cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)private_cancelAction:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
    [self.camera stopSession];
}

#pragma mark - accessors

- (BYQ_Camera *)camera {
    if (!_camera) {
        _camera = [[BYQ_Camera alloc] initWithCameraFrame:self.view.bounds];
        _camera.sessionPreset = AVCaptureSessionPresetHigh;
        QRCode_Camera_OutputHandler *qr = [[QRCode_Camera_OutputHandler alloc] init];
        __weak QRCodeViewController *weakSelf = self;
        _camera.outputHandler = qr;
        qr.handler = ^(BOOL success, NSString *result) {
            if (success) {
                NSLog(@"result:%@",result);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    [weakSelf.camera stopSession];
                });
            } else {
                NSLog(@"失败");
            }
        };
    }
    return _camera;
}

@end
