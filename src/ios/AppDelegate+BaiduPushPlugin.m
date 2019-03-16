#import "AppDelegate+BaiduPushPlugin.h"
#import <objc/runtime.h>
#import "BPush.h"
#import "BaiduPushPlugin.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@implementation AppDelegate (BaiduPushPlugin)

static IMP didRegisterOriginalMethod = NULL;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(pushPluginSwizzledInit);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
        
        // didRegisterForRemoteNotificationsWithDeviceToken swizzle
        Method didRegisterMethod = class_getInstanceMethod(class, @selector(my_application:didRegisterForRemoteNotificationsWithDeviceToken:));
        IMP didRegisterMethodImp = method_getImplementation(didRegisterMethod);
        const char* didRegisterTypes = method_getTypeEncoding(didRegisterMethod);
        
        Method didRegisterOriginal = class_getInstanceMethod(class, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
        if (didRegisterOriginal) {
            didRegisterOriginalMethod = method_getImplementation(didRegisterOriginal);
            method_exchangeImplementations(didRegisterOriginal, didRegisterMethod);
        } else {
            class_addMethod(class, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), didRegisterMethodImp, didRegisterTypes);
        }
    });
}

- (AppDelegate *)pushPluginSwizzledInit
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidBecomeActive:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil]; //监听是否重新进入程序程序.
    
    return [self pushPluginSwizzledInit];
}

//应用重新启动后执行
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"test:%@",deviceToken);
    BaiduPushPlugin *pushHandler = [self.viewController getCommandInstance:@"baidupush"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

@end
