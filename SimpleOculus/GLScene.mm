//
//  GLScene.cpp
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#include "GLScene.h"
#import <OpenGL/glu.h>

void GLScene::init(){
    textureName = 0;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"outside" ofType:@"jpg"];
    texture = [[Texture alloc] initWithPath:path];
    textureName = [texture textureName];
}

void GLScene::update(){
    
}

void GLScene::render(){
    drawPanorama();
}

void GLScene::draw_triangles(){
    glColor3f(0.0f, 0.35f, 0.85f);
    
    glBegin(GL_TRIANGLES);
    glVertex3f( -1.0,  1.0, 0.0);
    glVertex3f( -1.0, -1.0, 0.0);
    glVertex3f(  1.0, -1.0 ,0.0);
    glColor3f(0.0f, 0.85f, 0.35f);
    glVertex3f(  1.0,  1.0, 0.0);
    glVertex3f( -1.0, -1.0, 0.0);
    glVertex3f(  1.0, -1.0 ,0.0);
    glEnd();
}

void GLScene::drawSquares(){
    glBegin(GL_QUADS);                          // Begin Drawing A Single Quad
    glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, 0.0f);
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, 0.0f);
    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, 0.0f);
    glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, 0.0f);
    glEnd();                                // Done Drawing The Textured Quad
}

void GLScene::drawPanorama(){
    
    GLUquadric *quadric = NULL;
    static GLfloat radius = 1.25;
    
	glEnable(GL_TEXTURE_2D);
    glClear(GL_DEPTH_BUFFER_BIT);
    
	glBindTexture(GL_TEXTURE_2D, textureName);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
    glPushMatrix();
    glLoadIdentity();
    
//    glMultMatrixf(orientation);
//    glRotatef(-90, 1.0, 0.0, 0.0);
    
	quadric = gluNewQuadric();
	
	gluQuadricTexture(quadric, GL_TRUE);
	gluSphere(quadric, radius, 48, 24);
	gluDeleteQuadric(quadric);
	quadric = NULL;
    glPopMatrix();
    
	glBindTexture(GL_TEXTURE_2D, 0);
}
