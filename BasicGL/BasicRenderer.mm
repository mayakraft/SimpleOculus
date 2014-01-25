//
//  BasicRenderer.cpp
//  BasicGL
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#include "BasicRenderer.h"

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
    draw_triangles();
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