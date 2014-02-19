# Simple Oculus
#### skeleton project for Mac OS X native Oculus Rift

![ScreenShot](https://raw.github.com/robbykraft/SimpleOculus/master/SimpleOculus/screenShot.jpg)

__features:__

* sensor orientation
* barrel warp
* keyboard:
`F` full screen `+` `-` change virtual interpupillary distance `△` `▽` `◁` `▷` walk around
* mouse: click to activate mouse look

###still in development

__BETA -__ Build and link LibOVR from scratch, see notes below.

__ALPHA -__ Rendering is on its way now but still much work to be done, for instance, warping is not calibrated, alternative aspect ratios are ignored, IPD isn't dynamically calculated.

------
### plug in your own scene

This project is setup to accept an OpenGL C++ / Objective-C scene (`Scene.h + Scene.cpp/mm`)

It’s only setup for head rotation, no translation (walking).

The sample environment is an immersion in an equirectangular panorama. I realized after the fact this doesn’t make a good demo. No walking is allowed, on top of that the edge warping is too steep. (Photo- Peter Gawthrop, flicker: gawthrop). Gonna change this soon.

------

> # Notes for building LibOVR in Xcode:

> ### from a blank Cocoa project:

> Drag LibOVR into Xcode Project, uncheck all “Add to Target”

>  

> Linked Frameworks and Libraries:

> * libovr.a (LibOVR/Lib/MacOS/Debug)

> * IOKit.framework

> ![Libraries](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/Libraries.png)

>  

> Architectures

> * Architectures : 64-bit Intel (x86_64)

> ![Architectures](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/Architectures.png)

>  

> Apple LLVM 5.0 - Language - C++

> * C++ Standard Library : libstdc++ (GNU C++ standard library)

> * Enable C++ Exceptions : No

> * Enable C++ Runtime Types : No

> ![LLVM](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/LLVMLanguage.png)

>  

> Search Paths

> * Header Search Paths : LibOVR/Src, LibOVR/Include
> * Library Search Paths :
> * - Debug : LibOVR/Lib/MacOS/Debug
> * - Release : LibOVR/Lib/MacOS/Release

> ![SearchPath](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/SearchPathsHeader.png)

> ![SearchPath](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/SearchPathsLibrary.png)

------

> Any classes which include OVR.h, and the classes which include THOSE classes, must be named *.mm, or must be marked as Objective-C++ source

> ![sample](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/Objective-C++.png)

------

> For reference: this is the example’s folder location

> ![Finder](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/Finder.png)

------



> ### Test it

> edit `main.mm`:


```
#import <Cocoa/Cocoa.h>
#include "OVR.h”

using namespace OVR;

int main(int argc, const char * argv[])
{
    System::Init();
    return NSApplicationMain(argc, argv);
}
```


> If this builds, you should be on your way!
