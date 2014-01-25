//
//  GLView.m
//  BasicGL
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import "GLView.h"
#include "BasicRenderer.h"

@interface GLView (){
    NSTimer *renderTimer;
    BasicRenderer renderer;
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
    NSLog(@"prepareOpenGL");
    GLint swapInt = 1;
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    renderer.init();
}

-(void) awakeFromNib{
    NSLog(@"awakeFromNib");
    renderTimer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(timerFired:) userInfo:Nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode];
}

-(void) timerFired:(id)sender{
    NSLog(@"timerFired");
    renderer.update();
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"drawRect");
//	[super drawRect:dirtyRect];
    NSRect backingBounds = [self convertRectToBacking:[self bounds]];
	glViewport(0, 0, backingBounds.size.width, backingBounds.size.height);
    renderer.render();
}

@end
