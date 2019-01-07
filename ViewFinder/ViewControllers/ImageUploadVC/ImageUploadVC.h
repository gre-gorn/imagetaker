//
//  ImageUploadVC.h
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 08.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "Network.h"

@interface ImageUploadVC : UIViewController<NetworkDelegate, UINavigationControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIImageView *imageView;
    IBOutlet UIProgressView *uploadProgress;
    NSData *_imageData;
    ImageToSend *_imageToSend;
    NSString *_filePath;
    Network *_network;
}

@property (nonatomic, readwrite, setter=setImageData:) NSData *imageData;

@end
