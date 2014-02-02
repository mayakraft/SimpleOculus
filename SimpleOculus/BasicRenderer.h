//
//  BasicRenderer.h
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#ifndef __SimpleOculus__BasicRenderer__
#define __SimpleOculus__BasicRenderer__

#include <iostream>
#include "GLRenderer.h"

class BasicRenderer : GLRenderer
{
public:
    virtual void init();
    virtual void update();
    virtual void render();
    
    float matrix[16];
    
private:
    float shift;
    float shift_direction;
    void draw_triangles();
    void drawSphere();
};

#endif /* defined(__SimpleOculus__BasicRenderer__) */
