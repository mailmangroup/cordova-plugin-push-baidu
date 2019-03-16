//
//  BaiduPushPlugin.m
//  HaobanPlugin
//
//  Created by 马杰磊 on 15/6/17.
//  Copyright (c) 2015年 NTTData. All rights reserved.
//

#import "BaiduPushPlugin.h"
#import "BPush.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation BaiduPushPlugin{
    NSNotificationCenter *_observer;
}

@synthesize appkey;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:deviceToken];
//    [BPush registerDeviceToken:deviceToken];
//    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
//        // 绑定返回值
//        if ([self returnBaiduResult:result])
//        {
//#warning TODO result中的user id、channel id可以在这个时候发送给server
//
//            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//        }
//        else{
//            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//        }
////        [[NSNotificationCenter defaultCenter] removeObserver:_obsexrver];
////        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
//        [self.commandDelegate sendPluginResult:self.result callbackId:nil];
//    }];
}

/*!
 @method
 @abstract 绑定
 */
- (void)startWork:(CDVInvokedUrlCommand*)command{
    NSLog(@"绑定");

    self.appkey = [command.arguments objectAtIndex:0];

    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    [BPush registerChannel:nil apiKey:self.appkey pushMode:BPushModeProduction withFirstAction:nil withSecondAction:nil withCategory:nil useBehaviorTextInput:YES isDebug:NO];
    
    // 禁用地理位置推送 需要再绑定接口前调用。
    [BPush disableLbs];

    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:CDVRemoteNotification
                  object:nil
                  queue:[NSOperationQueue mainQueue]
                  usingBlock:^(NSNotification *note) {
                      NSData *deviceToken = [note object];
                      [BPush registerDeviceToken:deviceToken];
                      [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
                          // 绑定返回值
                          if ([self returnBaiduResult:result])
                          {
                              #warning TODO result中的user id、channel id可以在这个时候发送给server
                              
                              self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                          }
                          else{
                              self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:result];
                          }
                          [[NSNotificationCenter defaultCenter] removeObserver:_observer];
                          [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
                      }];
                  }];
    
    // iOS10 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                                  if (granted) {
//                                      [application registerForRemoteNotifications];
                                      dispatch_async(dispatch_get_main_queue(), ^(void) {
                                          [[UIApplication sharedApplication] registerForRemoteNotifications];
                                      });
                                  }
                              }];
#endif
    }
    else
    // iOS8 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    /*
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 绑定返回值
        if ([self returnBaiduResult:result])
        {
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else{
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
    }];
    */
}

/*!
 @method
 @abstract 解除绑定
 */
- (void)stopWork:(CDVInvokedUrlCommand*)command{
    NSLog(@"解除绑定");
    [BPush unbindChannelWithCompleteHandler:^(id result, NSError *error) {
        // 解绑返回值
        if ([self returnBaiduResult:result])
        {
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else{
            self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
    }];
}

/*!
 @method
 @abstract 回复绑定
 */
- (void)resumeWork:(CDVInvokedUrlCommand*)command{
    NSLog(@"回复绑定");
}

/*!
@method
@abstract 设置Tag
*/
- (void)setTags:(CDVInvokedUrlCommand*)command{
    NSLog(@"设置Tag");
    NSString *tagsString = command.arguments[0];
    if (![self checkTagString:tagsString]) {
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        return;
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@","];
    if (tags) {
        [BPush setTags:tags withCompleteHandler:^(id result, NSError *error) {
            // 设置多个标签组的返回值
            if ([self returnBaiduResult:result])
            {
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else{
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        }];
    }
}

/*!
 @method
 @abstract 删除Tag
 */
- (void)delTags:(CDVInvokedUrlCommand*)command{
    NSLog(@"删除Tag");
    NSString *tagsString = command.arguments[0];
    if (![self checkTagString:tagsString]) {
        self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        return;
    }
    
    NSArray *tags = [tagsString componentsSeparatedByString:@","];
    if (tags) {
        [BPush delTags:tags withCompleteHandler:^(id result, NSError *error) {
            // 删除标签的返回值
            if ([self returnBaiduResult:result])
            {
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
            else{
                self.result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:self.result callbackId:command.callbackId];
        }];
    }
}

- (BOOL)checkTagString:(NSString *)tagStr {
    NSString *str = [tagStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    if ([str isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)returnBaiduResult:(id)result{
    NSString *resultStr = result[@"error_code"];
    if (!resultStr || [[resultStr description] isEqualToString:@"0"]){
        return YES;
    }
    return NO;
}

@end
