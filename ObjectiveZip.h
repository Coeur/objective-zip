//
//  ObjectiveZip.h
//  Objective-Zip
//
//  Created by Antoine Cœur on 10/01/12.
//  Copyright (c) 2012 Coeur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectiveZip : NSObject
{
}
@property (retain) NSThread * zipThread;
@property (assign) SEL handlerSelector;

- (void) unzipFrom:(NSString *)sourceFile to:(NSString *)destinationPath;
- (void) zipFrom:(NSString *)sourcePath to:(NSString *)destinationFile;
@end
