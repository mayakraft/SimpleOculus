//
//  OculusInterface.h
//  SimpleOculus
//
//  Created by Robby Kraft on 2/1/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OculusInterface : NSObject

@property float *orientation;  // 4x4 orientation matrix
@property float IPD;           // virtual interpupillary distance

-(void) LogOculus;

@end
