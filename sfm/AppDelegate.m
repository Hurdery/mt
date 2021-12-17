//
//  AppDelegate.m
//  sfm
//
//  Created by LY_MD on 2021/12/15.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CLLocationManager.h>
#import "ViewController.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate,CLLocationManagerDelegate>
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property(nonatomic,strong)CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
    [self setNotificationCenter];
    return YES;
}
- (void)setNotificationCenter{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
                   for (UNNotificationRequest *req in requests){
//                       NSLog(@"存在的ID:%@\n",req.identifier);
//                        [center removePendingNotificationRequestsWithIdentifiers:@[req.identifier]];
                   }
        }];

        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        center.delegate = self;
//        [center removeAllPendingNotificationRequests];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
API_AVAILABLE(ios(10.0)){
    [self receiveNotification];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler
API_AVAILABLE(ios(10.0)){
    [self receiveNotification];
}

- (void)receiveNotification{

//    [[NSNotificationCenter defaultCenter]postNotificationName:@"receiveNotification" object:nil];
}

- (void)startBackgroundTask{
    UIApplication* app = [UIApplication sharedApplication];
    __block  UIBackgroundTaskIdentifier  bgTask ;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        //这里延迟的系统时间结束
        NSLog(@"backgroundTimeRemaining======%f",app.backgroundTimeRemaining);
    }];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [self startBackgroundTask];
//    [self startLocationUpdate];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadList" object:nil];
}

- (void)startLocationUpdate{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.delegate = self;
        [_locationManager requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];
    }
}

/** 获取到新的位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//  NSLog(@"定位到了%@",locations);
}
/** 不能获取位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"获取定位失败%@",error.description);
}

@end
