//
//  ObjectiveZip.m
//  Objective-Zip
//
//  Created by Antoine Cœur on 10/01/12.
//  Copyright (c) 2012 Coeur. All rights reserved.
//

#import "ObjectiveZip.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"

@implementation ObjectiveZip
@synthesize zipThread, handlerSelector;

- (void) startUnzip {
    zipThread = [[NSThread alloc] initWithTarget:self selector:@selector(unzipFrom:to:) object:nil];
    [zipThread start];
}

- (void) closeUnzip {
	[zipThread cancel];
	[zipThread release];
    zipThread = nil;
}

- (void) logZip:(NSString *)log {
	NSLog(@"%@", log);
}

- (void) unzipFrom:(NSString *)sourceFile to:(NSString *)destinationPath {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (![[NSThread currentThread] isCancelled]) { 
        [self performSelectorOnMainThread:@selector(logZip:) withObject:@"Unpacking started..." waitUntilDone:YES];
    }
    
    ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:sourceFile mode:ZipFileModeUnzip];
    [unzipFile goToFirstFileInZip];
    
    for (int i = 0; i < [unzipFile numFilesInZip]; i++) {
        FileInZipInfo *info = [unzipFile getCurrentFileInZipInfo];
        if (![[NSThread currentThread] isCancelled]) { 
            [self performSelectorOnMainThread:@selector(logZip:) withObject:[NSString stringWithFormat:@"Unpacking file '%@'", info.name] waitUntilDone:YES];
        }
        
        ZipReadStream *read = [unzipFile readCurrentFileInZip];
        
        NSData *data = [read readDataOfLength:info.length];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@", destinationPath, info.name] atomically:NO];  
        [read finishedReading];
        
        [unzipFile goToNextFileInZip];
        
        if (![[NSThread currentThread] isCancelled]) { 
            [self performSelectorOnMainThread:@selector(logZip:) withObject:[NSString stringWithFormat:@"Unpacked file '%@'", info.name] waitUntilDone:YES];
        }
    }
    
    [unzipFile close];
    [unzipFile release];
    
    if (![[NSThread currentThread] isCancelled])  {
        [self performSelectorOnMainThread:@selector(logZip:) withObject:@"...Unpacking completed." waitUntilDone:YES];
        if (handlerSelector != nil) {
            if ([self respondsToSelector:handlerSelector]) {
                [self performSelectorOnMainThread:handlerSelector withObject:nil waitUntilDone:YES];
            }
        }
        [self closeUnzip];
    }
    [pool drain];
}

- (void) zipFrom:(NSString *)sourcePath to:(NSString *)destinationFile {
	ZipFile *zipFile = [[ZipFile alloc] initWithFileName:destinationFile mode:ZipFileModeCreate];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:nil]; 
    for (NSString *fileName in array) {
        BOOL isDirectory = NO;
        BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", sourcePath, fileName] isDirectory:&isDirectory];
        
        if (isDirectory && fileExistsAtPath) {
            NSArray *subDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", sourcePath, fileName] error:nil];
            for (NSString *subFileName in subDir) {
                ZipWriteStream *writeStream =  [zipFile writeFileInZipWithName:[NSString stringWithFormat:@"%@/%@", fileName, subFileName] compressionLevel:ZipCompressionLevelBest];
                NSString *location = [NSString stringWithFormat:@"%@/%@/%@", sourcePath, fileName, subFileName];
                NSData *data = [[[NSData alloc] initWithContentsOfFile:location] autorelease];
                [writeStream writeData:data];
                [writeStream finishedWriting];
            }
        }
        else if (!isDirectory && fileExistsAtPath) {
            ZipWriteStream *writeStream =  [zipFile writeFileInZipWithName:[NSString stringWithFormat:@"%@", fileName] compressionLevel:ZipCompressionLevelBest];
            NSString *location = [NSString stringWithFormat:@"%@/%@", sourcePath, fileName];
            NSData *data = [[[NSData alloc] initWithContentsOfFile:location] autorelease];
            [writeStream writeData:data];
            [writeStream finishedWriting];
        }
    }
    [zipFile close];
    [zipFile release];
}

@end
