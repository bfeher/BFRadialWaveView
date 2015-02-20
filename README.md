BFRadialWaveView
=============
[![CocoaPods](https://img.shields.io/cocoapods/v/BFRadialWaveView.svg?style=flat)](https://github.com/bfeher/BFRadialWaveView)

> A mesmerizing view with lots of options. It is meant to be used with [BFRadialWaveHUD](), but you are free to take it :) 

![Animated Screenshot]("Animated Screenshot")


About
---------
_BFRadialWaveView_ is a sublcass of UIView. It displays a radial wave with various options. It was made to be the progress/spinner view for ![BFRadialWaveHUD]().

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
 <br />

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


Properties
---------
`someProp` <br />
SomeProp description.



Usage
---------
Add the _BFRadialWaveView_ header and implementation file to your project. (.h & .m)

### Working Example
*(Taken directly from example project.)*<br />
```objective-c
```

### Customized Example
*(Taken directly from example project.)*<br />
```objective-c
```

Cocoapods
-------

CocoaPods are the best way to manage library dependencies in Objective-C projects.
Learn more at http://cocoapods.org

Add this to your podfile to add BFRadialWaveView to your project.
```ruby
platform :ios, '7.1'
```


License
--------
_BFRadialWaveView_ uses the MIT License:

> Please see included [LICENSE file](https://raw.githubusercontent.com/bfeher/BFRadialWaveView/master/LICENSE.md).
