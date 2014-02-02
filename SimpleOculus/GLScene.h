//
//  GLScene.h
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#ifndef __SimpleOculus__GLScene__
#define __SimpleOculus__GLScene__

#include <iostream>

class GLScene
{
public:
    virtual void init() = 0;
    virtual void render() = 0;
    virtual void update() = 0;
protected:
    void clear(float r=0, float g=0, float b=0, float a=1, bool depth=true);
    void flush();
};

#endif /* defined(__SimpleOculus__GLGLScene__) */
