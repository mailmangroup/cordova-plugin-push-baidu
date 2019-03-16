#import "AppDelegate.h"

@interface AppDelegate (notification)
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
@end