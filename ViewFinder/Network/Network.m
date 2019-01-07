//
//  Network.m
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 08.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import "Network.h"

@implementation Network

/**
 Initialize object with default endpoint.
 */
- (id) init {
    self  = [super init];
    
    if (self) {
        _postImageURL = [NSURL URLWithString:kEndpoint_PostImage];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        _request = [NSMutableURLRequest requestWithURL:_postImageURL];
        _request.timeoutInterval = 60.0;
    }
    
    return self;
}

/**
 Upload image to server.
 */
- (BOOL) sendImageToServer:(ImageToSend*) file {
    if (!_urlSession) {
        return NO;
    }

    NSDictionary *jsonObject = @{ @"FileName": file.fileName, @"FileData": file.fileData };
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options: 0
                                                         error:&error];
    
    if (!jsonData) {
        return NO;
    }

    [_request setHTTPBody:jsonData];
    [_request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [_request setHTTPMethod:@"POST"];
   
    if (_task) {
        [_task suspend];
        [_task cancel];
    }

    _task = [_urlSession dataTaskWithRequest:_request];   
    [_task resume];
    
    NSDate *methodStart = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *stringFromDate = [formatter stringFromDate:methodStart];
    NSLog(@"startTime = %@", stringFromDate);
    
    return YES;
}

- (void)URLSession:(NSURLSession *)session
                task:(NSURLSessionTask *)task
                didSendBodyData:(int64_t)bytesSent
                totalBytesSent:(int64_t)totalBytesSent
                totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"percent:%.2f", (CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend * 100.0f);
    [_delegate onUploadProgress:(CGFloat)totalBytesSent / (CGFloat)totalBytesExpectedToSend * 100.0f];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    if (!_responseData) {
        _responseData = [NSMutableData dataWithData:data];
    } else {
        [_responseData appendData:data];
    }
}

- (void)URLSession:(NSURLSession *)session
                task:(NSURLSessionTask *)task
                didCompleteWithError:(NSError *)error
{
    NSString *message = @"";
    if (!error) {
        NSDate *finish = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
        NSString *stringFromDate = [formatter stringFromDate:finish];
        NSLog(@"finished = %@", stringFromDate);
        NSLog(@"file transfered!");
        if (_responseData) {
            NSString *myString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", myString);
            NSError *jsonError;
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableContainers error:&jsonError];
            if (!jsonError) {
                [_delegate onUploadSuccess:jsonObject[@"Message"]];
            } else {
                [_delegate onUploadFailed:error.localizedDescription];
            }
        } else {
            [_delegate onUploadFailed:@"Response message is missing."];
        }
    } else {
        //400, 404 or 500 on error
        switch ([(NSHTTPURLResponse*)task.response statusCode]) {
            case 400:
                message = @"Bad request.";
                break;
            case 404:
                message = @"The requested URL was not found on this server.";
                break;
            case 500:
                message = @"Internal Server Error.";
                break;
            default:
                message = error.localizedDescription;
                break;
        }
        [_delegate onUploadFailed:message];
    }

    //clear cached response
    _responseData = nil;
}

@end
