//
//  ImageUploadVC.m
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 08.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import "ImageUploadVC.h"
#import "ImageCaptureVC.h"
#import "FadeOutAnimation.h"

@implementation ImageUploadVC

- (void) hideUploadProgress {
    uploadProgress.progress = 0.0f;
    uploadProgress.hidden = YES;
}

- (UIAlertController*) alertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    return alert;
}

- (void) onUploadFailed:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideUploadProgress];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[self alertWithTitle:@"Failure" message:message] animated:YES completion:^{
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleDone target:self action:@selector(executeUpload:)];
        }];
    });
}

- (void) onUploadSuccess:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideUploadProgress];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[self alertWithTitle:@"Message" message:message] animated:YES completion:^{
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleDone target:self action:@selector(executeUpload:)];
        }];
    });
}

- (void) onUploadProgress:(CGFloat)percent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [uploadProgress setProgress:percent / 100.0f animated:YES];
    });
}

- (void)executeUpload:(id)sender {
    uploadProgress.progress = 0.0f;
    uploadProgress.hidden = NO;
    if (!_network) {
        _network = [[Network alloc] init];
        _network.delegate = self;
    }
    if (![_network sendImageToServer: _imageToSend]) {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:[self alertWithTitle:@"Error" message:@"Can't start image upload."] animated:YES completion:nil];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setImageData:(NSData *)imageData {
    _imageData = [NSData dataWithData:imageData];
    _imageToSend = [[ImageToSend alloc] initWithData:imageData];
    _filePath = _imageToSend.filePath;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.delegate = self;
    
    if (self.imageData) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStyleDone target:self action:@selector(executeUpload:)];
        [imageView setImage:[UIImage imageWithData:_imageData]];
        self.navigationItem.title = _imageToSend.fileName;
    }

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }

    self.navigationItem.rightBarButtonItem = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_imageToSend.filePath error:NULL];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {

    if (fromVC == self && [toVC isKindOfClass:[ImageCaptureVC class]]) {
        return [[FadeOutAnimation alloc] init];
    } else {
        return nil;
    }
}

@end
