//
//  OculusInterface.h
//  SimpleOculus
//
//  Created by Robby Kraft on 2/1/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OculusInterface : NSObject

@property float *headsetOrientation;  // 4x4 orientation matrix

-(bool) initOculus;
-(void) closeOculus;
-(void) updateOculus;   // updates orientation matrix

@end
