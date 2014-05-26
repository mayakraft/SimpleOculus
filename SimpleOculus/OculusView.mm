//
//  GLView.m
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#import <GLUT/GLUT.h>
#import "OculusView.h"
#import "OculusInterface.h"
#include "Scene.h"

#define INCREMENT .005f

// buffer for shader
#define TEXTURE_WIDTH 1024
#define TEXTURE_HEIGHT 1024

#define UP 0
#define DOWN 1
#define LEFT 2
#define RIGHT 3

#define STRIDE .01  // walk speed

@interface OculusView (){
    OculusInterface *oculusRift;
    NSTimer *renderTimer;
    bool isFullscreen;
    int w, h;
    GLuint fboId;
    GLuint rboId;
    GLuint textureId;
    GLuint _program;
    GLint uniforms[6];
    bool warping;  // enable barrel warping

    Scene scene;
    
    float _attitudeMatrix[16];
    
    // keyboard mouse input
    NSPoint mouseRotation;
    bool mouseRotationOn;
    NSPoint walkPosition;
    bool keyboardArrows[4];
}

@end

@implementation OculusView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        NSOpenGLContext *glcontext = [self openGLContext];
        [glcontext makeCurrentContext];
        mouseRotation = NSMakePoint(0.0f, 0.0f);
        mouseRotationOn = false;
        walkPosition = NSMakePoint(0.0f, 0.0f);
        keyboardArrows[0] = keyboardArrows[1] = keyboardArrows[2] = keyboardArrows[3] = false;
    }
    return self;
}

-(void) awakeFromNib{
    oculusRift = [[OculusInterface alloc] init];
    [self setupRenderTimer];
//-------------------------
    scene.init();        // place for custom scene
//-------------------------
}

- (void)reshape{   // window scrolled, moved or resized
	NSRect baseRect = [self convertRectToBase:[self bounds]];
	w = baseRect.size.width;
	h = baseRect.size.height;
    [[self openGLContext] update];
    [self createRenderTarget];
    [[self window] setAcceptsMouseMovedEvents:YES];
}

-(void) update{    // window moved or resized
}

- (void) setupRenderTimer{
    if(!renderTimer){
        renderTimer = [NSTimer scheduledTimerWithTimeInterval:.005 target:self selector:@selector(updateGLView:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:renderTimer forMode:NSModalPanelRunLoopMode];
        [self loadShaders];
    }
}

- (void) updateGLView:(NSTimer *)timer{
    
//TODO: somebody with an Oculus check this for me:
    
//    oculusRift.orientation
//    _lookVector = GLKVector3Make(-_attitudeMatrix.m02,
//                                 -_attitudeMatrix.m12,
//                                 -_attitudeMatrix.m22);
//    _lookAzimuth = atan2f(_lookVector.x, -_lookVector.z);
//    _lookAltitude = asinf(_lookVector.y);
    
//    oculusRift.orientation[2]
//    oculusRift.orientation[6]
//    oculusRift.orientation[10]
//
//    oculusRift.orientation[8]
//    oculusRift.orientation[9]
//    oculusRift.orientation[10]
    
    /* there may be some issues with signs  */
                            /*  THIS is either 2 & 10 or 8 & 10  */
    float lookAzimuth = atan2f(oculusRift.orientation[2], oculusRift.orientation[10]);
    
    float mouseAzimuth = -mouseRotation.x/180.*M_PI;
    
    lookAzimuth += mouseAzimuth;
    
    if(keyboardArrows[UP]){
        float x = STRIDE * sinf(lookAzimuth);
        float y = STRIDE * cosf(lookAzimuth);
        walkPosition.x += x;
        walkPosition.y += y;
    }
    if(keyboardArrows[DOWN]){
        float x = STRIDE * sinf(lookAzimuth);
        float y = STRIDE * cosf(lookAzimuth);
        walkPosition.x -= x;
        walkPosition.y -= y;
    }
    if(keyboardArrows[LEFT]){
        float x = STRIDE * sinf(lookAzimuth+M_PI*.5);
        float y = STRIDE * cosf(lookAzimuth+M_PI*.5);
        walkPosition.x += x;
        walkPosition.y += y;
    }
    if(keyboardArrows[RIGHT]){
        float x = STRIDE * sinf(lookAzimuth+M_PI*.5);
        float y = STRIDE * cosf(lookAzimuth+M_PI*.5);
        walkPosition.x -= x;
        walkPosition.y -= y;
    }
//-------------------------
    scene.update();        // place for custom scene
//-------------------------
    [self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)rect{

    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    for(int eye = 0; eye < 2; eye++){  // 0 = left , 1 = right

        // setup scene to render to texture
        glViewport(0, 0, TEXTURE_WIDTH, TEXTURE_HEIGHT);
        glMatrixMode (GL_PROJECTION);
        glLoadIdentity ();
        [self glPerspective:120.0f Aspect:(GLfloat)(w/2.)/(GLfloat)(h) Near:.1f Far:1000.0f];
        glMatrixMode (GL_MODELVIEW);
        // setup texture
        glBindFramebuffer(GL_FRAMEBUFFER, fboId);
        glClearColor(1, 1, 1, 1);
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        //draw scene to square texture
        glLoadIdentity ();
        // offset by interpupillary distance
        if(eye == 0)
            glTranslatef(oculusRift.IPD, 0.0f, 0.0f);
        else if (eye == 1)
            glTranslatef(-oculusRift.IPD, 0.0f, 0.0f);
        glPushMatrix();
        
            // apply headset orientation
            glMultMatrixf(oculusRift.orientation);
            // mouse rotation
            glRotatef(mouseRotation.y, 1, 0, 0);
            glRotatef(mouseRotation.x, 0, 1, 0);
            // draw scene
//-------------------------
            // keyboard translation
            scene.render(walkPosition.x, walkPosition.y);  // place for custom scene
//-------------------------
        glPopMatrix();
        // unbind framebuffer, now render to screen
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        glBindTexture(GL_TEXTURE_2D, textureId);
        glGenerateMipmap(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, 0);

        if(eye == 0)                        // left screen
            glViewport (0, 0, w/2., h);
        else if (eye == 1)                  // right screen
            glViewport (w/2., 0, w/2., h);
        
        glMatrixMode (GL_PROJECTION);
        glLoadIdentity ();
        [self glPerspective:90.0f Aspect:(GLfloat)(w/2.0f)/(GLfloat)(h) Near:.1f Far:10.0f];
        glMatrixMode (GL_MODELVIEW);
        
        glLoadIdentity();
        glPushMatrix();
        
        if(warping){
            glUseProgram(_program);
            // preset suggestions from http://www.mtbs3d.com/phpbb/viewtopic.php?f=140&t=17081
            const float Scale[2] = {0.1469278, 0.2350845};
            const float ScaleIn[2] = {2, 2.5};
            const float HmdWarpParam[4] = {1, 0.22, 0.24, 0};
            const float LeftLensCenter[2] = {0.2863248*2.0, 0.5};
            const float LeftScreenCenter[2] = {0.55, 0.5};
            const float RightLensCenter[2] = {(0.7136753-.5) * 2.0, 0.5};
            const float RightScreenCenter[2] = {0.45, 0.5};
            // apply shader uniforms
            glUniform2fv(uniforms[3], 1, Scale);
            glUniform2fv(uniforms[4], 1, ScaleIn);
            glUniform4fv(uniforms[5], 1, HmdWarpParam);
            if(eye == 0){
                glUniform2fv(uniforms[1], 1, LeftLensCenter);
                glUniform2fv(uniforms[2], 1, LeftScreenCenter);
            }
            else{
                glUniform2fv(uniforms[1], 1, RightLensCenter);
                glUniform2fv(uniforms[2], 1, RightScreenCenter);
            }
        }
        else{  // no warp, closer to fill screen
            glTranslatef(0, 0, -1.0);
        }
        // draw scene on a quad for each side
        glBindTexture(GL_TEXTURE_2D, textureId);
        [self drawQuad];
        glBindTexture(GL_TEXTURE_2D, 0);
        
        if(warping)
            glUseProgram(0);
        
        glPopMatrix();
    }
    glFlush();
}

-(void) drawQuad{
    glColor4f(1, 1, 1, 1);
    glBegin(GL_TRIANGLES);
    glNormal3f(0,0,1);
    glTexCoord2f(1,1);  glVertex3f(1,1,0);
    glTexCoord2f(0,1);  glVertex3f(-1,1,0);
    glTexCoord2f(0,0);  glVertex3f(-1,-1,0);
    glTexCoord2f(0,0);  glVertex3f(-1,-1,0);
    glTexCoord2f(1,0);  glVertex3f(1,-1,0);
    glTexCoord2f(1,1);  glVertex3f(1,1,0);
    glEnd();
    glBindTexture(GL_TEXTURE_2D, 0);
}

#pragma mark- Shaders
- (BOOL)loadShaders{
    
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    // Create shader program.
    _program = glCreateProgram();
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"BarrelWarp" ofType:@"vs"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"BarrelWarp" ofType:@"fs"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return NO;
    }
    // Get uniform locations.
    uniforms[0] = glGetUniformLocation(_program, "Texture");
    uniforms[1] = glGetUniformLocation(_program, "LensCenter");
    uniforms[2] = glGetUniformLocation(_program, "ScreenCenter");
    uniforms[3] = glGetUniformLocation(_program, "Scale");
    uniforms[4] = glGetUniformLocation(_program, "ScaleIn");
    uniforms[5] = glGetUniformLocation(_program, "HmdWarpParam");
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    // success, enable warping
    warping = true;
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    GLint status;
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog{
    GLint status;
    glLinkProgram(prog);
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

#pragma mark- OpenGL

// FBO tutorial: http://www.songho.ca/opengl/gl_fbo.html

-(void) createRenderTarget{
    
    glDeleteBuffers(1, &(fboId));
    glDeleteBuffers(1, &(rboId));
    
    fboId = rboId = textureId = 0;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, TEXTURE_WIDTH, TEXTURE_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glGenFramebuffers(1, &fboId);
    glBindFramebuffer(GL_FRAMEBUFFER, fboId);  //Once a FBO is bound, all OpenGL operations affect onto the current bound framebuffer object.
    glGenRenderbuffers(1, &rboId);
    glBindRenderbuffer(GL_RENDERBUFFER, rboId);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, TEXTURE_WIDTH, TEXTURE_HEIGHT);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureId, 0);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboId);
    
//    NSLog(@"SUCCESS ?: (0/1): %d: %d", GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus(GL_FRAMEBUFFER), glCheckFramebufferStatus(GL_FRAMEBUFFER));
}

// replacement for gluPerspective from NEHE
-(void) glPerspective:(GLdouble)fovY Aspect:(GLdouble)aspect Near:(GLdouble)zNear Far:(GLdouble) zFar{
    const GLdouble pi = 3.14159265359;
    GLdouble fW, fH;
    fH = tan(fovY/360.*pi) * zNear;
    fW = fH * aspect;
    glFrustum(-fW, fW, -fH, fH, zNear, zFar);
}

#pragma mark- User Input

-(void)mouseMoved:(NSEvent *)theEvent{
    [super mouseMoved:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent{
    [super mouseDragged:theEvent];
    if(mouseRotationOn){
        mouseRotation.x += [theEvent deltaX];
        mouseRotation.y += [theEvent deltaY];
    }
}

-(void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    mouseRotationOn = true;
}

-(void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
    mouseRotationOn = false;
}

-(void)keyUp:(NSEvent *)theEvent{
    if([theEvent keyCode] == 126) // up arrow
        keyboardArrows[UP] = false;
    else if([theEvent keyCode] == 125) // down arrow
        keyboardArrows[DOWN] = false;
    else if([theEvent keyCode] == 124) // right arrow
        keyboardArrows[RIGHT] = false;
    else if([theEvent keyCode] == 123) // left arrow
        keyboardArrows[LEFT] = false;
}
-(void)keyDown:(NSEvent *)theEvent
{
    NSString *characters = [theEvent characters];
    if([theEvent keyCode] == 53 && isFullscreen)
        [self toggleFullscreen];
    if([theEvent keyCode] == 126) // up arrow
        keyboardArrows[UP] = true;
    else if([theEvent keyCode] == 125) // down arrow
        keyboardArrows[DOWN] = true;
    else if([theEvent keyCode] == 124) // right arrow
        keyboardArrows[RIGHT] = true;
    else if([theEvent keyCode] == 123) // left arrow
        keyboardArrows[LEFT] = true;
    else if ([characters length]) {
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

- (BOOL)acceptsFirstResponder{
    return YES;
}
- (BOOL)becomeFirstResponder{
    return YES;
}

@end
