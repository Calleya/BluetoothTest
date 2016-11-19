//
//  ReadViewController.h
//  bluetooth
//
//  Created by on 16/11/16.
//  Copyright © 2016年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>

@interface ReadViewController : UIViewController

@property (nonatomic, strong) NSString *uuidString;

@property (nonatomic, strong) CBCharacteristic *selectCharactistic;

@end
