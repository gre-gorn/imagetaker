//
//  ImageToSend.h
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 07.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageToSend : NSObject {
    NSString *_fileName;
    NSString *_filePath;
}

- (id)initWith:(NSString*) fileName;
- (id)initWithData:(NSData*) imageData;

@property (readwrite) NSString *fileName;
@property (readwrite) NSString *filePath;
@property (nonatomic, readonly, getter=getFileData) NSString *fileData;

@end
