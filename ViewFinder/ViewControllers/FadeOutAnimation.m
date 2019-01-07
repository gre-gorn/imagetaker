//
//  FadeOutAnimation.m
//  ViewFinder
//
//  Created by Grzegorz Górnisiewicz on 10.03.2017.
//  Copyright © 2017 Anoto. All rights reserved.
//

#import "FadeOutAnimation.h"

@implementation FadeOutAnimation

- (void)perform {
    [UIView animateWithDuration:0.4 animations:^{
        self.sourceViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.sourceViewController.navigationController popViewControllerAnimated:NO];
    }];
}

@end
