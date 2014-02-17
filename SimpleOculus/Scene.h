//
//  Scene.h
//  SimpleOculus
//
//  Created by Robby Kraft on 1/25/14.
//  Copyright (c) 2014 Robby Kraft. All rights reserved.
//

#ifndef __SimpleOculus__Scene__
#define __SimpleOculus__Scene__

#include <iostream>
#import "Texture.h"

class Scene
{
public:
    void init();
    void update();
    void render();
    
private:
    void drawPanorama();
    
    Texture *texture;
	GLuint textureName;
};

#endif /* defined(__SimpleOculus__Scene__) */
