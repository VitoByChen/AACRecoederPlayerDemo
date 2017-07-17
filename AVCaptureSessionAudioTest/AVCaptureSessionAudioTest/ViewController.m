//
//  ViewController.m
//  AVCaptureSessionAudioTest
//
//  Created by KC on 2017/7/14.
//  Copyright © 2017年 KC. All rights reserved.
//

#import "ViewController.h"
#import "AACEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import "AACPlayer.h"
@interface ViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate>
/***<#name#>**/
@property(nonatomic, strong)   AVCaptureSession *captureSession;
/***<#name#>**/
@property(nonatomic, strong) AVCaptureAudioDataOutput *captureAudioOutput;
/***<#name#>**/
@property(nonatomic, strong)  NSFileHandle *audioFileHandle;
/***<#name#>**/
@property(nonatomic, strong)   AACEncoder *aacEncoder;
/***<#name#>**/
@property(nonatomic, strong)  AACPlayer *player;

/***<#name#>**/
@property(nonatomic, strong)   NSString *audioFilePath;
/***<#name#>**/
@property(nonatomic, assign)  NSUInteger lenght;
/***<#name#>**/
@property(nonatomic, assign)  NSUInteger index;
/***<#name#>**/
@property(nonatomic, assign)  NSUInteger currentLenght;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AACEncoder *aacEncoder = [[AACEncoder alloc] init];
    
    self.aacEncoder = aacEncoder;
    
}

- (IBAction)recoder:(UIButton *)recordBtn {
    recordBtn.selected = !recordBtn.selected;
    if (recordBtn.selected) {
        [recordBtn setTitle:@"stop" forState:UIControlStateSelected];
        [self startRecord];
    }else {
       [recordBtn setTitle:@"recoding" forState:UIControlStateNormal];
        [self.captureSession stopRunning];
    }
    
}

-(void)startRecord {
    self.index = 0;
    //建立会话者
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    self.captureSession = captureSession;
    //连接输入设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].lastObject;
    AVCaptureDeviceInput *captureAudioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if ([captureSession canAddInput:captureAudioInput]) {
        [captureSession addInput:captureAudioInput];
    }
    //连接输出设备
    AVCaptureAudioDataOutput *captureAudioOutput = [[AVCaptureAudioDataOutput alloc] init];
    self.captureAudioOutput = captureAudioOutput;
    if ([captureSession canAddOutput:captureAudioOutput]) {
        [captureSession addOutput:captureAudioOutput];
    }
    dispatch_queue_t captureAudioOutputQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [captureAudioOutput setSampleBufferDelegate:self queue:captureAudioOutputQueue];
    //文件存储位置
    NSString *audioFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"abc.aac"];
    self.audioFilePath = audioFilePath;
    [[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:audioFilePath contents:nil attributes:nil];
    NSFileHandle *audioFileHandle = [NSFileHandle fileHandleForWritingAtPath:audioFilePath];
    self.audioFileHandle = audioFileHandle;
    [captureSession startRunning];
}
- (IBAction)play:(UIButton *)playBtn {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"session --%@", error);
    }
    NSURL *audioURL=[[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"aac"];
    AVPlayer *player = [AVPlayer playerWithURL:audioURL];
//    NSData *data = [NSData dataWithContentsOfFile:self.audioFilePath];
//    NSLog(@"data --%@--%zd", data, data.length);
//    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
//    if (error) {
//        NSLog(@"AVAudioPlayer --%@", error);
//    }
//    if ([player prepareToPlay]) {
//         NSLog(@"prepareToPlay --");
//    }
//    if ([player play]) {
//        NSLog(@"play --");
//    }
//    NSLog(@"error%@", player.error);
//    [player play];
    
//    [self systemPlay];
    [self playerToPlay];
}

-(void)playerToPlay {
    //[self.audioFileHandle readDataOfLength:10000];
//    NSData *data = [NSData dataWithContentsOfFile:self.audioFilePath];
//    NSData *subData = [data subdataWithRange:NSMakeRange(self.currentLenght, data.length - self.currentLenght)];
//    [[NSFileManager defaultManager] removeItemAtPath:self.audioFilePath error:nil];
//    [subData writeToFile:self.audioFilePath atomically:YES];
//    NSLog(@"data1---%@--%zd", data,data.length);
//    data = [NSData dataWithContentsOfFile:self.audioFilePath];
//    NSLog(@"data2---%@--%zd", data,data.length);
//    NSLog(@"subData ---%@--%zd", subData,subData.length);
    AACPlayer *player = [[AACPlayer alloc] initWithFilePath:self.audioFilePath];
    self.player = player;
    [player play];
}

-(void)systemPlay {
    NSURL *audioURL=[[NSBundle mainBundle] URLForResource:@"abc" withExtension:@"aac"];
    NSURL *filePath = [NSURL URLWithString:self.audioFilePath];
    SystemSoundID soundID;
    //Creates a system sound object.
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioURL), &soundID);
    //Registers a callback function that is invoked when a specified system sound finishes playing.
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, &playCallback, (__bridge void * _Nullable)(self));
    //    AudioServicesPlayAlertSound(soundID);
    AudioServicesPlaySystemSound(soundID);
}

void playCallback(SystemSoundID ID, void  * clientData){
    ViewController* controller = (__bridge ViewController *)clientData;
//    [controller onPlayCallback];
}
#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (captureOutput == self.captureAudioOutput) {
        NSLog(@"%@--%@", sampleBuffer, [NSDate date]);
       //__block NSUInteger  leng = 0;
        [self.aacEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
//            self.index++;
//            self.lenght = self.lenght + encodedData.length;
//            if (self.index == 30) {
//                self.currentLenght = self.lenght;
//            }
            NSLog(@"jp---%@--%zd--%zd", encodedData, encodedData.length, self.lenght);
            [self.audioFileHandle writeData:encodedData];
        }];
    }

}

@end
