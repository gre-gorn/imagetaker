//
//  ImageCaptureVC.h
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 07.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageCaptureVC : UIViewController <AVCapturePhotoCaptureDelegate,  UIAlertViewDelegate, UINavigationControllerDelegate> {
    IBOutlet UIView *previewView;
    IBOutlet UIView *controlsView;
    IBOutlet UIImageView *thumbnailImageView;
    IBOutlet UIButton *takePhotoButton;
    IBOutlet UIButton *flashStatusButton;
    IBOutlet UILabel *zoomLevelLabel;
    IBOutlet UISlider *zoomLevelSlider;
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *imageInput;
    AVCaptureDevice *imageCaptureDevice;
    id imageOutput;
    AVCaptureConnection *captureConnection;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    NSData *imageData;
}

@end

