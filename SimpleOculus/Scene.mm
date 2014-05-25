//
//  Scene.cpp
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#include "Scene.h"
#import <OpenGL/glu.h>

void Scene::init(){
    textureName = 0;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Tycho" ofType:@"jpg"];
    texture = [[Texture alloc] initWithPath:path];
    textureName = [texture textureName];
}

void Scene::update(){
    
}

void Scene::lighting(){
    static GLfloat spot_direction[] = { 0.0, -1.0, 0.0 };
    static GLfloat light_ambient[] = { 0.0, 0.0, 0.0, 1.0 };
    static GLfloat light_diffuse[] = { 1.0, 1.0, 1.0, 1.0 };
    static GLfloat light_specular[] = { 1.0, 1.0, 1.0, 1.0 };
    static GLfloat light_position[] = { 0.0, 1.0, 0.0, 1.0 };
    
    glEnable(GL_LIGHT0);
    glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
    glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
    glLightfv(GL_LIGHT0, GL_POSITION, light_position);
    
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 75.0);
    glLightf(GL_LIGHT0, GL_SPOT_EXPONENT, 2.0);
    glLightfv(GL_LIGHT0,GL_SPOT_DIRECTION, spot_direction);
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, light_ambient);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, light_diffuse);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, light_specular);
}

void Scene::render(float translationX, float translationZ){
    static GLfloat material1[4] = { 1.0, 1.0, 1.0, 1.0 };
    static GLfloat material2[4] = { 0.1, 0.1, 0.1, 1.0 };

    drawPanorama();

    glEnable(GL_LIGHTING);
    lighting();
    
    
    glPushMatrix();
    glTranslatef(translationX, 0, translationZ);  // move the world around the person
    
    // infinitely scrolling chess board
    int XOffset = translationX;
    int ZOffset = translationZ;
    glTranslatef(0, -1, 0); // move floor down
    for(int i = -8; i <= 8; i++){
        for(int j = -8; j <= 8; j++){
            float b = fabsf(((i+j+XOffset+ZOffset)%2));
            if(b) glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, material1);
            else  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, material2);
            drawRect(i-XOffset, j-ZOffset, 1, 1);
        }
    }
    glPopMatrix();
    
    glDisable(GL_LIGHTING);
}

void Scene::drawPanorama(){
    glPushMatrix();
    GLUquadric *quadric = NULL;
    static GLfloat radius = 500.0f;
    
	glEnable(GL_TEXTURE_2D);
    glClear(GL_DEPTH_BUFFER_BIT);
    
	glBindTexture(GL_TEXTURE_2D, textureName);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
	quadric = gluNewQuadric();
	
	gluQuadricTexture(quadric, GL_TRUE);
    glRotatef(-90, 1.0, 0.0, 0.0);  // textured sphere is on its side
	gluSphere(quadric, radius, 48, 24);
	gluDeleteQuadric(quadric);
	quadric = NULL;
    
	glBindTexture(GL_TEXTURE_2D, 0);
    glPopMatrix();
}

void Scene::drawRect(float x, float y, float width, float height){
    static const GLfloat _unit_square[] = {
        -0.5f, 0.0f, 0.5f,
        0.5f, 0.0f, 0.5f,
        -0.5f, 0.0f, -0.5f,
        0.5f, 0.0f, -0.5f
    };
    static const GLfloat _unit_square_normals[] = {
        0.0f, 0.1f, 0.0f,
        0.0f, 0.1f, 0.0f,
        0.0f, 0.1f, 0.0f,
        0.0f, 0.1f, 0.0f
    };
    glPushMatrix();
    glTranslatef(x, 0.0, y);
    glScalef(width, 1.0, height);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, _unit_square);
    glNormalPointer(GL_FLOAT, 0, _unit_square_normals);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glPopMatrix();
}

