//
//  Public.h
//  bluetooth
//
//  Created by  on 16/11/7.
//  Copyright © 2016年 com. All rights reserved.
//

#ifndef Public_h
#define Public_h


#endif /* Public_h */

// 用于读写数据的服务的UUID字符串
static NSString *kServiceUUIDString = @"";

// 用于读数据的特征字符串FFF2
static NSString *kCharacteristicReadUUIDString = @"";

// 用于写数据的特征字符串FFF1
static NSString *kCharacteristicWriteUUIDString = @"";


// 成功连接设备的回调
typedef void(^setBlockOnConnectPeripheralSuccessful)(CBPeripheral *peripheral);

// 连接设备失败的回调
typedef void(^setBlockOnConnectedPeripheralFailed)(CBPeripheral *peripheral);

// 断开设备的回调
typedef void(^setBlockOnDisconnectPeripheral)(CBPeripheral *peripheral);

// 发现设备的服务的回调
typedef void (^setBlockOnDiscoveredPeripherals)(CBPeripheral *peripheral,NSNumber *rssi);

// 发现服务的特征的回调
typedef void(^setBlockOnDiscoveredCharacteristies)(CBService *service);

// 启动通知后，接收到的特征值的回调
typedef void(^setBlockOnUpdateNotificationsFromePeripheral)(NSData *data);




