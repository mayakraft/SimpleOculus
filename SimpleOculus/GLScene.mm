//
//  GLScene.cpp
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#include "GLScene.h"

void GLScene::clear(float r, float g, float b, float a, bool depth){
    glClearColor(r, g, b, a);
    if(depth)
        glClear(GL_COLOR_BUFFER_BIT);
}

void GLScene::flush(){
    glFlush();
}