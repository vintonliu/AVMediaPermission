//
//  ViewController.m
//  AVMedia
//
//  Created by liuwenchang on 2019/5/20.
//  Copyright © 2019 veryrtc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *_btnAudio;
@property (weak, nonatomic) IBOutlet UIButton *_btnVideo;
@property (weak, nonatomic) IBOutlet UILabel *_lblTips;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self._btnAudio.layer.cornerRadius = 8;
    self._btnVideo.layer.cornerRadius = 8;
}

- (IBAction)onBtnAudioClicked:(id)sender {
    NSString *version = [UIDevice currentDevice].systemVersion;
    BOOL IOS8_OR_HIGHER = version.doubleValue >= 8.0;
    
    if (!IOS8_OR_HIGHER) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        switch (authStatus) {
            case AVAuthorizationStatusDenied: // 用户已拒绝授权
            case AVAuthorizationStatusRestricted: {// 设备使用受限
                NSLog(@"Denied || Restricted");
                self._lblTips.text = @"拒绝授权";
                [self showAlertView:1];
            }
                break;
            
            case AVAuthorizationStatusNotDetermined: { // 尚未询问用户是否授权
                NSLog(@"NotDetermined");
                self._lblTips.text = @"待授权";
                
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    NSLog(@"audio %@ -- %@", @(granted), @([NSThread isMainThread]));
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (granted) {
                            self._lblTips.text = @"授权成功";
                        } else {
                            self._lblTips.text = @"授权失败";
                        }
                    });
                }];
            }
                break;
                
            case AVAuthorizationStatusAuthorized: // 用户已授权
                NSLog(@"Authorized");
                self._lblTips.text = @"已授权";
                break;
                
            default:
                break;
        }
    } else {
        AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
        switch (permission) {
            case AVAudioSessionRecordPermissionDenied: {
                NSLog(@"Denied");
                self._lblTips.text = @"拒绝授权";
                [self showAlertView:1];
            }
                break;
                
            case AVAudioSessionRecordPermissionGranted:
                NSLog(@"Granted");
                self._lblTips.text = @"已授权";
                break;
                
            case AVAudioSessionRecordPermissionUndetermined: {
                NSLog(@"Undetermined");
                self._lblTips.text = @"待授权";
                
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    NSLog(@"audio %@ -- %@", @(granted), @([NSThread isMainThread]));
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (granted) {
                            self._lblTips.text = @"授权成功";
                        } else {
                            self._lblTips.text = @"授权失败";
                        }
                    });
                }];
            }
                break;
                
            default:
                break;
        }
    }
}

- (IBAction)onBtnVideoClicked:(id)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            NSLog(@"Denied");
            self._lblTips.text = @"拒绝授权";
            [self showAlertView:2];
        }
            break;
            
        case AVAuthorizationStatusNotDetermined: {
            NSLog(@"NotDetermined");
            self._lblTips.text = @"待授权";
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                NSLog(@"video %@ -- %@", @(granted), @([NSThread isMainThread]));
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (granted) {
                        self._lblTips.text = @"授权成功";
                    } else {
                        self._lblTips.text = @"授权失败";
                    }
                });
            }];
        }
            break;
            
        case AVAuthorizationStatusAuthorized:
            NSLog(@"Authorized");
            self._lblTips.text = @"已授权";
            break;
            
        default:
            break;
    }
}

- (void)showAlertView:(int)type {
    
    UIAlertController *alertVC;
    if (type == 1) {
        alertVC = [UIAlertController alertControllerWithTitle:@"麦克风权限未开启"
                                            message:@"麦克风权限未开启，请进入系统【设置】>【隐私】>【麦克风】中打开开关,开启麦克风功能"
                                     preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:@"摄像头权限未开启"
                                            message:@"摄像头权限未开启，请进入系统【设置】>【隐私】>【相机】中打开开关,开启摄像头功能"
                                     preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            // 打开该应用的权限设置界面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    
    [alertVC addAction:cancelAction];
    [alertVC addAction:setAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}
@end
