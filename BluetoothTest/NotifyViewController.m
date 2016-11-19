//
//  NotifyViewController.m
//  bluetooth
//
//  Created by on 16/11/8.
//  Copyright © 2016年 com. All rights reserved.
//

#import "NotifyViewController.h"
#import "CentralManager.h"

#import "SVProgressHUD.h"

@interface NotifyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *uuidStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property (weak, nonatomic) IBOutlet UIButton *listenButton;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;


@property (nonatomic) NSMutableArray *dataArray;

@end

@implementation NotifyViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[CentralManager shareManager] startMonitor:NO selectCharacteristic:_selectCharactistic];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _dataArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataTableView.tableFooterView = [[UIView alloc] init];
        _uuidStringLabel.text = [NSString stringWithFormat:@"UUID: %@",_uuidString];;
    
    [self connectStatusDelegate];
    [self updateNotifationsDelegate];
}

#pragma mark 外设连接状态改变
- (void)connectStatusDelegate {
    [CentralManager shareManager].disconnectPeripheral = ^(CBPeripheral *peripheral) {
        
        _connectStatus.text = @"Disconnected";
        [_listenButton setTitle:@"Listen for notifications" forState:UIControlStateNormal];
        _listenButton.enabled = NO;
        [SVProgressHUD showErrorWithStatus:@"Disconnected"];
    };
}

#pragma mark 监听到外设发出的数据
- (void)updateNotifationsDelegate {
    [CentralManager shareManager].updateNotifationsBlock = ^(NSData *data) {
        
        if (data) {
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            [format setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            NSString *time=[format stringFromDate:[NSDate date]];
            NSArray *dataArr = @[data,time];
            [_dataArray insertObject:dataArr atIndex:0];
            [_dataTableView reloadData];
        }
    };
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *indentify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentify];
    }
    NSArray *array = _dataArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",array[0]];
    cell.detailTextLabel.text = array[1];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (IBAction)listenDataFromDevice:(id)sender {
    
    if ([_listenButton.titleLabel.text isEqualToString:@"Listen for notifications"]) {
        [_listenButton setTitle:@"Stop listening" forState:UIControlStateNormal];
        [[CentralManager shareManager] startMonitor:YES selectCharacteristic:_selectCharactistic];
    }
    else {
        [_listenButton setTitle:@"Listen for notifications" forState:UIControlStateNormal];
        [[CentralManager shareManager] startMonitor:NO selectCharacteristic:_selectCharactistic];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
