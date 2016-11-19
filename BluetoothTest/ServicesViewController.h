//
//  ServicesViewController.h
//  bluetooth
//
//  Created by  on 16/11/1.
//  Copyright © 2016年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ServicesViewController : UIViewController


@property (nonatomic,strong) CBPeripheral *selectPeripheral;
@end
