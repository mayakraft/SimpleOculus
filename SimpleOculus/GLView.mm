//
//  GLView.m
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "GLView.h"
#include "BasicRenderer.h"

#define Z_NEAR 0.1f
#define Z_FAR 10.0f

@interface GLView (){
    NSTimer *renderTimer;
    BasicRenderer renderer;
    int w, h;
    float _fieldOfView, frustum, _aspectRatio;
}

@end

@implementation GLView
//- (void)clearGLContext{}
//- (void)update{}		// moved or resized
//- (void)reshape{}	// scrolled, moved or resized

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        NSLog(@"init");
        
        NSOpenGLContext *glcontext = [self openGLContext];
        [glcontext makeCurrentContext];

        [self setupRenderTimer];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect pixelFormat:(NSOpenGLPixelFormat*)format {
    self = [super initWithFrame:frameRect pixelFormat:format];
    if (self) {
        NSLog(@"initWithFrame pixelFormat");
        // Initialization code here.
        [self wantsBestResolutionOpenGLSurface];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"initWithFrame");
        // Initialization code here.
        [self wantsBestResolutionOpenGLSurface];
    }
    return self;
}

- (void)reshape
{
	NSLog(@"reshaping");
	
	//Get view dimensions
	NSRect baseRect = [self convertRectToBase:[self bounds]];
	w = baseRect.size.width;
	h = baseRect.size.height;
	
	//Add your OpenGL resize code here
    
    _fieldOfView = M_PI/2.;
    _aspectRatio = (float)w/(float)h;
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    frustum = Z_NEAR * tanf(_fieldOfView / 2.0);
    glFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    //glFrustum(-0.1, 0.1, -(float)(h)/(10.0*(float)(w)), (float)(h)/(10.0*(float)(w)), 0.5, 1000.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    renderer.init();
   
}

-(void) update{
//    NSLog(@"prepareOpenGL");
//    GLint swapInt = 1;
//  [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    NSLog(@"update");
//    [self setNeedsDisplay:true];
    // Oculus
//    [self initOculus];
//    [self closeOculus];
}

- (void) setupRenderTimer
{
    NSTimeInterval timeInterval = 0.005;
    
    renderTimer =  [ NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                                   selector:@selector( update )
                                                   userInfo:nil repeats:YES ];
    [ [ NSRunLoop currentRunLoop ] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode ];
    [ [ NSRunLoop currentRunLoop ] addTimer:renderTimer forMode:NSModalPanelRunLoopMode ];
}


/*
 * Called by the rendering timer.
 */
- (void) updateGLView:(NSTimer *)timer
{
    [self setNeedsDisplay:true];
//    if( glView != nil )
//        [ glView drawRect:[ glView frame ] ];
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
    NSLog(@"drawRect");
//    NSLog(@"drawRect");
//    NSRect backingBounds = [self convertRectToBacking:[self bounds]];
//	glViewport(0, 0, w, h);//backingBounds.size.width, backingBounds.size.height);

    // normal mode
    if(0){
        glViewport(0, 0, w, h);
        renderer.render();
    }
    else
    {
        // right
        glViewport(0, 0, w/2., h);
        glLoadIdentity ();
//        gluLookAt(5.0f, 5.0f, 5.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
        renderer.render();

        // left
        glViewport(w/2., 0, w/2., h);
        glLoadIdentity();
//        gluLookAt (5.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
        renderer.render();
    }
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    _fieldOfView = M_PI/2.;
    frustum = Z_NEAR * tanf(_fieldOfView / 2.0);
    _aspectRatio = (float)w/(float)h;
    glFrustum(-frustum, frustum, -frustum/_aspectRatio, frustum/_aspectRatio, Z_NEAR, Z_FAR);
    //glFrustum(-0.1, 0.1, -(float)(h)/(10.0*(float)(w)), (float)(h)/(10.0*(float)(w)), 0.5, 1000.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
//    [[self openGLContext] flushBuffer];
}

//- (void) awakeFromNib
//{
//    [ NSApp setDelegate:self ];   // We want delegate notifications
//    renderTimer = nil;
//    //[self makeFirstResponder:self ];
//    glView = [ [ MyOpenGLView alloc ] initWithFrame:[ self.myGLview frame ]
//                                          colorBits:16 depthBits:16 fullscreen:FALSE ];
//    if( glView != nil )
//    {
//        [ self.window.contentView addSubview:glView ];
//        [ self.window makeKeyAndOrderFront:self ];
//        [ self setupRenderTimer ];
//    }
//    else
//        [ self createFailed ];
//}

//-(void) updateOculus{
//    if(pSensor){
//		Quatf quaternion = pFusionResult->GetOrientation();
//        
//		float yaw, pitch, roll;
//		quaternion.GetEulerAngles<Axis_Y, Axis_X, Axis_Z>(&yaw, &pitch, &roll);
//        
//        //		cout << " Yaw: " << RadToDegree(yaw) <<
//        //        ", Pitch: " << RadToDegree(pitch) <<
//        //        ", Roll: " << RadToDegree(roll) << endl;
//        Matrix4f mat = [self identityMatrix];//[self getRotationMatrix:quaternion];
//        renderer.orientation[0] = mat.M[0][0];
//        renderer.orientation[1] = mat.M[0][1];
//        renderer.orientation[2] = mat.M[0][2];
//        renderer.orientation[3] = mat.M[0][3];
//        renderer.orientation[4] = mat.M[1][0];
//        renderer.orientation[5] = mat.M[1][1];
//        renderer.orientation[6] = mat.M[1][2];
//        renderer.orientation[7] = mat.M[1][3];
//        renderer.orientation[8] = mat.M[2][0];
//        renderer.orientation[9] = mat.M[2][1];
//        renderer.orientation[10] = mat.M[2][2];
//        renderer.orientation[11] = mat.M[2][3];
//        renderer.orientation[12] = mat.M[3][0];
//        renderer.orientation[13] = mat.M[3][1];
//        renderer.orientation[14] = mat.M[3][2];
//        renderer.orientation[15] = mat.M[3][3];
//        //        NSLog(@"\n%f %f %f\n%f %f %f\n%f %f %f",
//        //              mat.M[0][0],mat.M[0][1],mat.M[0][2],
//        //              mat.M[1][0],mat.M[1][1],mat.M[1][2],
//        //              mat.M[2][0],mat.M[2][1],mat.M[2][2]);
//	}
//}

@end
