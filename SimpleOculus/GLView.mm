//
//  GLView.m
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "GLView.h"
#import "OculusRift.h"
#include "GLScene.h"

@interface GLView (){
    OculusRift *oculusRift;
    NSTimer *renderTimer;
    GLScene scene;
    int w, h;
    bool isFullscreen;
    NSRect windowRect;
}

@end

@implementation GLView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        NSLog(@"initWithCoder");
        NSOpenGLContext *glcontext = [self openGLContext];
        [glcontext makeCurrentContext];
        oculusRift = [[OculusRift alloc] init];
    }
    return self;
}

-(void) awakeFromNib{
    NSLog(@"awakeFromNib");
    [self setupRenderTimer];
}

- (void)reshape{ 	// scrolled, moved or resized
	NSRect baseRect = [self convertRectToBase:[self bounds]];
	w = baseRect.size.width;
	h = baseRect.size.height;
    NSLog(@"reshape() (%d, %d)", w, h);
    [[self openGLContext] update];
}

-(void) update{  		// moved or resized
    NSLog(@"update");
//  [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

- (void) setupRenderTimer{
    if(!renderTimer){
        scene.init();
        
        renderTimer = [NSTimer scheduledTimerWithTimeInterval:.005 target:self selector:@selector(updateGLView:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSModalPanelRunLoopMode];
//        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSDefaultRunLoopMode];
    }
}

-(void)keyDown:(NSEvent *)theEvent
{
    NSString *characters = [theEvent characters];
    if ([characters length]) {
        unichar character = [characters characterAtIndex:0];
		switch (character) {
			case 'f':
				NSLog(@"f");
                [self toggleFullscreen];
				break;
		}
	}
}

- (BOOL)acceptsFirstResponder{
    return YES;
}
- (BOOL)becomeFirstResponder{
    return  YES;
}
- (BOOL)resignFirstResponder{
    return YES;
}

- (void) updateGLView:(NSTimer *)timer{
    scene.update();
//    NSLog(@"%f",oculusInterface.headsetOrientation[2]);
    [self sendOrientation];
    [self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)dirtyRect{

    glClear (GL_COLOR_BUFFER_BIT);

    for(int eye = 0; eye < 2; eye++){  // 0 left, 1 right
//        glColor3ub(255,255,255);  // color overlay
        if(eye == 0){
            glViewport (0, 0, w/2., h);
            glMatrixMode (GL_PROJECTION);
            glLoadIdentity ();
            [self glPerspective:75.0f Aspect:(GLfloat)(w/2.)/(GLfloat)(h) Near:.1f Far:100.0f];
        }
        else if (eye == 1){
            glViewport (w/2., 0, w/2., h);
            glMatrixMode (GL_PROJECTION);
            glLoadIdentity ();
            [self glPerspective:75.0f Aspect:(GLfloat)(w/2.)/(GLfloat)(h) Near:.1f Far:100.0f];
        }
        glMatrixMode (GL_MODELVIEW);
        glLoadIdentity ();
        glClear (GL_DEPTH_BUFFER_BIT); 
        
        if(eye == 0){ // left
            glTranslatef(0.01f, 0.0f, 0.0f);
        }
        else if (eye == 1){
            glTranslatef(-0.01f, 0.0f, 0.0f);
        }
        scene.render();
    }
    glFlush();
}

// replacement for gluPerspective from NEHE
-(void) glPerspective:(GLdouble)fovY Aspect:(GLdouble)aspect Near:(GLdouble)zNear Far:(GLdouble) zFar{
    const GLdouble pi = 3.14159265359;
    GLdouble fW, fH;
    fH = tan(fovY/360.*pi) * zNear;
    fW = fH * aspect;
    glFrustum(-fW, fW, -fH, fH, zNear, zFar);
}

-(void) sendOrientation{
    for(int i = 0; i < 16; i++)
        scene.orientation[i] = oculusRift.orientation[i];
}

-(void)activateFullScreen{
    NSRect mainDisplayRect = [[NSScreen mainScreen] frame];
    w = mainDisplayRect.size.width;
    h = mainDisplayRect.size.height;
    [self setFrame:mainDisplayRect];
}

- (void)toggleFullscreen
{
    NSWindow *mainWindow = [self window];
    if (isFullscreen) {
        [mainWindow setLevel:NSNormalWindowLevel];
        [mainWindow makeKeyWindow];
        [mainWindow makeFirstResponder:self];
        [mainWindow setStyleMask:NSTitledWindowMask | NSClosableWindowMask |
                                 NSMiniaturizableWindowMask | NSResizableWindowMask ];
        [mainWindow setFrame:windowRect display:true];
        [mainWindow setAcceptsMouseMovedEvents:YES];
        [mainWindow setTitle:@"SimpleOculus"];
        isFullscreen = false;
    } else {
        // before leaving, store last window position/size
        windowRect = [self convertRectToBase:[self bounds]];
        NSRect fullscreenFrame = [[NSScreen mainScreen] frame];
        w = fullscreenFrame.size.width;
        h = fullscreenFrame.size.height;
        [mainWindow setStyleMask:NSBorderlessWindowMask];
        [mainWindow setFrame:fullscreenFrame display:true];
        [mainWindow setAcceptsMouseMovedEvents:YES];
        [mainWindow makeKeyAndOrderFront:self];
        [mainWindow setLevel:NSScreenSaverWindowLevel-1];
        [mainWindow makeFirstResponder:self];
        isFullscreen = true;
    }
}

@end
