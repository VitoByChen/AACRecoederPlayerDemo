//
//  AACPlayer.h
//  AVCaptureSessionAudioTest
//
//  Created by KC on 2017/7/14.
//  Copyright © 2017年 KC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AACPlayer : NSObject
- (instancetype)initWithFilePath:(NSString *)filePath;
- (void)play;

- (double)getCurrentTime;


@end
