//
//  CentralManager.m
//  bluetooth
//
//  Created by  on 16/11/4.
//  Copyright © 2016年 com. All rights reserved.
//

#import "CentralManager.h"

@implementation CentralManager

+ (instancetype)shareManager {
    static id shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[CentralManager alloc] init];
    });
    return shareManager;
}

// 创建中心
- (void)initCentralManager {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

// 开始扫描
- (void)startScanPeripheral {
    // 利用中心设备扫描外围设备
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

// 扫描外设中的服务
- (void)discoverSeverInPeripheral {
    _selectPeripheral.delegate = self;
    [_selectPeripheral discoverServices:nil];
    
}

- (void)readValue:(CBCharacteristic *)characteristic{
    [_selectPeripheral readValueForCharacteristic:characteristic];
}

- (void)disconnectDevice {
    
    [self.centralManager cancelPeripheralConnection:_selectPeripheral];
}

// 开始启动通知，接收特征值的更新
- (void)startMonitor:(BOOL)isStart selectCharacteristic:(CBCharacteristic *)characteristic{
    
    [self.selectPeripheral setNotifyValue:isStart forCharacteristic:characteristic];
}

- (void)writeData:(NSData *)valueData forCharacteristic:(CBCharacteristic *)characteristic {
    [self.selectPeripheral writeValue:valueData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark - CBCentralManagerDelegate

// 扫描到外围设备调用
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"Discovered: %@ , RSSI: %@, %@",peripheral.name,RSSI,advertisementData);
    self.discoveredPeripheralsBlock(peripheral,RSSI);
    
}

// 连接外设成功时调用
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"连接成功");
    // 连接成功，停止扫描
    [self.centralManager stopScan];
    _selectPeripheral = peripheral;
    self.connectSuccessBlock(peripheral);
    [self discoverSeverInPeripheral];
}

// 连接外围设备失败时调用
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"连接失败");
    self.connectedPeripeheralFailed(peripheral);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.disconnectPeripheral(peripheral);
    NSLog(@"断开连接");
}

// 只要扫描到服务就会调用
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"扫描服务");
    NSArray *services = peripheral.services;
    for (CBService *service in services) {
        // 从peripheral中得service中扫描特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/**
 
 *  只要扫描到特征就会调用
 *  @param peripheral 特征所属的外设
 *  @param service 特征所属的服务
 
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
//    NSArray *characteristics = service.characteristics;
//    
//    // 遍历特征，拿到需要的特征处理
//    for (CBCharacteristic *character in characteristics) {
//    }
    self.discoveredCharacteristiesBlock(service);
    
}

// 检测代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            // 开始扫描
            [self startScanPeripheral];
            break;
            
        default:
            break;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error == nil) {
        [peripheral readValueForCharacteristic:characteristic];
    }
    
}

#pragma mark处理蓝牙发送过来的数据
// 接收更新的特征值时调用
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
     if (error == nil) {
        NSLog(@"array:%@",characteristic);
        self.updateNotifationsBlock(characteristic.value);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
  
    if (error) {
    NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
}
@end
