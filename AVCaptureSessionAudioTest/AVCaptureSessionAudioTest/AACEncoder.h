//
//
//  
//  AVCaptureSessionAudioTest
//
//  Created by KC on 2017/7/14.
//  Copyright © 2017年 KC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AACEncoder : NSObject

@property (nonatomic) dispatch_queue_t encoderQueue;//转码队列
@property (nonatomic) dispatch_queue_t callbackQueue;//转码回调队列

//把PCM数据传过来， 编码完成后回调出去
- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer completionBlock:(void (^)(NSData *encodedData, NSError* error))completionBlock;


@end
