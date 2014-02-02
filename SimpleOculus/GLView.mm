//
//  GLView.m
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "GLView.h"
#include "BasicRenderer.h"
#include "OVR.h"
#include <iostream.h>
#include <stdio.h>

#define Z_NEAR 0.1f
#define Z_FAR 10.0f

using namespace OVR;
using namespace std;

@interface GLView (){
    NSTimer *renderTimer;
    BasicRenderer renderer;
    Ptr<DeviceManager>	pManager;
    Ptr<HMDDevice>		pHMD;
    Ptr<SensorDevice>	pSensor;
    SensorFusion*		pFusionResult;
    HMDInfo             Info;
    bool                InfoLoaded;
    Matrix4f rotation;
    int w;
    int h;
}

@end

@implementation GLView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initWithFrame");
        // Initialization code here.
        [self wantsBestResolutionOpenGLSurface];
    }
    return self;
}

-(void) prepareOpenGL{
//    NSLog(@"prepareOpenGL");
//    GLint swapInt = 1;
//  [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

    w = 1280;
    h = 800;
    static float _fieldOfView = M_PI/2.;
    float _aspectRatio = (float)w/(float)h;
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    GLfloat frustum = Z_NEAR * tanf(_fieldOfView / 2.0);
    glFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    //glFrustum(-0.1, 0.1, -(float)(h)/(10.0*(float)(w)), (float)(h)/(10.0*(float)(w)), 0.5, 1000.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    renderer.init();
    // Oculus
//    [self initOculus];
//    [self closeOculus];
}

-(void) initOculus{
    System::Init();
    
    pFusionResult = new SensorFusion();
    pManager = *DeviceManager::Create();
    pHMD = *pManager->EnumerateDevices<HMDDevice>().CreateDevice();
    if (pHMD){
        InfoLoaded = pHMD->GetDeviceInfo(&Info);
        pSensor = *pHMD->GetSensor();
    }
    else{
        pSensor = *pManager->EnumerateDevices<SensorDevice>().CreateDevice();
    }
    if (pSensor){
        pFusionResult->AttachToSensor(pSensor);
    }
    [self LogOculus];
    [NSTimer scheduledTimerWithTimeInterval:1./60. target:self selector:@selector(updateOculus) userInfo:Nil repeats:YES];
}

-(void) updateOculus{
    if(pSensor){
		Quatf quaternion = pFusionResult->GetOrientation();
        
		float yaw, pitch, roll;
		quaternion.GetEulerAngles<Axis_Y, Axis_X, Axis_Z>(&yaw, &pitch, &roll);
        
//		cout << " Yaw: " << RadToDegree(yaw) <<
//        ", Pitch: " << RadToDegree(pitch) <<
//        ", Roll: " << RadToDegree(roll) << endl;
        Matrix4f mat = [self identityMatrix];//[self getRotationMatrix:quaternion];
        renderer.matrix[0] = mat.M[0][0];
        renderer.matrix[1] = mat.M[0][1];
        renderer.matrix[2] = mat.M[0][2];
        renderer.matrix[3] = mat.M[0][3];
        renderer.matrix[4] = mat.M[1][0];
        renderer.matrix[5] = mat.M[1][1];
        renderer.matrix[6] = mat.M[1][2];
        renderer.matrix[7] = mat.M[1][3];
        renderer.matrix[8] = mat.M[2][0];
        renderer.matrix[9] = mat.M[2][1];
        renderer.matrix[10] = mat.M[2][2];
        renderer.matrix[11] = mat.M[2][3];
        renderer.matrix[12] = mat.M[3][0];
        renderer.matrix[13] = mat.M[3][1];
        renderer.matrix[14] = mat.M[3][2];
        renderer.matrix[15] = mat.M[3][3];
//        NSLog(@"\n%f %f %f\n%f %f %f\n%f %f %f",
//              mat.M[0][0],mat.M[0][1],mat.M[0][2],
//              mat.M[1][0],mat.M[1][1],mat.M[1][2],
//              mat.M[2][0],mat.M[2][1],mat.M[2][2]);
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
	cout << "----- Oculus Console -----" << endl;
    
	if (pHMD)
		cout << " [x] HMD Found" << endl;
	else
		cout << " [ ] HMD Not Found" << endl;
	if (pSensor)
		cout << " [x] Sensor Found" << endl;
	else
        cout << " [ ] Sensor Not Found" << endl;
	cout << "--------------------------" << endl;
	if (InfoLoaded)
    {
		cout << " DisplayDeviceName: " << Info.DisplayDeviceName << endl;
		cout << " ProductName: " << Info.ProductName << endl;
		cout << " Manufacturer: " << Info.Manufacturer << endl;
		cout << " Version: " << Info.Version << endl;
		cout << " HResolution: " << Info.HResolution<< endl;
		cout << " VResolution: " << Info.VResolution<< endl;
		cout << " HScreenSize: " << Info.HScreenSize<< endl;
		cout << " VScreenSize: " << Info.VScreenSize<< endl;
		cout << " VScreenCenter: " << Info.VScreenCenter<< endl;
		cout << " EyeToScreenDistance: " << Info.EyeToScreenDistance << endl;
		cout << " LensSeparationDistance: " << Info.LensSeparationDistance << endl;
		cout << " InterpupillaryDistance: " << Info.InterpupillaryDistance << endl;
		cout << " DistortionK[0]: " << Info.DistortionK[0] << endl;
		cout << " DistortionK[1]: " << Info.DistortionK[1] << endl;
		cout << " DistortionK[2]: " << Info.DistortionK[2] << endl;
		cout << "--------------------------" << endl;
    }
	if(pSensor){
		Quatf quaternion = pFusionResult->GetOrientation();
		float yaw, pitch, roll;
		quaternion.GetEulerAngles<Axis_Y, Axis_X, Axis_Z>(&yaw, &pitch, &roll);
		cout << " Yaw: " << RadToDegree(yaw) <<
        ", Pitch: " << RadToDegree(pitch) <<
        ", Roll: " << RadToDegree(roll) << endl;
	}
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

- (void)drawRect:(NSRect)dirtyRect{
//    NSLog(@"drawRect");
    NSRect backingBounds = [self convertRectToBacking:[self bounds]];
	glViewport(0, 0, w, h);//backingBounds.size.width, backingBounds.size.height);
    renderer.render();
}
-(Matrix4f) identityMatrix
{
    Matrix4f _mat;
    _mat.M[0][0] = 1.0; _mat.M[1][0] = 0.0; _mat.M[2][0] = 0.0; _mat.M[3][0] = 0.0;
    _mat.M[0][1] = 0.0; _mat.M[1][1] = 1.0; _mat.M[2][1] = 0.0; _mat.M[3][1] = 0.0;
    _mat.M[0][2] = 0.0; _mat.M[1][2] = 0.0; _mat.M[2][2] = 1.0; _mat.M[3][2] = 0.0;
    _mat.M[0][3] = 0.0; _mat.M[1][3] = 0.0; _mat.M[2][3] = 0.0; _mat.M[3][3] = 1.0;
    return _mat;
}
-(Matrix4f) getRotationMatrix:(const Quatf)q
{
    Matrix4f _mat;
    double length2 =  q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w;
    if (fabs(length2) <= std::numeric_limits<double>::min())
    {
        _mat.M[0][0] = 1.0; _mat.M[1][0] = 0.0; _mat.M[2][0] = 0.0;
        _mat.M[0][1] = 0.0; _mat.M[1][1] = 1.0; _mat.M[2][1] = 0.0;
        _mat.M[0][2] = 0.0; _mat.M[1][2] = 0.0; _mat.M[2][2] = 1.0;
    }
    else
    {
        double rlength2;
        // normalize quat if required.
        // We can avoid the expensive sqrt in this case since all 'coefficients' below are products of two q components.
        // That is a square of a square root, so it is possible to avoid that
        if (length2 != 1.0)
        {
            rlength2 = 2.0/length2;
        }
        else
        {
            rlength2 = 2.0;
        }
        
        // Source: Gamasutra, Rotating Objects Using Quaternions
        //
        //http://www.gamasutra.com/features/19980703/quaternions_01.htm
        
        double wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2;
        
        // calculate coefficients
        x2 = rlength2*q.x;
        y2 = rlength2*q.y;
        z2 = rlength2*q.z;
        
        xx = q.x * x2;
        xy = q.x * y2;
        xz = q.x * z2;
        
        yy = q.y * y2;
        yz = q.y * z2;
        zz = q.z * z2;
        
        wx = q.w * x2;
        wy = q.w * y2;
        wz = q.w * z2;
        
        // Note.  Gamasutra gets the matrix assignments inverted, resulting
        // in left-handed rotations, which is contrary to OpenGL and OSG's
        // methodology.  The matrix assignment has been altered in the next
        // few lines of code to do the right thing.
        // Don Burns - Oct 13, 2001
        _mat.M[0][0] = 1.0 - (yy + zz);
        _mat.M[1][0] = xy - wz;
        _mat.M[2][0] = xz + wy;
        
        
        _mat.M[0][1] = xy + wz;
        _mat.M[1][1] = 1.0 - (xx + zz);
        _mat.M[2][1] = yz - wx;
        
        _mat.M[0][2] = xz - wy;
        _mat.M[1][2] = yz + wx;
        _mat.M[2][2] = 1.0 - (xx + yy);
    }
    
#if 0
    _mat.M[0][3] = 0.0;
    _mat.M[1][3] = 0.0;
    _mat.M[2][3] = 0.0;
    
    _mat.M[3][0] = 0.0;
    _mat.M[3][1] = 0.0;
    _mat.M[3][2] = 0.0;
    _mat.M[3][3] = 1.0;
#endif
    return _mat;
}


@end
