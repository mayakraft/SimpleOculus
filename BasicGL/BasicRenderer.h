//
//  BasicRenderer.h
//  BasicGL
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#ifndef __BasicGL__BasicRenderer__
#define __BasicGL__BasicRenderer__

#include <iostream>
#include "GLRenderer.h"

class BasicRenderer : GLRenderer
{
public:
    virtual void init();
    virtual void update();
    virtual void render();
    
private:
    float shift;
    float shift_direction;
    void draw_triangles();
};

#endif /* defined(__BasicGL__BasicRenderer__) */
