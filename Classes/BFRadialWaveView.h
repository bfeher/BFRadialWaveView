//
//  BFRadialWaveView.h
//  BFRadialWaveHUD
//
//  Created by Bence Feher on 2/13/15.
//  Copyright (c) 2015 Bence Feher. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BFRadialWaveViewMode) {
    BFRadialWaveViewMode_Default,
    BFRadialWaveViewMode_KuneKune,
    BFRadialWaveViewMode_North,
    BFRadialWaveViewMode_NorthEast,
    BFRadialWaveViewMode_East,
    BFRadialWaveViewMode_SouthEast,
    BFRadialWaveViewMode_South,
    BFRadialWaveViewMode_SouthWest,
    BFRadialWaveViewMode_West,
    BFRadialWaveViewMode_NorthWest,
};

extern NSInteger const BFRadialWaveView_DefaultNumberOfCircles;
extern CGFloat const BFRadialWaveView_DefaultStrokeWidth;


@class BFRadialWaveView;
@protocol BFRadialWaveViewDelegate <NSObject>
- (void)successfulCompletionWithRadialWaveView:(BFRadialWaveView *)sender;
- (void)errorCompletionWithRadialWaveView:(BFRadialWaveView *)sender;
@end


@interface BFRadialWaveView : UIView
#pragma mark - Custom Initializers
// Use this when you make a BFRadialWaveView in code:
- (instancetype)initWithView:(UIView *)container
                     circles:(NSInteger)numberOfCircles
                       color:(UIColor *)circleColor
                        mode:(BFRadialWaveViewMode)mode
                 strokeWidth:(CGFloat)strokeWidth
                withGradient:(BOOL)withGradient;


#pragma mark - Setup
// Use this when you made a BFRadialWaveView in the storyboard or xib:
- (void)setupWithView:(UIView *)container
              circles:(NSInteger)numberOfCircles
                color:(UIColor *)circleColor
                 mode:(BFRadialWaveViewMode)mode
          strokeWidth:(CGFloat)strokeWidth
         withGradient:(BOOL)withGradient;


#pragma mark - Loading
- (void)show;


#pragma mark - Progress
- (void)showProgress:(CGFloat)progress;


#pragma mark - Success
- (void)showSuccess;


#pragma mark - Error
- (void)showError;


#pragma mark - Update
- (void)updateProgress:(CGFloat)progress;

- (void)updateCircleColor:(UIColor *)color;

- (void)updateProgressCircleColor:(UIColor *)color;


#pragma mark - Fun
- (void)disco:(BOOL)on;


#pragma mark - Properties
@property (nonatomic, readonly) CGFloat diameter;
@property UIColor *checkmarkColor;
@property UIColor *crossColor;
@property (nonatomic) NSArray *discoColors;
@property (nonatomic) CGFloat discoSpeed;

@property id <BFRadialWaveViewDelegate> delegate;

@end
