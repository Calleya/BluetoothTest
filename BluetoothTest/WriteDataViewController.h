//
//  WriteDataViewController.h
//  bluetooth
//
//  Created by on 16/11/8.
//  Copyright © 2016年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface WriteDataViewController : UIViewController

@property (nonatomic, strong) NSString *uuidString;

@property (nonatomic, strong) CBCharacteristic *characteristic;

@end
