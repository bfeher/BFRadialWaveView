//
//  BFRadialWaveView.m
//  BFRadialWaveHUD
//
//  Created by Bence Feher on 2/13/15.
//  Copyright (c) 2015 Bence Feher. All rights reserved.
//

#import "BFRadialWaveView.h"
// Classes:
#import "BFGradientCALayer.h"
// Pods:
#import "UIColor+BFPaperColors.h"


@interface BFRadialWaveView ()
@property (nonatomic) NSMutableArray *topCircleLayers;
@property (nonatomic) NSMutableArray *bottomCircleLayers;
@property CAShapeLayer *progressCircle;
@property UIView *container;
@property UIColor *circleColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) NSInteger circleCount;
@property (nonatomic) CGFloat progress;
@property CGPoint centerPoint;
@property CGFloat animationDuration;
@property BFRadialWaveViewMode mode;
@property NSMutableArray *deathRowForCircleLayers;  // This is where old circle layers go to be killed :(
@property BFGradientCALayer *radialGradientLayer;
@property CAShapeLayer *checkmarkLayer;
@property CAShapeLayer *crossLayer;
@property BOOL atTheDisco;
@property BOOL shouldRestartAnimationIfInterrupted;

@property BOOL paused; //To check if animation is paused.
@end

@implementation BFRadialWaveView
@synthesize diameter = _diameter;
NSInteger const BFRadialWaveView_DefaultNumberOfCircles = 20;
CGFloat const BFRadialWaveView_DefaultStrokeWidth = 2.f;
static CGFloat const BFRadialWaveView_CheckmarkAnimationDuration = 0.5f;
static CGFloat const BFRadialWaveView_BackgroundPadding = 10.f; // YOU MIGHT NEED TO CHANGE THIS IF YOU NOTICE THE GRADIENT LAYER NOT TAKING UP THE FULL VIEW!!
static NSString *const bfRadialViewDiscoAnimationKey = @"discoAnimation.key";
static NSString *const bfFadeCircleOutAnimationKey   = @"fadeCircleOutAnimation.key";
static NSString *const bfShowSuccessAnimationKey     = @"showSuccessAnimation.key";
static NSString *const bfShowErrorAnimationKey       = @"showErrorAnimation.key";
static NSString *const bfDrawCheckmarkAnimationKey   = @"drawCheckmarkAnimation.key";
static NSString *const bfDrawCrossAnimationKey       = @"drawCrossAnimation.key";
static NSString *const bfUnwindProgressForErrorKey   = @"unwindProgressForError.key";
static NSString *const bfFadeProgressCircleInKey     = @"fadeProgressCircleIn.key";



#pragma mark - Custom Initializers
- (instancetype)initWithView:(UIView *)container
                     circles:(NSInteger)numberOfCircles
                       color:(UIColor *)circleColor
                        mode:(BFRadialWaveViewMode)mode
                 strokeWidth:(CGFloat)strokeWidth
                withGradient:(BOOL)withGradient
{
    self = [super init];
    if (self) {
        [self setupWithView:container
                    circles:numberOfCircles
                      color:circleColor
                       mode:mode
                strokeWidth:strokeWidth
               withGradient:withGradient];
        
        self.paused = NO;
    }
    return self;
}


#pragma mark - Super Overrides
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds),
                                   CGRectGetMidY(self.bounds));
    
    [self repositionCircles];
    
    CGRect gradientFrame;
    if ([UIColor isColorClear:self.container.backgroundColor]) {
        gradientFrame = [[[UIApplication sharedApplication] keyWindow] bounds];
        gradientFrame.size.height += (CGRectGetMidY(self.container.bounds) - self.centerPoint.y) + BFRadialWaveView_BackgroundPadding;
    }
    else {
        gradientFrame = self.container.bounds;
        gradientFrame.size.height += (CGRectGetMidY(self.container.bounds) - self.centerPoint.y) + BFRadialWaveView_BackgroundPadding;
    }
    self.radialGradientLayer.frame = gradientFrame;
    self.radialGradientLayer.position = self.centerPoint;
    [self.radialGradientLayer setNeedsDisplay];
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

#pragma mark - Setters and Getters
- (NSMutableArray *)topCircleLayers
{
    if (!_topCircleLayers) {
        _topCircleLayers = [NSMutableArray array];
    }
    return _topCircleLayers;
}

- (NSMutableArray *)bottomCircleLayers
{
    if (!_bottomCircleLayers) {
        _bottomCircleLayers = [NSMutableArray array];
    }
    return _bottomCircleLayers;
}

- (CGFloat)diameter
{
    if (11 > _diameter) {
        CGFloat radius = (self.lineWidth * self.circleCount) + ((self.lineWidth / 2.f ) * self.circleCount) + 1;
        _diameter = 2.f * radius;
    }
    return _diameter;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    self.progressCircle.strokeEnd = progress;
}

- (void)setProgressCircleColor:(UIColor *)progressCircleColor
{
    if (!progressCircleColor) { return; }
    
    _progressCircleColor = progressCircleColor;
    self.progressCircle.strokeColor = progressCircleColor.CGColor;
}

- (void)setCheckmarkColor:(UIColor *)checkmarkColor
{
    if (!checkmarkColor) { return; }
    _checkmarkColor = checkmarkColor;
    self.checkmarkLayer.strokeColor = checkmarkColor.CGColor;
}

- (void)setCrossColor:(UIColor *)crossColor
{
    if (!crossColor) { return; }
    _crossColor = crossColor;
    self.crossLayer.strokeColor = crossColor.CGColor;
}

- (void)setDiscoColors:(NSArray *)discoColors
{
    _discoColors = discoColors;
    if (self.atTheDisco) {
        // Remove disco animation:
        [self disco:NO];
        // Get back to discoing:
        [self disco:YES];
    }
}

- (void)setDiscoSpeed:(CGFloat)discoSpeed
{
    _discoSpeed = discoSpeed;
    if (self.atTheDisco) {
        // Remove disco animation:
        [self disco:NO];
        // Get back to discoing:
        [self disco:YES];
    }
}


#pragma mark - Setup
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForReenteringForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareToResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithView:(UIView *)container
              circles:(NSInteger)numberOfCircles
                color:(UIColor *)circleColor
                 mode:(BFRadialWaveViewMode)mode
          strokeWidth:(CGFloat)strokeWidth
         withGradient:(BOOL)withGradient
{
    // Validate circle input:
    NSInteger circles = numberOfCircles;
    if (circles < 3) {
        NSLog(@"Must have at least 3 circles! Creating %ld more to accomodate for this...", 3 - (long)numberOfCircles);
        circles = 3;
    }
    
    // Validate stroke width input:
    CGFloat lineWidth = strokeWidth;
    if (lineWidth < 1.f) {
        NSLog(@"Stroke width must fall in the range [1.0, 5.0]. Adjusting to 1.f...");
        lineWidth = 1.f;
    }
    else if (lineWidth > 5.f) {
        NSLog(@"Stroke width must fall in the range [1.0, 5.0]. Adjusting to 1.f...");
        lineWidth = 5.f;
    }
    
    self.frame = container.bounds;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Visual properties:                                                                                                   //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    self.container = container;
    self.circleCount = numberOfCircles;
    self.circleColor = circleColor ? circleColor : [UIColor paperColorGray50];
    self.lineWidth = lineWidth;
    self.mode = mode;
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds),
                                   CGRectGetMidY(self.bounds));
    self.progressCircleColor = circleColor;
    self.checkmarkColor = self.circleColor;
    self.crossColor = self.circleColor;
    self.atTheDisco = NO;
    self.discoColors = nil;
    self.discoSpeed = 0.33f;
    self.animationDuration = 1.f;
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.progressCircle = [CAShapeLayer layer];
    self.deathRowForCircleLayers = [NSMutableArray array];
    
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    
    if (withGradient) {
        self.radialGradientLayer = [BFGradientCALayer new];
        
        CGRect gradientFrame;
        if ([UIColor isColorClear:self.container.backgroundColor]) {
            gradientFrame = [[[UIApplication sharedApplication] keyWindow] bounds];
            gradientFrame.size.height += (CGRectGetMidY(self.container.bounds) - self.centerPoint.y) + BFRadialWaveView_BackgroundPadding;
        }
        else {
            gradientFrame = self.container.bounds;
            gradientFrame.size.height += (CGRectGetMidY(self.container.bounds) - self.centerPoint.y) + BFRadialWaveView_BackgroundPadding;
        }
        self.radialGradientLayer.frame = gradientFrame;
        [self.layer insertSublayer:self.radialGradientLayer atIndex:0];
    }
    
    // Create circle layers:
    for (int i = 0; i < circles; i++) {
        CAShapeLayer *topCircleLayer = [CAShapeLayer layer];
        CAShapeLayer *bottomCircleLayer = [CAShapeLayer layer];
        [self.topCircleLayers addObject:topCircleLayer];
        [self.bottomCircleLayers addObject:bottomCircleLayer];
    }
    [self.container addSubview:self];
    
    [self registerForNotifications];
}

- (void)drawCircles
{
    for (int i = 0; i < self.topCircleLayers.count; i++) {
        [self drawCircleLayerAtIndex:i];
        [self startAnimatingCicle:self.topCircleLayers[i] withTimeIndex:i];
        [self startAnimatingCicle:self.bottomCircleLayers[i] withTimeIndex:i];
    }
}

- (void)drawCenterDot
{
    CGFloat radius = self.lineWidth / 2.f;
    CAShapeLayer *dot = self.topCircleLayers[0];
    
    // Make a circlular path:
    dot.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.f * radius, 2.f * radius)
                                          cornerRadius:radius].CGPath;
    
    // Center the dot in container:
    dot.position = CGPointMake(self.centerPoint.x - radius, self.centerPoint.y - radius);
    
    dot.fillColor = [UIColor clearColor].CGColor;
    dot.strokeColor = self.circleColor ? self.circleColor.CGColor : [UIColor blackColor].CGColor;
    dot.lineWidth = self.lineWidth;
    
    // Add to self
    [self.layer addSublayer:dot];
}

- (void)drawCircleLayerAtIndex:(NSInteger)index
{
    //NSLog(@"index = %ld", (long)index);
    if (0 == index) {
        [self drawCenterDot];
        return;
    }
    
    CGFloat radius = (self.lineWidth * index) + ((self.lineWidth / 2.f ) * index) + 1;
    //NSLog(@"radius = %0.2f", radius);
    
    // Upper circle:
    CAShapeLayer *topCircle = self.topCircleLayers[index];
    topCircle.bounds = CGRectMake(0, 0, 2.f * radius, 2.f * radius);
    topCircle.path = [UIBezierPath bezierPathWithRoundedRect:topCircle.bounds
                                                cornerRadius:radius].CGPath;
    
    // Lower circle:
    CAShapeLayer *bottomCircle = self.bottomCircleLayers[index];
    bottomCircle.bounds = CGRectMake(0, 0, 2.f * radius, 2.f * radius);
    bottomCircle.path = [UIBezierPath bezierPathWithRoundedRect:bottomCircle.bounds
                                                   cornerRadius:radius].CGPath;
    
    topCircle.anchorPoint = CGPointMake(0.5f, 0.5f);
    bottomCircle.anchorPoint = CGPointMake(0.5f, 0.5f);
    
    // MODES:
    switch (self.mode) {
        case BFRadialWaveViewMode_North:
        {
            topCircle.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
            bottomCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 1, 0, 0),
                                                         CATransform3DMakeRotation(M_PI, 0, 1, 0));
            break;
        }
        case BFRadialWaveViewMode_NorthEast:
        {
            topCircle.transform = CATransform3DMakeRotation(-3 * M_PI_4, 0, 0, 1);
            bottomCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 0, 1, 0),
                                                         CATransform3DMakeRotation(-3 * M_PI_4, 0, 0, 1));
            break;
        }
        case BFRadialWaveViewMode_East:
        {
            topCircle.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
            bottomCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(-M_PI_2, 0, 0, 1),
                                                         CATransform3DMakeRotation(M_PI, 1, 0, 0));
            break;
        }
        case BFRadialWaveViewMode_SouthEast:
        {
            topCircle.transform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1);
            bottomCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 0, 1, 0),
                                                         CATransform3DMakeRotation(-M_PI_4, 0, 0, 1));
            break;
        }
        case BFRadialWaveViewMode_South:
        {
            bottomCircle.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            break;
        }
        case BFRadialWaveViewMode_SouthWest:
        {
            topCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 0, 1, 0),
                                                      CATransform3DMakeRotation(M_PI_4, 0, 0, 1));
            bottomCircle.transform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
            break;
        }
        case BFRadialWaveViewMode_West:
        {
            topCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(-M_PI_2, 0, 0, 1),
                                                      CATransform3DMakeRotation(M_PI, 0, 1, 0));
            bottomCircle.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
            break;
        }
        case BFRadialWaveViewMode_NorthWest:
        {
            topCircle.transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 1, 0, 0),
                                                      CATransform3DMakeRotation(-M_PI_4, 0, 0, 1));
            bottomCircle.transform = CATransform3DMakeRotation(-5 * M_PI_4, 0, 0, 1);
            break;
        }
        case BFRadialWaveViewMode_Default:
        case BFRadialWaveViewMode_KuneKune:
        default:
        {
            topCircle.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
            bottomCircle.transform = CATransform3DMakeRotation(-3 * M_PI_2, 0, 0, 1);
            break;
        }
    }
    
    topCircle.position = CGPointMake(self.centerPoint.x, self.centerPoint.y);
    topCircle.fillColor = [UIColor clearColor].CGColor;
    topCircle.strokeColor = self.circleColor ? self.circleColor.CGColor : [UIColor blackColor].CGColor;
    topCircle.lineWidth = self.lineWidth;
    
    bottomCircle.position = CGPointMake(self.centerPoint.x, self.centerPoint.y);
    bottomCircle.fillColor = [UIColor clearColor].CGColor;
    bottomCircle.strokeColor = self.circleColor ? self.circleColor.CGColor : [UIColor blackColor].CGColor;
    bottomCircle.lineWidth = self.lineWidth;
    
    [self.layer addSublayer:topCircle];
    [self.layer addSublayer:bottomCircle];
}

- (void)drawProgressCircleWithProgress:(CGFloat)progress
{
    self.progress = progress;
    
    CGFloat radius = (self.lineWidth * self.circleCount) + ((self.lineWidth / 2.f ) * self.circleCount) + 1;
    _diameter = 2.f * radius;
    self.progressCircle.bounds = CGRectMake(0, 0, 2.f * radius, 2.f * radius);
    self.progressCircle.path = [UIBezierPath bezierPathWithRoundedRect:self.progressCircle.bounds
                                                          cornerRadius:radius].CGPath;
    
    self.progressCircle.anchorPoint = CGPointMake(0.5f, 0.5f);
    //    self.progressCircle.position = CGPointMake(self.centerPoint.x /*- radius*/, self.centerPoint.y /*- radius*/);
    self.progressCircle.position = CGPointMake(self.centerPoint.x, self.centerPoint.y);
    self.progressCircle.fillColor = [UIColor clearColor].CGColor;
    self.progressCircle.strokeColor = self.progressCircleColor.CGColor;
    self.progressCircle.lineWidth = self.lineWidth;
    self.progressCircle.strokeEnd = progress;
    
    [self.layer addSublayer:self.progressCircle];
}

#pragma mark - Public Methods
#pragma mark Loading
- (void)show
{
    [self showProgress:0];
    self.paused = NO;
}

#pragma mark Progress
- (void)showProgress:(CGFloat)progress
{
    [self drawCircles];
    [self drawProgressCircleWithProgress:progress];
    self.shouldRestartAnimationIfInterrupted = YES;
}


#pragma mark Success
- (void)showSuccess
{
    // Complete progress wheel (even if it was never up):
    [self drawProgressCircleWithProgress:self.progress];
    [self completeProgressForSuccess];
    
    // Draw checkmark:
    [self removeCircles];
    [self removeCross];
    [self drawCheckmark];
    self.shouldRestartAnimationIfInterrupted = NO;
}


#pragma mark Error
- (void)showError
{
    // Unwind progress:
    if (0 < self.progress) {
        [self drawProgressCircleWithProgress:self.progress];
        [self unwindProgressForError];
    }
    else {
        [self drawProgressCircleWithProgress:0];
        [self fadeProgressCircleIn];
    }
    // Draw 'X':
    [self removeCircles];
    [self removeCheckmark];
    [self drawCross];
    self.shouldRestartAnimationIfInterrupted = NO;
}


#pragma mark Update
- (void)updateProgress:(CGFloat)progress
{
    [self setProgress:progress];
}

- (void)updateCircleColor:(UIColor *)color
{
    if (color == self.circleColor) { return; }
    
    self.circleColor = color;
    
    for (int i = 0; i < self.topCircleLayers.count; i++) {
        CAShapeLayer *topCircle = self.topCircleLayers[i];
        CAShapeLayer *bottomCircle = self.bottomCircleLayers[i];
        topCircle.strokeColor = self.circleColor.CGColor;
        bottomCircle.strokeColor = self.circleColor.CGColor;
    }
}


- (void)repositionCircles
{
    for (int i = 0; i < self.topCircleLayers.count; i++) {
        CAShapeLayer *topCircle = self.topCircleLayers[i];
        CAShapeLayer *bottomCircle = self.bottomCircleLayers[i];
        if (0 == i) {
            // Center dots:
            CGFloat radius = self.lineWidth / 2.f;
            topCircle.position = CGPointMake(self.centerPoint.x - radius, self.centerPoint.y - radius);
            bottomCircle.position = CGPointMake(self.centerPoint.x - radius, self.centerPoint.y - radius);
        }
        else {
            // Outer circle layers
            topCircle.position = CGPointMake(self.centerPoint.x, self.centerPoint.y);
            bottomCircle.position = CGPointMake(self.centerPoint.x, self.centerPoint.y);
        }
    }
    self.progressCircle.position = CGPointMake(self.centerPoint.x, self.centerPoint.y);
}


#pragma mark Pause and Resume
// (Pause and Resume features graciously added by GitHub user @fco-edno !)
- (void)pauseAnimation
{
    for (CAShapeLayer *layer in self.topCircleLayers) {
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    };
    
    for (CAShapeLayer *layer in self.bottomCircleLayers) {
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }
    
    self.paused = YES;
}

- (void)resumeAnimation
{
    for (CAShapeLayer *layer in self.bottomCircleLayers) {
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }
    
    for (CAShapeLayer *layer in self.topCircleLayers) {
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }
    
    self.paused = NO;
}

- (BOOL)isPaused
{
    return self.paused;
}


#pragma mark Fun
- (void)disco:(BOOL)on
{
    self.atTheDisco = on;
    
    if (on) {
        for (int i = 0; i < self.topCircleLayers.count; i++) {
            CAShapeLayer *topCircle = self.topCircleLayers[i];
            CAShapeLayer *bottomCircle = self.bottomCircleLayers[i];
            [self discoTimeForCircle:topCircle atIndex:i];
            [self discoTimeForCircle:bottomCircle atIndex:i];
        }
    }
    else {
        for (int i = 0; i < self.topCircleLayers.count; i++) {
            CAShapeLayer *topCircle = self.topCircleLayers[i];
            CAShapeLayer *bottomCircle = self.bottomCircleLayers[i];
            [topCircle removeAnimationForKey:bfRadialViewDiscoAnimationKey];
            [bottomCircle removeAnimationForKey:bfRadialViewDiscoAnimationKey];
        }
    }
}


#pragma mark - Animation
- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"id"] isEqualToString:bfDrawCheckmarkAnimationKey] && flag) {
        //NSLog(@"finished success");
        [self.delegate successfulCompletionWithRadialWaveView:self];
    }
    else if ([[anim valueForKey:@"id"] isEqualToString:bfUnwindProgressForErrorKey] && flag) {
        //NSLog(@"finished unwinding for error");
        [self fadeProgressCircleIn];
    }
    else if ([[anim valueForKey:@"id"] isEqualToString:bfDrawCrossAnimationKey] && flag) {
        //NSLog(@"finished drawing X");
    }
    else if ([[anim valueForKey:@"id"] isEqualToString:bfFadeProgressCircleInKey] && flag) {
        //NSLog(@"finished fading progress back in for error");
        [self.delegate errorCompletionWithRadialWaveView:self];
    }
}

- (void)startAnimatingCicle:(CAShapeLayer *)circle
              withTimeIndex:(NSInteger)index
{
    if (0 != index) {
        CGFloat toValue = (self.mode == BFRadialWaveViewMode_KuneKune) ? 0.25f : 0.5f;
        //        CGFloat toValue = (0.5f / (CGFloat)self.circleCount) * ((CGFloat)index + 1);  // for screenshot
        circle.strokeEnd = toValue;
        
        CABasicAnimation *semicircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        semicircle.duration = self.animationDuration;
        semicircle.autoreverses = YES;
        semicircle.repeatCount = HUGE_VALF;
        semicircle.beginTime = (self.animationDuration / 10.f) * index;
        semicircle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        semicircle.fromValue = @(0);
        semicircle.toValue = [NSNumber numberWithFloat:toValue];
        semicircle.removedOnCompletion = YES;
        [circle addAnimation:semicircle forKey:@"semicircle"];
    }
}

- (void)discoTimeForCircle:(CAShapeLayer *)circle
                   atIndex:(NSInteger)index
{
    // Use default colors of self.discoColors doesn't exist:
    NSArray *colors = self.discoColors ? self.discoColors : @[[UIColor paperColorRedA400],
                                                              [UIColor paperColorOrangeA400],
                                                              [UIColor paperColorYellowA400],
                                                              [UIColor paperColorGreenA400],
                                                              [UIColor paperColorBlueA400],
                                                              [UIColor paperColorIndigoA400],
                                                              [UIColor paperColorPurpleA400]];
    
    NSInteger colorCount = colors.count;
    NSMutableArray *animationsArray = [NSMutableArray array];
    
    for (int i = 0; i < colorCount; i++) {
        CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        colorAnimation.beginTime = (self.discoSpeed / colorCount) * i;
        colorAnimation.duration = self.discoSpeed;
        colorAnimation.fromValue = (id)[colors[i] CGColor];
        colorAnimation.toValue = (id)[colors[(i + 1) % colorCount] CGColor];
        
        [animationsArray addObject:colorAnimation];
    }
    
    CAAnimationGroup *discoAnimation = [CAAnimationGroup animation];
    discoAnimation.beginTime    = (self.discoSpeed / 10.f) * index;
    discoAnimation.duration     = self.discoSpeed;
    discoAnimation.animations   = animationsArray;
    discoAnimation.autoreverses = NO;
    discoAnimation.repeatCount  = HUGE_VALF;
    discoAnimation.removedOnCompletion = YES;
    
    [circle addAnimation:discoAnimation forKey:bfRadialViewDiscoAnimationKey];
}

- (void)removeCircles
{
    for (int i = 0; i < self.topCircleLayers.count; i++) {
        CAShapeLayer *topCircle = self.topCircleLayers[i];
        CAShapeLayer *bottomCircle = self.bottomCircleLayers[i];
        
        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [fade setValue:bfFadeCircleOutAnimationKey forKey:@"id"];
        fade.delegate = self;
        fade.duration = 0.2f;
        fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fade.fromValue = [NSNumber numberWithFloat:1.f];
        fade.toValue = [NSNumber numberWithFloat:0];
        
        topCircle.opacity = 0;
        bottomCircle.opacity = 0;
        [topCircle addAnimation:fade forKey:bfFadeCircleOutAnimationKey];
        [bottomCircle addAnimation:fade forKey:bfFadeCircleOutAnimationKey];
    }
}

- (void)completeProgressForSuccess
{
    CABasicAnimation *fullCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    fullCircle.duration = self.animationDuration;
    fullCircle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fullCircle.fromValue = [NSNumber numberWithFloat:self.progress];
    fullCircle.toValue = @(1);
    
    self.progressCircle.strokeEnd = 1;
    [self.progressCircle addAnimation:fullCircle forKey:bfShowSuccessAnimationKey];
}

- (void)unwindProgressForError
{
    CABasicAnimation *fullCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [fullCircle setValue:bfUnwindProgressForErrorKey forKey:@"id"];
    fullCircle.delegate = self;
    fullCircle.duration = self.animationDuration;
    fullCircle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fullCircle.fromValue = [NSNumber numberWithFloat:self.progress];
    fullCircle.toValue = @(0);
    
    self.progressCircle.strokeEnd = 0;
    [self.progressCircle addAnimation:fullCircle forKey:bfUnwindProgressForErrorKey];
}

- (void)fadeProgressCircleIn
{
    self.progressCircle.opacity = 0;
    self.progressCircle.strokeEnd = 1.f;
    
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fade setValue:bfFadeProgressCircleInKey forKey:@"id"];
    fade.delegate = self;
    fade.duration = self.animationDuration;
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fade.fromValue = @(0);
    fade.toValue = @(1);
    
    self.progressCircle.opacity = 1;
    [self.progressCircle addAnimation:fade forKey:bfFadeProgressCircleInKey];
}

- (void)drawCheckmark
{
    UIBezierPath* checkmarkPath = [UIBezierPath bezierPath];
    [checkmarkPath moveToPoint:CGPointMake(self.diameter * 0.28f, self.diameter * 0.53f)];
    [checkmarkPath addLineToPoint:CGPointMake(self.diameter * 0.42f, self.diameter * 0.66f)];
    [checkmarkPath addLineToPoint:CGPointMake(self.diameter * 0.72f, self.diameter * 0.36f)];
    checkmarkPath.lineCapStyle = kCGLineCapSquare;
    
    self.checkmarkLayer = [CAShapeLayer layer];
    self.checkmarkLayer.path = checkmarkPath.CGPath;
    self.checkmarkLayer.fillColor = nil;
    self.checkmarkLayer.strokeColor = self.checkmarkColor.CGColor;
    self.checkmarkLayer.lineWidth = self.lineWidth;
    self.checkmarkLayer.strokeEnd = 0.f;
    self.checkmarkLayer.position = CGPointMake(self.centerPoint.x - (self.diameter / 2.f), self.centerPoint.y - (self.diameter / 2.f));
    [self.layer addSublayer:self.checkmarkLayer];
    
    CABasicAnimation *checkmarkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [checkmarkAnimation setValue:bfDrawCheckmarkAnimationKey forKey:@"id"];
    checkmarkAnimation.delegate = self;
    checkmarkAnimation.duration = BFRadialWaveView_CheckmarkAnimationDuration;
    checkmarkAnimation.removedOnCompletion = YES;
    checkmarkAnimation.fromValue = @(0);
    checkmarkAnimation.toValue = @(1);
    checkmarkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    self.checkmarkLayer.strokeEnd = 1.f;
    [self.checkmarkLayer addAnimation:checkmarkAnimation
                               forKey:bfDrawCheckmarkAnimationKey];
}

- (void)removeCheckmark
{
    [self.checkmarkLayer removeFromSuperlayer];
}

- (void)drawCross
{
    UIBezierPath* crossPath = [UIBezierPath bezierPath];
    [crossPath moveToPoint:CGPointMake(self.diameter * 0.72f, self.diameter * 0.27f)];
    [crossPath addLineToPoint:CGPointMake(self.diameter * 0.27f, self.diameter * 0.72f)];
    [crossPath moveToPoint:CGPointMake(self.diameter * 0.27f, self.diameter * 0.27f)];
    [crossPath addLineToPoint:CGPointMake(self.diameter * 0.72f, self.diameter * 0.72f)];
    crossPath.lineCapStyle = kCGLineCapSquare;
    
    self.crossLayer = [CAShapeLayer layer];
    self.crossLayer.path = crossPath.CGPath;
    self.crossLayer.fillColor = nil;
    self.crossLayer.strokeColor = self.crossColor.CGColor;
    self.crossLayer.lineWidth = self.lineWidth;
    self.crossLayer.opacity = 0.f;
    self.crossLayer.position = CGPointMake(self.centerPoint.x - (self.diameter / 2.f), self.centerPoint.y - (self.diameter / 2.f));
    
    [self.layer addSublayer:self.crossLayer];
    
    CABasicAnimation *drawCrossAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [drawCrossAnimation setValue:bfDrawCrossAnimationKey forKey:@"id"];
    drawCrossAnimation.delegate = self;
    drawCrossAnimation.duration = BFRadialWaveView_CheckmarkAnimationDuration;
    drawCrossAnimation.removedOnCompletion = YES;
    drawCrossAnimation.fromValue = @(0);
    drawCrossAnimation.toValue = @(1);
    drawCrossAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    self.crossLayer.opacity = 1.f;
    [self.crossLayer addAnimation:drawCrossAnimation
                           forKey:bfDrawCrossAnimationKey];
}

- (void)removeCross
{
    [self.crossLayer removeFromSuperlayer];
}


#pragma mark - Notificaion Handlers
- (void)prepareToResignActive
{
    [self.layer removeAllAnimations];
}

- (void)prepareForReenteringForeground
{
    if (self.shouldRestartAnimationIfInterrupted) {
        [self showProgress:self.progress];
    }
}


@end
