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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"outside" ofType:@"jpg"];
    texture = [[Texture alloc] initWithPath:path];
    textureName = [texture textureName];
}

void Scene::update(){
    
}

void Scene::render(){
    drawPanorama();
}

void Scene::drawPanorama(){
    
    GLUquadric *quadric = NULL;
    static GLfloat radius = 1.0f;
    
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
}
