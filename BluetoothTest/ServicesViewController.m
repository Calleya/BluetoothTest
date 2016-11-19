//
//  ServicesViewController.m
//  bluetooth
//
//  Created by  on 16/11/1.
//  Copyright © 2016年 com. All rights reserved.
//

#import "ServicesViewController.h"
#import "NotifyViewController.h"
#import "WriteDataViewController.h" 
#import "PropertyViewController.h"

#import "CentralManager.h"
#import "Public.h"
#import "SVProgressHUD.h"
@interface ServicesViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *peripheralName;
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
@property (weak, nonatomic) IBOutlet UITableView *peripheraInformatiom;

// 保存扫描到的所有的服务
@property (nonatomic, strong) NSMutableArray *serviceArray;
@end

@implementation ServicesViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _peripheralName.text = _selectPeripheral.name;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _serviceArray = [NSMutableArray array];
    
    self.peripheraInformatiom.estimatedRowHeight = 200;
    // 清除多余的cell
    self.peripheraInformatiom.tableFooterView = [[UIView alloc]init];
    
    [self connectStatusDelegate];
    [self discoveredCharacteristicsDelegate];
}

#pragma mark 外设连接状态改变
- (void)connectStatusDelegate {
    
    [CentralManager shareManager].disconnectPeripheral = ^(CBPeripheral *peripheral) {
        _connectStatus.text = @"Disconnected";
        [SVProgressHUD showErrorWithStatus:@"Disconnected"];
        _serviceArray = [NSMutableArray array];
        [_peripheraInformatiom reloadData];
    };
}

#pragma mark 外设发现特征的改变
- (void)discoveredCharacteristicsDelegate {
    
    [CentralManager shareManager].discoveredCharacteristiesBlock = ^(CBService *service) {
        // 保存所有发现的服务
        [_serviceArray addObject:service];
        [_peripheraInformatiom reloadData];
    };
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    CBService *service = _serviceArray[section];
    NSArray *characteristic = service.characteristics;
    
    return characteristic.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _serviceArray.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    CBService *service = _serviceArray[section];
    NSString *title = [NSString stringWithFormat:@"UUID: %@",service.UUID];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CBService *service = _serviceArray[indexPath.section];
    NSArray *characterArray = service.characteristics;
    CBCharacteristic *characteristic = characterArray[indexPath.row];
    NSLog(@"%@",characteristic);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", characteristic.UUID];
    cell.textLabel.numberOfLines = 0;
    
    // 有读写特征的可以跳转
    if ([self getCharacteristicProperties:characteristic.properties]) {
        cell.detailTextLabel.text = [self getCharacteristicProperties:characteristic.properties];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CBService *service = _serviceArray[indexPath.section];
    CBCharacteristic *characteristic = service.characteristics[indexPath.row];
    NSString *properities = [self getCharacteristicProperties:characteristic.properties];
    if (properities) {
        NSArray *array = [properities componentsSeparatedByString:@" "];        
        PropertyViewController *propertyVC = [[PropertyViewController alloc] init];
        propertyVC.properties = array;
        propertyVC.uuidString = characteristic.UUID.UUIDString;
        propertyVC.selectCharactistic = characteristic;
        [self.navigationController pushViewController:propertyVC animated:YES];
    }

}

// 对特征的properties进行位运算，确定是否有读、写、通知的特征
- (NSString *)getCharacteristicProperties:(CBCharacteristicProperties)properties {
    
    NSString *propertiesString;
    
    if (properties & CBCharacteristicPropertyRead) {
        
        propertiesString = @"Read";
    }
    if (properties & CBCharacteristicPropertyWrite) {
        if (!propertiesString) {
            propertiesString = @"Write";
        }
        else {
            propertiesString = [NSString stringWithFormat:@"%@ Write",propertiesString];
        }
    }
    if (properties & CBCharacteristicPropertyNotify) {
        if (!propertiesString) {
            propertiesString = @"Notify";
        }
        else {
            propertiesString = [NSString stringWithFormat:@"%@ Notify",propertiesString];
        }
        
    }
#if 0
    if (properties & CBCharacteristicPropertyBroadcast) {
        propertiesString = @"Property:Broadcast";
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        propertiesString = @"Property:WriteWithoutResponse";
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        propertiesString = @"Property:Indicate";
    }
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        propertiesString = @"Property:AuthenticatedSignedWrites";
    }
    if (properties & CBCharacteristicPropertyExtendedProperties) {
        propertiesString = @"Property:ExtendedProperties";
    }
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        propertiesString = @"Property:NotifyEncryptionRequired";
    }
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        propertiesString = @"Property:IndicateEncryptionRequired";
    }
#endif
    return propertiesString;
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
