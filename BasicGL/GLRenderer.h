//
//  GLRenderer.h
//  BasicGL
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#ifndef __BasicGL__GLRenderer__
#define __BasicGL__GLRenderer__

#include <iostream>

class GLRenderer
{
public:
    virtual void init() = 0;
    virtual void render() = 0;
    virtual void update() = 0;
protected:
    void clear(float r=0, float g=0, float b=0, float a=1, bool depth=true);
    void flush();
};

#endif /* defined(__BasicGL__GLRenderer__) */
