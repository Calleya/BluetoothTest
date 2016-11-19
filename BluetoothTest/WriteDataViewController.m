//
//  WriteDataViewController.m
//  bluetooth
//
//  Created by on 16/11/8.
//  Copyright © 2016年 . All rights reserved.
//

#import "WriteDataViewController.h"

#import "CentralManager.h"
#import "Public.h"
#import "SVProgressHUD.h"

@interface WriteDataViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *uuidStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectedStatus;
@property (weak, nonatomic) IBOutlet UIButton *writeDataButton;
@property (weak, nonatomic) IBOutlet UITableView *writeOrderTableView;

// 保存写入的数据
@property (nonatomic, strong) NSMutableArray *writeDaraArray;
@end

@implementation WriteDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _writeDaraArray = [NSMutableArray array];
    _writeOrderTableView.tableFooterView = [[UIView alloc] init];
    _uuidStringLabel.text = [NSString stringWithFormat:@"UUID: %@",_uuidString];

    [self connectStatusDelegate];
}

#pragma mark 外设连接状态改变
- (void)connectStatusDelegate {
    [CentralManager shareManager].disconnectPeripheral = ^(CBPeripheral *peripheral) {
        _connectedStatus.text = @"Disconnected";
        [SVProgressHUD showErrorWithStatus:@"Disconnected"];
    };
}

- (IBAction)writeDataToDevice:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit Value" message:@"Hex" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *hexTextField = alertController.textFields.firstObject;
        
        NSData *hexData = [self convertHexStrToData:hexTextField.text];
        [[CentralManager shareManager] writeData:hexData forCharacteristic:_characteristic];
        
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        NSString *time=[format stringFromDate:[NSDate date]];
        NSArray *dataArr = @[hexData,time];
        [_writeDaraArray insertObject:dataArr atIndex:0];
        
        [_writeOrderTableView reloadData];
        
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 十六进制转NSData
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    NSLog(@"hexdata: %@", hexData);
    return hexData;
}

#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _writeDaraArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifity = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifity];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifity];
    }
    if (_writeDaraArray.count) {
        NSArray *array = _writeDaraArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",array[0]];
        cell.detailTextLabel.text = array[1];
;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
