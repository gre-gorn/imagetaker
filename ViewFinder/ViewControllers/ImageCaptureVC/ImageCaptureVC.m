//
//  ImageCaptureVC.m
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 07.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import "ImageCaptureVC.h"
#import "ImageUploadVC.h"
#import "FadeInAnimation.h"

@implementation ImageCaptureVC

- (void)hideZoomControls {
    zoomLevelLabel.hidden = YES;
    zoomLevelSlider.hidden = YES;
}

- (void)showZoomControls {
    zoomLevelLabel.text = [NSString stringWithFormat:@"%.0fx", imageCaptureDevice.videoZoomFactor];
    zoomLevelLabel.hidden = NO;
    zoomLevelSlider.minimumValue = 0.0f;
    zoomLevelSlider.maximumValue = 1.0f;
    zoomLevelSlider.value = imageCaptureDevice.videoZoomFactor / imageCaptureDevice.activeFormat.videoMaxZoomFactor * zoomLevelSlider.maximumValue;
    zoomLevelSlider.hidden = NO;
}

- (IBAction)onSliderValueChanged:(id)sender {
    if ([imageCaptureDevice lockForConfiguration:nil]) {
        //set current zoom
        CGFloat desiredZoomFactor = atan(zoomLevelSlider.value) / M_PI * imageCaptureDevice.activeFormat.videoMaxZoomFactor;
        NSLog(@"desiredZoomFactor:%f", desiredZoomFactor);
        [imageCaptureDevice rampToVideoZoomFactor:round(MAX(1.0, MIN(desiredZoomFactor, imageCaptureDevice.activeFormat.videoMaxZoomFactor))) withRate:fabs(desiredZoomFactor - imageCaptureDevice.videoZoomFactor)];
        zoomLevelLabel.text = [NSString stringWithFormat:@"%.0fx", [imageCaptureDevice videoZoomFactor]];
        [imageCaptureDevice unlockForConfiguration];
    }
}

- (IBAction)flashOnOff:(id)sender {
    UIButton *flashOnOff = sender;
    flashOnOff.selected = !flashOnOff.selected;
}

- (IBAction)uploadImage:(id)sender {
    if (imageData) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        if (storyboard) {
            ImageUploadVC *imageUploadVC = [storyboard instantiateViewControllerWithIdentifier:@"ImageUploadVC"];
            if (imageUploadVC) {
                imageUploadVC.imageData = imageData;
                [self.navigationController pushViewController:imageUploadVC animated:YES];
            }
        }
    } else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Info" message:@"Before upload take a photo please." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction) takePicture:(id)sender {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        AVCapturePhotoSettings *captureSettings = [AVCapturePhotoSettings photoSettings];
        [captureSettings setHighResolutionPhotoEnabled:YES];
        if ([imageCaptureDevice lockForConfiguration:nil]) {
            if ([imageCaptureDevice hasFlash]) {
                flashStatusButton.selected ? [captureSettings setFlashMode:AVCaptureFlashModeOn] : [imageCaptureDevice setFlashMode:AVCaptureFlashModeOff];
            }
            [imageCaptureDevice unlockForConfiguration];
        }
        AVCapturePhotoOutput *capturePhotoOutput = imageOutput;
        [capturePhotoOutput capturePhotoWithSettings:captureSettings delegate:self];
    } else {
        [(AVCaptureStillImageOutput*)imageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSLog(@"takePicture");
            imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            if (imageData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CALayer *layer = [[thumbnailImageView.layer sublayers] objectAtIndex:0];
                    [layer removeFromSuperlayer];
                    [thumbnailImageView setImage:[UIImage imageWithData:imageData]];
                });
            }
        }];
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate
-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
    }
    
    if (!CMSampleBufferIsValid(photoSampleBuffer)) {
        NSLog(@"sampleBuffer isn't valid.");
        return;
    }
    
    if( !CMSampleBufferDataIsReady(photoSampleBuffer) )
    {
        NSLog(@"sampleBuffer is not ready. Skipping sample." );
        return;
    }

    if (photoSampleBuffer) {
        imageData = nil;
        imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        if (imageData) {
            NSLog(@"takePicture");
            dispatch_async(dispatch_get_main_queue(), ^{
                CALayer *layer = [[thumbnailImageView.layer sublayers] objectAtIndex:0];
                [layer removeFromSuperlayer];
                [thumbnailImageView setImage:[UIImage imageWithData:imageData]];
            });
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    self.navigationController.delegate = self;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, 48, 64);
    gradient.colors = @[(id)[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0].CGColor, (id)[UIColor blackColor].CGColor];
    
    [thumbnailImageView.layer insertSublayer:gradient atIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
    imageData = nil;
}

- (void) viewDidLoad {
    [super viewDidLoad];

    takePhotoButton.layer.cornerRadius = 32.0f;
    takePhotoButton.layer.borderWidth = 2.0f;
    takePhotoButton.layer.borderColor = [UIColor whiteColor].CGColor;

    [self askForCameraPermissions];
    
    //prepare capture session with resolution set to the highest available for the device.
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    imageCaptureDevice = [self backCamera];
    
    NSError *error = nil;
    
    imageInput = [AVCaptureDeviceInput deviceInputWithDevice:imageCaptureDevice error:&error];
    
    if (!imageInput) {
        UIAlertController *controller = [[UIAlertController alloc] init];
        controller.title = NSLocalizedStringWithDefaultValue(@"Error", @"Error", [NSBundle mainBundle], @"Error", @"");
        controller.message = error.localizedDescription;
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];

        return;
    }
    
    NSLog(@"imageInput exists and is ready");

    if ([captureSession canAddInput:imageInput]) {
        [captureSession addInput:imageInput];
    }

    //Prepare output
    AVCapturePhotoSettings *captureSettings = [AVCapturePhotoSettings photoSettings];
    [captureSettings setHighResolutionPhotoEnabled:YES];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        imageOutput = [[AVCapturePhotoOutput alloc] init];
        [(AVCapturePhotoOutput*)imageOutput setHighResolutionCaptureEnabled:YES];
        [(AVCapturePhotoOutput*)imageOutput setPhotoSettingsForSceneMonitoring:captureSettings];
    } else {
        imageOutput = [[AVCaptureStillImageOutput alloc] init];
        [(AVCaptureStillImageOutput*)imageOutput setHighResolutionStillImageOutputEnabled:YES];
        [(AVCaptureStillImageOutput*)imageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
        captureConnection = [(AVCaptureStillImageOutput*)imageOutput connectionWithMediaType:AVMediaTypeVideo];
    }

    if ([captureSession canAddOutput:imageOutput]) {
        [captureSession addOutput:imageOutput];
    }

    //Create video preview layer and add it to the UI
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    captureVideoPreviewLayer.frame = previewView.bounds;
    
    [previewView.layer addSublayer:captureVideoPreviewLayer];
    
    [captureSession startRunning];

    flashStatusButton.hidden = ![imageCaptureDevice hasFlash];

    if ( [imageCaptureDevice lockForConfiguration:nil]) {
        //set continuous autofocus
        if ([imageCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
            [imageCaptureDevice setFocusPointOfInterest:autofocusPoint];
            [imageCaptureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //set max zoom
        NSLog(@"videoMaxZoomFactor:%f", [imageCaptureDevice activeFormat].videoMaxZoomFactor);
        [imageCaptureDevice setVideoZoomFactor:[imageCaptureDevice activeFormat].videoMaxZoomFactor];
        [imageCaptureDevice unlockForConfiguration];
    }

    if ([imageCaptureDevice videoZoomFactor] != 1.0f) {
        [self showZoomControls];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) askForCameraPermissions {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if(authStatus == AVAuthorizationStatusAuthorized) {
        NSLog(@"Granted access to %@", AVMediaTypeVideo);
        return;
    }

    if (authStatus == AVAuthorizationStatusNotDetermined) {
        NSLog(@"%@", @"Camera access not determined. Ask for permission.");
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                NSLog(@"Granted access to %@", AVMediaTypeVideo);
            } else {
                NSLog(@"Not granted access to %@", AVMediaTypeVideo);
            }
        }];
    }

    return;
}

- (AVCaptureDevice *) backCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }

    return nil;
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    if (fromVC == self && [toVC isKindOfClass:[ImageUploadVC class]]) {
        return [[FadeInAnimation alloc] init];
    }
    else {
        return nil;
    }
}

@end
