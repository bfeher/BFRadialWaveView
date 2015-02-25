BFRadialWaveView
====================
[![CocoaPods](https://img.shields.io/cocoapods/v/BFRadialWaveView.svg?style=flat)](https://github.com/bfeher/BFRadialWaveView)

> Note that this changelog was started very late, at roughly the time between version 1.1.25 and 1.2.1. Previous changes are lost to the All Father, forever to be unknown.


1.3.1
---------
+ ^ Changing build settings to try and get the cocoapod working. Experimenting a bit here.


1.3.1
---------
+ ^ Animations now restart when app becomes active again after being sent to the background.
+ ^ Moved resources into a 'Resources' directory. Updated the podspec to reflect this.


1.2.1
---------
+ + Added a changelog!
- - Removed `- (void)updateProgressCircleColor:(UIColor *)color` and replaced it with the property `UIColor *progressCircleColor`.
+ ^ Fixed bug where checkmarkColor and crossColor weren't being updated properly.
