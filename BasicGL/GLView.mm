//
//  GLView.m
//  BasicGL
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "GLView.h"
#include "BasicRenderer.h"
#include "OVR.h"

using namespace OVR;

@interface GLView (){
    NSTimer *renderTimer;
    BasicRenderer renderer;
    Ptr<DeviceManager>	pManager;
    Ptr<HMDDevice>		pHMD;
    Ptr<SensorDevice>	pSensor;
    SensorFusion*		pFusionResult;
    HMDInfo			Info;
    bool			InfoLoaded;
}

@end

@implementation GLView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        NSLog(@"initWithFrame");
        // Initialization code here.
        [self wantsBestResolutionOpenGLSurface];
    }
    return self;
}

-(void) prepareOpenGL{
//    NSLog(@"prepareOpenGL");
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    renderer.init();
    // Oculus
    [self initOculus];
    [self closeOculus];
}

-(void) initOculus{
    System::Init();
    
    pFusionResult = new SensorFusion();
    pManager = *DeviceManager::Create();
    
    pHMD = *pManager->EnumerateDevices<HMDDevice>().CreateDevice();
    
    if (pHMD)
    {
        InfoLoaded = pHMD->GetDeviceInfo(&Info);
        
        pSensor = *pHMD->GetSensor();
    }
    else
    {
        pSensor = *pManager->EnumerateDevices<SensorDevice>().CreateDevice();
    }
    
    if (pSensor)
    {
        pFusionResult->AttachToSensor(pSensor);
    }
}
-(void) closeOculus{
	pSensor.Clear();
    pHMD.Clear();
	pManager.Clear();
    
	delete pFusionResult;
    
	System::Destroy();
}

-(void) LogOculus {
//	cout << "----- Oculus Console -----" << endl;
//    
//	if (pHMD)
//	{
//		cout << " [x] HMD Found" << endl;
//	}
//	else
//	{
//		cout << " [ ] HMD Not Found" << endl;
//	}
//    
//	if (pSensor)
//	{
//		cout << " [x] Sensor Found" << endl;
//	}
//	else
//	{
//		cout << " [ ] Sensor Not Found" << endl;
//	}
//    
//	cout << "--------------------------" << endl;
//    
//	if (InfoLoaded)
//    {
//		cout << " DisplayDeviceName: " << Info.DisplayDeviceName << endl;
//		cout << " ProductName: " << Info.ProductName << endl;
//		cout << " Manufacturer: " << Info.Manufacturer << endl;
//		cout << " Version: " << Info.Version << endl;
//		cout << " HResolution: " << Info.HResolution<< endl;
//		cout << " VResolution: " << Info.VResolution<< endl;
//		cout << " HScreenSize: " << Info.HScreenSize<< endl;
//		cout << " VScreenSize: " << Info.VScreenSize<< endl;
//		cout << " VScreenCenter: " << Info.VScreenCenter<< endl;
//		cout << " EyeToScreenDistance: " << Info.EyeToScreenDistance << endl;
//		cout << " LensSeparationDistance: " << Info.LensSeparationDistance << endl;
//		cout << " InterpupillaryDistance: " << Info.InterpupillaryDistance << endl;
//		cout << " DistortionK[0]: " << Info.DistortionK[0] << endl;
//		cout << " DistortionK[1]: " << Info.DistortionK[1] << endl;
//		cout << " DistortionK[2]: " << Info.DistortionK[2] << endl;
//		cout << "--------------------------" << endl;
//    }
//    
//	cout << endl << " Press ENTER to continue" << endl;
//    
//	cin.get();
//    
//	while(pSensor)
//	{
//		Quatf quaternion = pFusionResult->GetOrientation();
//        
//		float yaw, pitch, roll;
//		quaternion.GetEulerAngles<Axis_Y, Axis_X, Axis_Z>(&yaw, &pitch, &roll);
//        
//		cout << " Yaw: " << RadToDegree(yaw) <<
//        ", Pitch: " << RadToDegree(pitch) <<
//        ", Roll: " << RadToDegree(roll) << endl;
//        
//		Sleep(50);
//        
//		if (_kbhit()) exit(0);
//	}
}

-(void) awakeFromNib{
//    NSLog(@"awakeFromNib");
    renderTimer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(timerFired:) userInfo:Nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode];
}

-(void) timerFired:(id)sender{
//    NSLog(@"timerFired");
    renderer.update();
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
//    NSLog(@"drawRect");
//	[super drawRect:dirtyRect];
    NSRect backingBounds = [self convertRectToBacking:[self bounds]];
	glViewport(0, 0, backingBounds.size.width, backingBounds.size.height);
    renderer.render();
}

@end
