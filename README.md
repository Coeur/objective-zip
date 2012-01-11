Coeur/objective-zip is a fork from AgileBits/objective-zip
The following changes were made:
* Compiler warnings reported by Xcode 4.2 Analyze were fixed.
* Added a simple wrapper class ObjectiveZip to zip and unzip folders
To be implemented soon...:
* Passwords

AgileBits/objective-zip is a fork from [objective-zip library](http://code.google.com/p/objective-zip/) developed by [Flying Dolphin Studio](http://www.flyingdolphinstudio.com).
The following changes were made:
* Test application was moved into its own folder. Simply add MiniZip and Objective-Zip folders to your project.
* ZLib source code was removed and replaced with the shared libz.dylib library available on both Mac OS X and iOS.
* Weak encryption code in MiniZip library was explicitly disabled by removing crypt.h and defining NOCRYPT and NOUNCRYPT.
* Compiler warnings reported by LLVM 2.0 compiler (Xcode 4) were fixed.


Import
	#import "ObjectiveZip.h"

Zip Usage
	ObjectiveZip *zipper = [ObjectiveZip new];
	[zipper unzipFrom:sourceFile to:destinationPath];
	[zipper release];

UnZip Usage
	ObjectiveZip *zipper = [ObjectiveZip new];
	[zipper unzipFrom:sourcePath to:destinationFile];
	[zipper release];


Code license
* Objective-Zip: [New BSD License](http://www.opensource.org/licenses/bsd-license.php)
* MiniZip: [See MiniZip website](http://www.winimage.com/zLibDll/minizip.html)
