//
//  QRCodeViewController.m
//  MyApp
//
//  Created by wangchong on 16/4/26.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()

@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self private_configureSession];
    [self.session startRunning];
}


#pragma mark - private

- (void)private_configureSession {
    
}

@end
