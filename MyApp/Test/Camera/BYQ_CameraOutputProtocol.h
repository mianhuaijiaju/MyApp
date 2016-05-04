
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, BYQ_CameraOutputType) {
    BYQ_CameraOutputType_StillImage, // 用于拍照
    BYQ_CameraOutputType_VideoData,  // 用于视频流
    BYQ_CameraOutputType_MetaData    // 用于元数据
};

@protocol BYQ_CameraOutputProtocol <NSObject>

@required
- (BYQ_CameraOutputType)outPutType;

/**
 *  用于处理视频输出的回调
 *
 *  @param captureOutput
 *  @param sampleBuffer
 *  @param connection
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;

/**
 *  用于处理元数据输出的回调
 *
 *  @param captureOutput
 *  @param metadataObjects
 *  @param connection      
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection;
@end

