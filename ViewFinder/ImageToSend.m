//
//  ImageToSend.m
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 07.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import "ImageToSend.h"

@implementation ImageToSend

/**
 Initialize with fileName.
 */
- (id)initWith:(NSString*) fileName {
    self = [super init];
    if (self) {
        self.fileName = fileName;
    }

    return self;
}

/**
 Initialize with data
 */
- (id)initWithData:(NSData*) imageData {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fileName = [NSString stringWithFormat:@"%.0f.jpg", [NSDate date].timeIntervalSince1970];
        _fileName = fileName;
        _filePath = [documentsPath stringByAppendingPathComponent:fileName];

        [imageData writeToFile:_filePath atomically:YES];
    }
    
    return self;
}

/**
 Get file data based on fileName private param.
 
 - returns: Base64Encoded string with contents of file fileName.
 */
- (NSString*) getFileData {
    if (!_fileName || _fileName.length == 0) {
        return nil;
    }

    if (!_filePath || _filePath.length == 0) {
        return nil;
    }

    NSData *data = [NSData dataWithContentsOfFile:_filePath];
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
