//
//  Network.h
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 08.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ImageToSend.h"

#define kNetwork_BackgroundSessionConfigurationIdentifier @"BackgroundSessionConfigurationIdentifier"

//TODO: put here url to receive the uploading image
#define kEndpoint_PostImage @"http://google.com"

/*
 * Messages related to the operation of a specific task.
 */
@protocol NetworkDelegate <NSObject>
@optional

- (void) onUploadProgress:(CGFloat)percent;
- (void) onUploadSuccess:(NSString*)message;
- (void) onUploadFailed:(NSString*)message;

@end

@interface Network : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate> {
    NSMutableURLRequest *_request;
    NSURLSession *_urlSession;
    NSURL *_postImageURL;
    NSURLSessionDataTask *_task;
    NSMutableData *_responseData;
    id _delegate;
}

- (BOOL) sendImageToServer:(ImageToSend*) file;

@property (readwrite) id<NetworkDelegate> delegate;

@end
