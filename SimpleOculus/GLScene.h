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
#import "Texture.h"

class GLScene
{
public:
    virtual void init();
    virtual void update();
    virtual void render();
    
    float orientation[16];  // orientation matrix
    
private:
    void draw_triangles();
    void drawPanorama();
    void drawSquares();
    
    Texture *texture;
	GLuint textureName;
};

#endif /* defined(__SimpleOculus__GLScene__) */
