//
//  BFGradientCALayer.m
//  BFRadialWaveHUD
//
//  Created by Bence Feher on 2/16/15.
//  Copyright (c) 2015 Bence Feher. All rights reserved.
//

#import "BFGradientCALayer.h"
#import <UIKit/UIKit.h>


@implementation BFGradientCALayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {0.f, 1.f};
    CGFloat gradColors[8] = {   1.4f, 1.4f, 1.4f, 0.4f,
        0.0f, 0.0f, 0.0f, 0.0f  };
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    
    float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    
    CGPoint gradCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    /*CGGradientRef gradient = [self newGradientWithColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f], nil]
     locations:[NSArray arrayWithObjects:@0, @1, nil]
     inContext:ctx];
     
     */
    CGContextDrawRadialGradient (ctx, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
    
    
    CGGradientRelease(gradient);
}

@end
