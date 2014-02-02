//
//  BasicRenderer.cpp
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#include "BasicRenderer.h"
#include "Texture.h"
#import <OpenGL/glu.h>

void BasicRenderer::init(){
    shift_direction = 1;
    shift = 0.0f;
}

void BasicRenderer::update(){
#define SHIFT_MOVE 0.005f
    if(shift_direction == 1){
        shift += SHIFT_MOVE;
        if(shift >= 1.0)
            shift_direction = 0;
    }
    else{
        shift -= SHIFT_MOVE;
        if(shift <= 0.0)
            shift_direction = 1;
    }
}

void BasicRenderer::render(){
    clear();
    drawSphere();
    flush();
}

void BasicRenderer::draw_triangles(){
    glColor3f(0.0f, 0.35f, 0.85f);
    
    glBegin(GL_TRIANGLES);
    glVertex3f( -1.0+shift,  1.0, 0.0);
    glVertex3f( -1.0, -1.0, 0.0);
    glVertex3f(  1.0, -1.0 ,0.0);
    glColor3f(0.0f, 0.85f, 0.35f);
    glVertex3f(  1.0-shift,  1.0, 0.0);
    glVertex3f( -1.0, -1.0, 0.0);
    glVertex3f(  1.0, -1.0 ,0.0);
    glEnd();
}

void BasicRenderer::drawSphere(){
	Texture *texture;
	GLuint textureName = 0;
    
    GLUquadric *quadric = NULL;
    static GLfloat radius = 1.25;
	glEnable(GL_TEXTURE_2D);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glLoadIdentity();
    
	if (!textureName) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"outside" ofType:@"jpg"];
		texture = [[Texture alloc] initWithPath:path];
		textureName = [texture textureName];
	}
    
	glBindTexture(GL_TEXTURE_2D, textureName);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
    glPushMatrix();
	
    glLoadIdentity();



//    glMultMatrixf(matrix);
//         glRotatef(90, 0.0, 1.0, 0.0);
//    glRotatef(-90.0, 1.0, 0.0, 0.0);
    
	quadric = gluNewQuadric();
    //	if (wireframe)
    //		gluQuadricDrawStyle(quadric, GLU_LINE);
	
	gluQuadricTexture(quadric, GL_TRUE);
    //	glMaterialfv(GL_FRONT, GL_AMBIENT, materialAmbient);
    //	glMaterialfv(GL_FRONT, GL_DIFFUSE, materialDiffuse);
    //	glRotatef(rollAngle, 1.0, 0.0, 0.0);
    //	glRotatef(-23.45, 0.0, 0.0, 1.0); // Earth's axial tilt is 23.45 degrees from the plane of the ecliptic
    //	glRotatef(animationPhase * 360.0, 0.0, 1.0, 0.0);
	gluSphere(quadric, radius, 48, 24);
	gluDeleteQuadric(quadric);
	quadric = NULL;
    glPopMatrix();
    
	glBindTexture(GL_TEXTURE_2D, 0);
}