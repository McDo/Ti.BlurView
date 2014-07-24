/**
 * benCoding.BlurView
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Edited by Do Lin. 07/24/14
 * mcdooooo@gmail.com
 */

#import "BencodingBlurGPUGrayscaleImageView.h"
#import "TiUtils.h"
#import "BencodingBlurModule.h"
#import "BXBGPUHelpers.h"

@implementation BencodingBlurGPUGrayscaleImageView

-(void)initializeState
{
    _debug = NO;
    _imageWait = 200;
	[super initializeState];
}

-(void) setDebug_:(id)value
{
    _debug = [TiUtils boolValue:value def:YES];
}

/*-(void) setBlurImageWait_:(id)value
{
    _imageWait = [TiUtils intValue:value def:200];
}*/


-(void)applyGrayscale:(UIImageView*) imageView {
    
    if( imageView.image == nil ) {
        
        if ( _debug ) {
            NSLog(@"[DEBUG] GPUBlurImageView : Still no image, giving up");
        }
        
    } else {
        
        BXBGPUHelpers *filterHelpers = [[BXBGPUHelpers alloc] initWithDetails:_debug];
        
        if(_debug){
            NSLog(@"[DEBUG] GPUBlurImageView: applying GPUImageGrayscaleFilter");
        }
        
        GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:imageView.image];
        
        GPUImageGrayscaleFilter *grayscaleFilter = [filterHelpers buildGrayscale];
        [imageSource addTarget:grayscaleFilter];
        [grayscaleFilter useNextFrameForImageCapture];
        [imageSource processImage];
        
        UIImage *outputImage = [grayscaleFilter imageFromCurrentFramebuffer];
        
        [imageView setImage:outputImage];
    }
    
}

-(void)setGrayscale_:(id)value {
    
    BOOL should = [TiUtils boolValue:value];
    
    if ( should ) {
        
        if( _debug ){
            NSLog(@"[DEBUG] GPUBlurImageView : Finding imageView");
        }
    
        UIImageView *imageView = [self valueForKey:@"imageView"];
    
        if ( nil == imageView ) {
            
            if( _debug ) {
                NSLog(@"[DEBUG] GPUBlurImageView : Not found, giving up");
            }
            
            return;
            
        }
    
        if( nil == imageView.image ) {
        
            if( _debug ) {
                NSLog(@"[DEBUG] GPUBlurImageView : No image yet, queued");
            }
        
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _imageWait);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self applyGrayscale:imageView];
            });
        
        } else {
        
            if ( _debug ) {
                NSLog(@"[DEBUG] GPUBlurImageView : Image available, starting");
            }
        
            [self applyGrayscale:imageView ];
        
        }
        
    }
    
}


@end
