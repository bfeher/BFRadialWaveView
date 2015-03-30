//
//  BFRadialWaveView.h
//  BFRadialWaveHUD
//
//  Created by Bence Feher on 2/13/15.
//  Copyright (c) 2015 Bence Feher. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BFRadialWaveViewMode) {
    BFRadialWaveViewMode_Default,       // Default: A swirly looking thing.
    BFRadialWaveViewMode_KuneKune,      // Kune Kune: A creepy feeler looking thing.
    BFRadialWaveViewMode_North,         // North: Points upwards.
    BFRadialWaveViewMode_NorthEast,     // North East: Points upwards to the right.
    BFRadialWaveViewMode_East,          // East: Points right.
    BFRadialWaveViewMode_SouthEast,     // South East: Points downwards to the right.
    BFRadialWaveViewMode_South,         // South: Points down.
    BFRadialWaveViewMode_SouthWest,     // South West: Points downwards to the left.
    BFRadialWaveViewMode_West,          // West: Points left.
    BFRadialWaveViewMode_NorthWest,     // North West: Points at Kanye.
};

extern NSInteger const BFRadialWaveView_DefaultNumberOfCircles;
extern CGFloat const BFRadialWaveView_DefaultStrokeWidth;


@class BFRadialWaveView;
@protocol BFRadialWaveViewDelegate <NSObject>
/**
 *  The protocol message to send our delegate on success.
 *
 *  @param sender The BFRadialWaveView that sent this message.
 */
- (void)successfulCompletionWithRadialWaveView:(BFRadialWaveView *)sender;

/**
 *  The protocol message to send our delegate on failure.
 *
 *  @param sender The BFRadialWaveView that sent this message.
 */
- (void)errorCompletionWithRadialWaveView:(BFRadialWaveView *)sender;
@end


@interface BFRadialWaveView : UIView
#pragma mark - Custom Initializers
/**
 *  Custom initializer. Use this when you make a BFRadialWaveView in code.
 *
 *  @param container       A UIView to place this one in.
 *  @param numberOfCircles NSInteger number of circles. Min = 3, Max = 20.
 *  @param circleColor     UIColor to set the circles' strokeColor to.
 *  @param mode            BFRadialWaveViewMode.
 *  @param strokeWidth     CGFloat stroke width of the circles.
 *  @param withGradient    BOOL flag to decide whether or not to draw a gradient in the background.
 *
 *  @return A BFRadialWaveView! Aww yiss!
 */
- (instancetype)initWithView:(UIView *)container
                     circles:(NSInteger)numberOfCircles
                       color:(UIColor *)circleColor
                        mode:(BFRadialWaveViewMode)mode
                 strokeWidth:(CGFloat)strokeWidth
                withGradient:(BOOL)withGradient;


#pragma mark - Setup
/**
 *  Setup. Use this when you made a BFRadialWaveView in the storyboard or xib.
 *
 *  @param container       A UIView to place this one in.
 *  @param numberOfCircles NSInteger number of circles. Min = 3, Max = 20.
 *  @param circleColor     UIColor to set the circles' strokeColor to.
 *  @param mode            BFRadialWaveViewMode.
 *  @param strokeWidth     CGFloat stroke width of the circles.
 *  @param withGradient    BOOL flag to decide whether or not to draw a gradient in the background.
 */
- (void)setupWithView:(UIView *)container
              circles:(NSInteger)numberOfCircles
                color:(UIColor *)circleColor
                 mode:(BFRadialWaveViewMode)mode
          strokeWidth:(CGFloat)strokeWidth
         withGradient:(BOOL)withGradient;


#pragma mark - Loading
/** Show a basic view with no progress. */
- (void)show;


#pragma mark - Progress
/**
 *  Show a view with progress.
 *
 *  @param progress CGFloat between 0.f and 1.f. The progress to show.
 */
- (void)showProgress:(CGFloat)progress;


#pragma mark - Success
/** Show a success view. */
- (void)showSuccess;


#pragma mark - Error
/** Show an error view. */
- (void)showError;


#pragma mark - Update
/**
 *  Update the progress to a certain value.
 *
 *  @param progress CGFloat between 0.f and 1.f. The progress to show.
 */
- (void)updateProgress:(CGFloat)progress;

/**
 *  Update the circle color on the fly.
 *
 *  @param color UIColor to set the circles' strokeColor to.
 */
- (void)updateCircleColor:(UIColor *)color;


#pragma mark - Pause and Resume
// (Pause and Resume features graciously added by GitHub user @fco-edno !)
/** Pause the animation. */
- (void)pauseAnimation;

/** Resume the animation. */
- (void)resumeAnimation;

/**
 *  Check the paused/not-paused state of the view's animations.
 *
 *  @return Returns a BOOL flag indicating the state of the animation being either paused (YES) or not-paused (NO).
 */
- (BOOL)isPaused;


#pragma mark - Fun
/**
 *  Activate or deactivate disco mode.
 *
 *  @param on BOOL flag to turn disco mode on (YES) or off (NO).
 */
- (void)disco:(BOOL)on;


#pragma mark - Properties
/** The diameter of the view (including progress circle). */
@property (nonatomic, readonly) CGFloat diameter;

/** The UIColor to set the progress circle to. Default is the same as the circleColor passed into the initializer or the setup. */
@property (nonatomic) UIColor *progressCircleColor;

/** The UIColor to set the success checkmark to. By default it is the same as the circleColor passed into the initializer or the setup. */
@property (nonatomic) UIColor *checkmarkColor;

/** The UIColor to set the failure cross to. By default it is the same as the circleColor passed into the initializer or the setup. */
@property (nonatomic) UIColor *crossColor;

/** An NSArray of colors to use for disco mode. By default it is the rainbow. */
@property (nonatomic) NSArray *discoColors;

/** CGFloat speed for the disco animation. Default is 0.33f. */
@property (nonatomic) CGFloat discoSpeed;

/** BFRadialWaveViewDelegate delegate for our protocol. */
@property id <BFRadialWaveViewDelegate> delegate;


@end
