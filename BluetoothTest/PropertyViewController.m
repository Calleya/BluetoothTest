//
//  PropertyViewController.m
//  bluetooth
//
//  Created by on 16/11/16.
//  Copyright © 2016年 com. All rights reserved.
//

#import "PropertyViewController.h"
#import "CentralManager.h"
#import "ReadViewController.h"
#import "NotifyViewController.h"
#import "WriteDataViewController.h"
#import "SVProgressHUD.h"

@interface PropertyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PropertyViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _uuidLabel.text = [NSString stringWithFormat:@"UUID: %@",_uuidString];
    [self connectStatusDelegate];
}

#pragma mark 外设连接状态改变
- (void)connectStatusDelegate {
    [CentralManager shareManager].disconnectPeripheral = ^(CBPeripheral *peripheral) {
    
        _statusLabel.text = @"Disconnected";
        [SVProgressHUD showErrorWithStatus:@"Disconnected"];
    };
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _properties.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"Properties";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = _properties[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([_properties[indexPath.row] isEqualToString:@"Read"]) {
        ReadViewController *readVC = [[ReadViewController alloc] init];
        readVC.uuidString = _selectCharactistic.UUID.UUIDString;
        readVC.selectCharactistic = _selectCharactistic;
        [self.navigationController pushViewController:readVC animated:YES];
    }
    if ([_properties[indexPath.row] isEqualToString:@"Notify"]) {
        NotifyViewController *monitorVC = [[NotifyViewController alloc] init];
        monitorVC.uuidString = _selectCharactistic.UUID.UUIDString;
        monitorVC.selectCharactistic = _selectCharactistic;
        [self.navigationController pushViewController:monitorVC animated:YES];
    }
    if ([_properties[indexPath.row] isEqualToString:@"Write"]) {
        WriteDataViewController *writeVC = [[WriteDataViewController alloc] init];
        writeVC.uuidString = _selectCharactistic.UUID.UUIDString;
        writeVC.characteristic = _selectCharactistic;
        [self.navigationController pushViewController:writeVC animated:YES];
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
