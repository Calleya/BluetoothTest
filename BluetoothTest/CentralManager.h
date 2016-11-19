//
//  CentralManager.h
//  bluetooth
//
//  Created by  on 16/11/4.
//  Copyright © 2016年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "Public.h"

@interface CentralManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

// 中心管理者
@property (nonatomic,strong) CBCentralManager *centralManager;

// 选择的外设
@property (nonatomic,strong) CBPeripheral *selectPeripheral;

// 特征
@property (nonatomic,strong) CBCharacteristic *characteristic;

@property (nonatomic, copy) setBlockOnConnectPeripheralSuccessful connectSuccessBlock;

@property (nonatomic, copy) setBlockOnConnectedPeripheralFailed connectedPeripeheralFailed;

@property (nonatomic, copy) setBlockOnDisconnectPeripheral disconnectPeripheral;

@property (nonatomic, copy) setBlockOnDiscoveredPeripherals discoveredPeripheralsBlock;

@property (nonatomic, copy) setBlockOnDiscoveredCharacteristies discoveredCharacteristiesBlock;

@property (nonatomic, copy) setBlockOnUpdateNotificationsFromePeripheral updateNotifationsBlock;


+ (instancetype)shareManager;

- (void)initCentralManager;

// 开始扫描
- (void)startScanPeripheral;

- (void)disconnectDevice;

// 开始启动通知，接受特征值的更新
- (void)startMonitor:(BOOL)isStart selectCharacteristic:(CBCharacteristic *)characteristic;

// 
- (void)readValue:(CBCharacteristic *)characteristic;

- (void)writeData:(NSData *)valueData forCharacteristic:(CBCharacteristic *)characteristic;

@end
