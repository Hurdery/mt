//
//  ViewController.m
//  sfm
//
//  Created by LY_MD on 2021/12/15.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "BRDatePickerView.h"
@interface ViewController ()
@property(nonatomic,copy)NSString *selectTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    BRDatePickerView *datePickerView = [[BRDatePickerView alloc]init];
    datePickerView.pickerMode = BRDatePickerModeYMDHMS;
    datePickerView.title = @"恰似一江春水向";
    datePickerView.minDate = [NSDate br_setYear:2018 month:3 day:10];
    datePickerView.maxDate = [NSDate br_setYear:2025 month:10 day:20];
    datePickerView.isAutoSelect = NO;

    // 指定不可选择的日期
    datePickerView.nonSelectableDates = @[[NSDate br_setYear:2020 month:8 day:1], [NSDate br_setYear:2020 month:9 day:10]];
    datePickerView.keyView = self.view; // 将组件 datePickerView 添加到 self.view 上，默认是添加到 keyWindow 上
    datePickerView.resultBlock = ^(NSDate *selectDate, NSString *selectValue) {
        self.selectTime = selectValue;
        [self addLocalNotice:[self twoTimeSpace:self.selectTime]];
    };
    [datePickerView show];
}

- (NSString *)hmsformatterDate{
  NSDate *  senddate=[NSDate date];
  NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
  [dateformatter setDateFormat:@"HH:mm:ss"];
  NSString * locationString=[dateformatter stringFromDate:senddate];
  return locationString;
}

- (NSString *)ssformatterDate{
  NSDate *  senddate=[NSDate date];
  NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
  [dateformatter setDateFormat:@"ss"];
  NSString * locationString=[dateformatter stringFromDate:senddate];
  return locationString;
}
-(long)twoTimeSpace:(NSString *)oneTime{

    NSString *time1 = oneTime;
    NSDate *date22 = [NSDate date];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time2 = [formatter2 stringFromDate: date22];

    // 2.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    // 3.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 4.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date2 toDate:date1 options:0];
    // 5.输出结果
//    NSLog(@"两个时间相差%ld年%ld月%ld日%ld小时%ld分钟%ld秒", cmps.year, cmps.month, cmps.day, cmps.hour, cmps.minute, cmps.second);
    long disSec = cmps.day * 24 * 60 * 60 + cmps.hour * 60 * 60 + cmps.minute * 60 + cmps.second;

    return disSec;
}

- (void)addLocalNotice:(long)sec {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"人生得意须尽欢";
        content.subtitle = @"岑夫子，丹丘生，将进酒，杯莫停";
        content.body = self.selectTime;

        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:sec] timeIntervalSinceNow];
        if (time < 1) {
            return;
        }
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        NSString *identifier = [NSUUID UUID].UUIDString;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");

            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
            });

        }];
    }
}

@end
