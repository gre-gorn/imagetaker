//
//  FadeInAnimation.m
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 09.03.2017.
//  Copyright © 2017 Softate. All rights reserved.
//

#import "ImageUploadVC.h"
#import "ImageCaptureVC.h"
#import "FadeInAnimation.h"

@implementation FadeInAnimation

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    ImageUploadVC *fromViewController = (ImageUploadVC*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ImageCaptureVC *toViewController = (ImageCaptureVC*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    // Setup the initial view states
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:duration animations:^{
        fromViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

@end
