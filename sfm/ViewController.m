//
//  ViewController.m
//  sfm
//
//  Created by LY_MD on 2021/12/15.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "BRDatePickerView.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,copy)NSString *selectTime;
@property(nonatomic,strong)NSMutableArray*dataAry;
@property(nonatomic,strong)UITableView *tabV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];

    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.title = [self hmsformatterDate];
    }];

    [self initData];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];

    UITableView *tabV = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    tabV.delegate = self;
    tabV.dataSource = self;
    [self.view addSubview:tabV];
    tabV.tableFooterView =[UIView new];
    self.tabV = tabV;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadList) name:@"reloadList" object:nil];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataAry.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSString *ident = self.dataAry[indexPath.row];
    cell.textLabel.text = [ident componentsSeparatedByString:@"/"][1];
    cell.detailTextLabel.text = [ident componentsSeparatedByString:@"/"][0];
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{

    UIContextualAction * deleteAction =  [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"??????" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
                   for (UNNotificationRequest *req in requests){
                       NSLog(@"?????????ID:%@\n",req.identifier);
                       if ([req.identifier isEqualToString:self.dataAry[indexPath.row]]) {
                           [center removePendingNotificationRequestsWithIdentifiers:@[req.identifier]];
                       }
                   }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataAry removeObjectAtIndex:indexPath.row];
                [self.tabV reloadData];
            });

        }];
       completionHandler(YES);
     }];

    NSArray<UIContextualAction *> * arrayTemp = @[deleteAction];
    UISwipeActionsConfiguration * swipeConfiguration = [UISwipeActionsConfiguration configurationWithActions: arrayTemp];
    //???????????????,???????????????????????????
    swipeConfiguration.performsFirstActionWithFullSwipe = YES;
    return swipeConfiguration;
}
- (void)reloadList {
    [self initData];
}
- (void)initData {

    self.dataAry = [NSMutableArray array];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
               for (UNNotificationRequest *req in requests){
                   NSLog(@"?????????ID:%@\n",req.identifier);
                   [self.dataAry addObject:req.identifier];
                }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tabV reloadData];
        });

    }];
}

- (void)add {
    BRDatePickerView *datePickerView = [[BRDatePickerView alloc]init];
    datePickerView.pickerMode = BRDatePickerModeYMDHMS;
    datePickerView.title = @"??????????????????";
    datePickerView.minDate = [NSDate br_setYear:2018 month:3 day:10];
    datePickerView.maxDate = [NSDate br_setYear:2025 month:10 day:20];
    datePickerView.isAutoSelect = NO;

    // ???????????????????????????
    datePickerView.nonSelectableDates = @[[NSDate br_setYear:2020 month:8 day:1], [NSDate br_setYear:2020 month:9 day:10]];
    datePickerView.keyView = self.view; // ????????? datePickerView ????????? self.view ???????????????????????? keyWindow ???
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

    // 2.??????????????????date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    // 3.????????????
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 4.?????????????????????????????????????????????
    NSDateComponents *cmps = [calendar components:type fromDate:date2 toDate:date1 options:0];
    // 5.????????????
//    NSLog(@"??????????????????%ld???%ld???%ld???%ld??????%ld??????%ld???", cmps.year, cmps.month, cmps.day, cmps.hour, cmps.minute, cmps.second);
    long disSec = cmps.day * 24 * 60 * 60 + cmps.hour * 60 * 60 + cmps.minute * 60 + cmps.second;

    return disSec;
}

- (void)addLocalNotice:(long)sec {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"?????????????????????";
        content.subtitle = @"?????????????????????????????????????????????";
        content.body = self.selectTime;

        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:sec] timeIntervalSinceNow];
        if (time < 1) {
            return;
        }
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        NSString *identifier = [NSString stringWithFormat:@"%@/%@", [NSUUID UUID].UUIDString,self.selectTime];

        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataAry addObject:identifier];
                [self.tabV reloadData];
                self.view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
            });

        }];
    }
}

@end
