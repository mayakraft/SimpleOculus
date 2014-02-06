//
//  GLView.m
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "OculusView.h"
#import "OculusRift.h"
#include "GLScene.h"

#define INCREMENT .005f

@interface OculusView (){
    OculusRift *oculusRift;
    GLScene scene;
    NSTimer *renderTimer;
    bool isFullscreen;
    int w, h;
}

@end

@implementation OculusView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        NSOpenGLContext *glcontext = [self openGLContext];
        [glcontext makeCurrentContext];
    }
    return self;
}

-(void) awakeFromNib{
    oculusRift = [[OculusRift alloc] init];
    [self setupRenderTimer];
    scene.init();
}

- (void)reshape{   // window scrolled, moved or resized
	NSRect baseRect = [self convertRectToBase:[self bounds]];
	w = baseRect.size.width;
	h = baseRect.size.height;
    [[self openGLContext] update];
}

-(void) update{    // window moved or resized
}

- (void) setupRenderTimer{
    if(!renderTimer){
        renderTimer = [NSTimer scheduledTimerWithTimeInterval:.005 target:self selector:@selector(updateGLView:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSModalPanelRunLoopMode];
    }
}

- (void) updateGLView:(NSTimer *)timer{
    scene.update();
    [self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)rect{
    
    glClear (GL_COLOR_BUFFER_BIT);
    
    for(int eye = 0; eye < 2; eye++){
        if(eye == 0)                        // left screen
            glViewport (0, 0, w/2., h);
        else if (eye == 1)                  // right screen
            glViewport (w/2., 0, w/2., h);
        glMatrixMode (GL_PROJECTION);
        glLoadIdentity ();
        [self glPerspective:90.0f Aspect:(GLfloat)(w/2.)/(GLfloat)(h) Near:.1f Far:10.0f];
        glMatrixMode (GL_MODELVIEW);
        glClear (GL_DEPTH_BUFFER_BIT);
        
        glLoadIdentity ();
        
        if(eye == 0)                        // left
            glTranslatef(oculusRift.IPD, 0.0f, 0.0f);
        else if (eye == 1)                  // right
            glTranslatef(-oculusRift.IPD, 0.0f, 0.0f);
        
        glPushMatrix();
        
        glMultMatrixf(oculusRift.orientation);
        
        scene.render();
        
        glPopMatrix();
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

-(void)keyDown:(NSEvent *)theEvent
{
    NSString *characters = [theEvent characters];
    if([theEvent keyCode] == 53 && isFullscreen)
        [self toggleFullscreen];
    if ([characters length]) {
        unichar character = [characters characterAtIndex:0];
		switch (character) {
			case 'f':
                [self toggleFullscreen];
                break;
			case '=':
            case '+':
                oculusRift.IPD+=INCREMENT;
                NSLog(@"virtual interpupillary distance: %.3f",oculusRift.IPD);
                break;
			case '-':
            case '_':
                oculusRift.IPD-=INCREMENT;
                if(oculusRift.IPD < 0)
                    oculusRift.IPD = 0;
                NSLog(@"virtual interpupillary distance: %.3f",oculusRift.IPD);
                break;
		}
	}
    
}

- (BOOL)acceptsFirstResponder{
    return YES;
}
- (BOOL)becomeFirstResponder{
    return YES;
}

- (void)toggleFullscreen{
    NSWindow *mainWindow = [self window];
    if (isFullscreen) {
        NSRect windowFrame = [[NSScreen mainScreen] visibleFrame];
        w = windowFrame.size.width;
        h = windowFrame.size.height;
        [mainWindow setLevel:NSNormalWindowLevel];
        [mainWindow setStyleMask:NSTitledWindowMask | NSClosableWindowMask |
                                 NSMiniaturizableWindowMask | NSResizableWindowMask ];
        [mainWindow setFrame:windowFrame display:true];
        [mainWindow setAcceptsMouseMovedEvents:YES];
        [mainWindow setTitle:@"SimpleOculus"];
        [mainWindow makeKeyAndOrderFront:self];
        [mainWindow makeFirstResponder:self];
        isFullscreen = false;
    } else {
        NSRect fullscreenFrame = [[NSScreen mainScreen] frame];
        w = fullscreenFrame.size.width;
        h = fullscreenFrame.size.height;
        [mainWindow setStyleMask:NSBorderlessWindowMask];
        [mainWindow setFrame:fullscreenFrame display:true];
        [mainWindow setAcceptsMouseMovedEvents:YES];
        [mainWindow setLevel:NSScreenSaverWindowLevel-1];
        [mainWindow makeKeyAndOrderFront:self];
        [mainWindow makeFirstResponder:self];
        isFullscreen = true;
    }
}

@end
