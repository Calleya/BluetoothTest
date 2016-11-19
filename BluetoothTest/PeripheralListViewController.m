//
//  PeripheralListViewController.m
//  bluetooth
//
//  Created by  on 16/11/1.
//  Copyright © 2016年 . All rights reserved.
//

#import "PeripheralListViewController.h"
#import "CentralManager.h"
#import "ServicesViewController.h"
#import "SVProgressHUD.h"

@interface PeripheralListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) CentralManager *centerManager;
@property (nonatomic,strong) CBPeripheral *selectPeripheral;
@property (nonatomic,strong) NSMutableArray *peripherals;
@property (nonatomic,strong) NSMutableArray *rssiArray;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation PeripheralListViewController

- (void)viewWillAppear:(BOOL)animated {
    [[CentralManager shareManager] disconnectDevice];
    [self scanPeripheral];
    [_tableview reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    // 清除多余的cell
    self.tableview.tableFooterView = [[UIView alloc]init];
    
    [self creatNavigationBar];
}

- (void)creatNavigationBar {
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(scanPeripheral)];
    
    [self.navigationItem setTitle:@"Peripherals List"];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)scanPeripheral {

    _centerManager = [CentralManager shareManager];
    [_centerManager initCentralManager];
    
    _peripherals = [NSMutableArray array];
    _rssiArray = [NSMutableArray array];
    
    __weak PeripheralListViewController *wself = self;
    _centerManager.discoveredPeripheralsBlock = ^(CBPeripheral *peripheral,NSNumber *rssi) {
        if (![wself.peripherals containsObject:peripheral]) {
            [wself.peripherals addObject:peripheral];
            [wself.rssiArray addObject:[NSString stringWithFormat:@"%@",rssi]];
            [wself.tableview reloadData];
        }
    };
    
    [self connectSuccessBlock];
    [self connectFailedBlock];
    
}

#pragma mark connectStatus 连接硬件的状态，成功或者是失败的回调
- (void)connectSuccessBlock {
    __weak PeripheralListViewController *wself = self;
    _centerManager.connectSuccessBlock = ^(CBPeripheral *peripheral) {
        [SVProgressHUD dismiss];
        ServicesViewController *deviceDetailVC = [[ServicesViewController alloc] init];
        deviceDetailVC.selectPeripheral = peripheral;
        [wself.navigationController pushViewController:deviceDetailVC animated:YES];
    };
}

- (void)connectFailedBlock {
    _centerManager.connectedPeripeheralFailed = ^(CBPeripheral *peripheral) {
        [SVProgressHUD showErrorWithStatus:@"Connection failed"];
    };
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _peripherals.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (_peripherals.count) {
        CBPeripheral *peri = self.peripherals[indexPath.row];
        if (peri.name) {
            cell.textLabel.text = peri.name;
        }
        else {
            cell.textLabel.text = @"Unnamed";
        }
        cell.detailTextLabel.text = _rssiArray[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.centerManager.centralManager connectPeripheral:_peripherals[indexPath.row] options:nil];
    
    [SVProgressHUD showWithStatus:@"Connecting..."];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
}



@end
