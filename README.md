BFRadialWaveView
=============
[![CocoaPods](https://img.shields.io/cocoapods/v/BFRadialWaveView.svg?style=flat)](https://github.com/bfeher/BFRadialWaveView)

> A mesmerizing view with lots of options. It is meant to be used with [BFRadialWaveHUD](https://github.com/bfeher/BFRadialWaveHUD), but you are free to take it :) 
<br />

>_Click the screenshot below for an animated gifv!_<br />
[![Animated Screenshot](https://raw.githubusercontent.com/bfeher/BFRadialWaveView/master/BFRadialWaveViewDemoFrame1.png)](http://i.imgur.com/blnYaNw.gifv)


About
---------
_BFRadialWaveView_ is a sublcass of UIView. It displays a radial wave with various options. It was made to be the progress/spinner view for [BFRadialWaveHUD](https://github.com/bfeher/BFRadialWaveHUD).


Changes
---------
Please refer to this [CHANGELOG.md](https://github.com/bfeher/BFRadialWaveView/blob/master/CHANGELOG.md).


To do:
---------
+ ~~Restart animations on app wake-up.~~
+ ~~Move resources into a resource directory, reflecting this change in the cocoapod. (Fix file structure)~~


Modes
---------
```objective-c
BFRadialWaveViewMode_Default       // Default: A swirly looking thing.
BFRadialWaveViewMode_KuneKune      // Kune Kune: A creepy feeler looking thing.
BFRadialWaveViewMode_North         // North: Points upwards.
BFRadialWaveViewMode_NorthEast     // North East: Points upwards to the right.
BFRadialWaveViewMode_East          // East: Points right.
BFRadialWaveViewMode_SouthEast     // South East: Points downwards to the right.
BFRadialWaveViewMode_South         // South: Points down.
BFRadialWaveViewMode_SouthWest     // South West: Points downwards to the left.
BFRadialWaveViewMode_West          // West: Points left.
BFRadialWaveViewMode_NorthWest     // North West: Points at Kanye.
```

Methods
---------
## Initializer
>Use this when you make a BFRadialWaveView in code.
```objective-c
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
 *  @return Returns A BFRadialWaveView! Aww yiss!
 */
- (instancetype)initWithView:(UIView *)container
                     circles:(NSInteger)numberOfCircles
                       color:(UIColor *)circleColor
                        mode:(BFRadialWaveViewMode)mode
                 strokeWidth:(CGFloat)strokeWidth
                withGradient:(BOOL)withGradient;
```

## Setup
>Use this when you made a BFRadialWaveView in the storyboard or xib
```objective-c
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
```

### Loading
```objective-c
/** Show a basic view with no progress. */
- (void)show;
```

### Progress
```objective-c
/**
 *  Show a view with progress.
 *
 *  @param progress CGFloat between 0.f and 1.f. The progress to show.
 */
- (void)showProgress:(CGFloat)progress;
```

### Success
```objective-c
/** Show a success view. */
- (void)showSuccess;
```

### Error
```objective-c
/** Show an error view. */
- (void)showError;
```

### Update
```objective-c
/**
 *  Update the progress to a certain value.
 *
 *  @param progress CGFloat between 0.f and 1.f. The progress to show.
 */
- (void)updateProgress:(CGFloat)progress;
```

```objective-c
/**
 *  Update the circle color on the fly.
 *
 *  @param color UIColor to set the circles' strokeColor to.
 */
- (void)updateCircleColor:(UIColor *)color;
```

### Pause and Resume  
Pause and Resume features graciously added by GitHub user [@fco-edno](https://github.com/fco-edno) :)
```objective-c
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
```

### Fun
```objective-c
/**
 *  Activate of Deactivate disco mode! This will rapidly cycle colors through your BFRadialWaveView. Without setting the colors explicitly, a rainbow is used.
 *
 *  @param on BOOL flag to turn disco mode on (YES) or off (NO).
 */
- (void)disco:(BOOL)on;
```



Properties
---------
```objective-c
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
```

Usage
---------
>Be sure the check out the included demo app to see examples on how to use BFRadialWaveView.

Add the _BFRadialWaveView_ header and implementation files to your project. (BFRadialWaveView.h & BFRadialWaveView.m)
as well as the _BFGradientCALayer_ header and implementation files to your project. (BFGradientLayer.h & BFGradientLayer.m)

### Working Example
```objective-c
BFRadialWaveView *radialWaveView;
radialWaveView = [[BFRadialWaveView alloc] initWithView:self.view
                                                circles:BFRadialWaveView_DefaultNumberOfCircles
                                                  color:nil
                                                   mode:BFRadialWaveViewMode_Default
                                            strokeWidth:BFRadialWaveView_DefaultStrokeWidth
                                           withGradient:YES];
[radialWaveView show];
```

### Customized Example
```objective-c
BFRadialWaveView *radialWaveView;
radialWaveView = [[BFRadialWaveView alloc] initWithView:self.view
                                                circles:10
                                                  color:[UIColor paperColorGray800]
                                                   mode:BFRadialWaveViewMode_North
                                            strokeWidth:5.f
                                           withGradient:NO];
[radialWaveView disco:YES];   // Disco time!
[radialWaveView showProgress:someProgressBetweenZeroAndOne];
```

Cocoapods
-------

CocoaPods are the best way to manage library dependencies in Objective-C projects.
Learn more at http://cocoapods.org

Add this to your podfile to add BFRadialWaveView to your project.
```ruby
platform :ios, '7.1'
pod 'BFRadialWaveView', '~> 1.4.6'
```


License
--------
_BFRadialWaveView_ uses the MIT License:

> Please see included [LICENSE file](https://raw.githubusercontent.com/bfeher/BFRadialWaveView/master/LICENSE.md).
