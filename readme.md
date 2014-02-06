# Simple Oculus
#### skeleton framework for native Xcode Oculus Rift development

__features:__

`F` for full screen `+` `-` to change virtual interpupillary distance

__use:__

Presently, this is a resource for learning to build and link LibOVR from scratch. Rendering is only in beginning stages of implementation.

The goal is to have as few lines of code as is practical.

------

### Notes for getting LibOVR to build in Xcode:

###### from a blank Cocoa project:

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

> ![Finder](https://raw.github.com/robbykraft/SimpleOculus/master/tutorial/Finder.png)

> * for reference: this is the example’s folder location

------



### Test it

edit `main.mm`:

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

If this builds, everything should be working!

------
### Sample scene

The sample environment is an equirectangular panorama. Traveling is restricted since the projection is a flat image. This isn’t really a good demo because of that, it should probably change soon.

Photo by Peter Gawthrop (flicker: gawthrop)

###### TODO:

* implement HMD warping
* expose more of the Oculus SDK
* build a scene that will allow for translation