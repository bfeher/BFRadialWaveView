//
//  ViewController.m
//  BFRadialWaveView
//
//  Created by Bence Feher on 2/18/15.
//  Copyright (c) 2015 Bence Feher. All rights reserved.
//

#import "ViewController.h"
// Classes:
#import "BFRadialWaveView.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;
@property (weak, nonatomic) IBOutlet UILabel *strokeWidthLabel;
@property (weak, nonatomic) IBOutlet UILabel *circleCountLabel;
@property (weak, nonatomic) IBOutlet UISwitch *discoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *gradientSwitch;
@property (weak, nonatomic) IBOutlet UIButton *showProgressButton;
@property BFRadialWaveView *radialWave;
@property BFRadialWaveViewMode mode;
@property UIColor *strokeColor;
@property CGFloat strokeWidth;
@property NSInteger numberOfCircles;
@end

@implementation ViewController
BOOL showSuccess;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.mode = BFRadialWaveViewMode_Default;
    self.strokeColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.strokeWidth = 2.f;
    self.strokeWidthLabel.text = [NSString stringWithFormat:@"stroke width: %0.2f", self.strokeWidth];
    self.numberOfCircles = BFRadialWaveView_DefaultNumberOfCircles;
    self.circleCountLabel.text = [NSString stringWithFormat:@"%ld circles", (long)self.numberOfCircles];

    [self setupTypeControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.radialWave = [[BFRadialWaveView alloc] initWithView:self.view
                                                     circles:self.numberOfCircles
                                                       color:self.strokeColor
                                                        mode:self.mode
                                                 strokeWidth:self.strokeWidth
                                                withGradient:self.gradientSwitch.isOn];
    [self.radialWave disco:self.discoSwitch.isOn];
    [self.radialWave show];
    [self.view sendSubviewToBack:self.radialWave];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setupTypeControl
{
    [self.typeControl setTitle:@"D" forSegmentAtIndex:0];
    [self.typeControl setTitle:@"K" forSegmentAtIndex:1];
    [self.typeControl setTitle:@"↑\U0000FE0E" forSegmentAtIndex:2];
    [self.typeControl setTitle:@"↗\U0000FE0E" forSegmentAtIndex:3];
    [self.typeControl setTitle:@"→\U0000FE0E" forSegmentAtIndex:4];
    [self.typeControl setTitle:@"↘\U0000FE0E" forSegmentAtIndex:5];
    [self.typeControl setTitle:@"↓\U0000FE0E" forSegmentAtIndex:6];
    [self.typeControl setTitle:@"↙\U0000FE0E" forSegmentAtIndex:7];
    [self.typeControl setTitle:@"←\U0000FE0E" forSegmentAtIndex:8];
    [self.typeControl setTitle:@"↖\U0000FE0E" forSegmentAtIndex:9];
}


#pragma mark - Action Handlers
- (IBAction)typeChanged:(UISegmentedControl *)sender
{
    self.mode = (BFRadialWaveViewMode)sender.selectedSegmentIndex;
    [self.radialWave removeFromSuperview];
    self.radialWave = [[BFRadialWaveView alloc] initWithView:self.view
                                                     circles:self.numberOfCircles
                                                       color:self.strokeColor
                                                        mode:self.mode
                                                 strokeWidth:self.strokeWidth
                                                withGradient:self.gradientSwitch.isOn];
    [self.radialWave disco:self.discoSwitch.isOn];
    [self.radialWave show];
    [self.view sendSubviewToBack:self.radialWave];
}

- (IBAction)strokeWidthChanged:(UIStepper *)sender
{
    self.strokeWidth = sender.value;
    self.strokeWidthLabel.text = [NSString stringWithFormat:@"stroke width: %0.2f", sender.value];

    [self.radialWave removeFromSuperview];
    self.radialWave = [[BFRadialWaveView alloc] initWithView:self.view
                                                     circles:self.numberOfCircles
                                                       color:self.strokeColor
                                                        mode:self.mode
                                                 strokeWidth:self.strokeWidth
                                                withGradient:self.gradientSwitch.isOn];
    [self.radialWave disco:self.discoSwitch.isOn];
    [self.radialWave show];
    [self.view sendSubviewToBack:self.radialWave];
}

- (IBAction)circleCountChanged:(UIStepper *)sender
{
    self.numberOfCircles = sender.value;
    self.circleCountLabel.text = [NSString stringWithFormat:@"%ld circles", (long)self.numberOfCircles];
    
    [self.radialWave removeFromSuperview];
    self.radialWave = [[BFRadialWaveView alloc] initWithView:self.view
                                                     circles:self.numberOfCircles
                                                       color:self.strokeColor
                                                        mode:self.mode
                                                 strokeWidth:self.strokeWidth
                                                withGradient:self.gradientSwitch.isOn];
    [self.radialWave disco:self.discoSwitch.isOn];
    [self.radialWave show];
    [self.view sendSubviewToBack:self.radialWave];
}

- (IBAction)showProgressPressed:(UIButton *)sender
{
    [self updateProgressRadialWaveView:self.radialWave];
}

- (IBAction)gradientFlipped:(UISwitch *)sender
{
    [self.radialWave removeFromSuperview];
    self.radialWave = [[BFRadialWaveView alloc] initWithView:self.view
                                                     circles:self.numberOfCircles
                                                       color:self.strokeColor
                                                        mode:self.mode
                                                 strokeWidth:self.strokeWidth
                                                withGradient:self.gradientSwitch.isOn];
    [self.radialWave disco:self.discoSwitch.isOn];
    [self.radialWave show];
    [self.view sendSubviewToBack:self.radialWave];
}

- (IBAction)discoFlipped:(UISwitch *)sender
{
    [self.radialWave disco:self.discoSwitch.isOn];
}

- (IBAction)pauseAndResumePressed:(UIButton *)sender
{
    // I'm going to take the liberty of checking the title of the button to deduce the state (pause, play).
    // This is not safe, I know, but this is just a demo app ;p
    NSString *title = [sender.titleLabel.text lowercaseString];
    if ([title isEqualToString:@"pause"]) {
        [self.radialWave pauseAnimation];
        [sender setTitle:@"Resume" forState:UIControlStateNormal];
    }
    else if ([title isEqualToString:@"resume"]) {
        [self.radialWave resumeAnimation];
        [sender setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else {
        NSLog(@"Unknown title for pause-and-resume button!! For testing purposes, fix this code or fix the title of the pause-and-resume button to be \'Pause\' and \'Resume\' ;)");
    }
}


#pragma mark - Helpers
- (void)updateProgressRadialWaveView:(BFRadialWaveView *)radialWave
{  
    showSuccess = !showSuccess;
    self.showProgressButton.enabled = NO;
    
    [radialWave updateProgress:0.1f];
    dispatch_main_after(2.0f, ^{
        [radialWave updateProgress:0.3f];
    });
    dispatch_main_after(2.5f, ^{
        [radialWave updateProgress:0.5f];
    });
    dispatch_main_after(2.8f, ^{
        [radialWave updateProgress:0.6f];
    });
    dispatch_main_after(3.7f, ^{
        [radialWave updateProgress:0.93f];
    });
    dispatch_main_after(5.0f, ^{
        [radialWave updateProgress:0.96f];
        if (showSuccess) {
            [radialWave showSuccess];
        }
        else {
            [radialWave showError];
        }
        dispatch_main_after(2.f, ^{
            [self.radialWave removeFromSuperview];
            self.radialWave = [[BFRadialWaveView alloc] initWithView:self.view
                                                             circles:self.numberOfCircles
                                                               color:self.strokeColor
                                                                mode:self.mode
                                                         strokeWidth:self.strokeWidth
                                                        withGradient:self.gradientSwitch.isOn];
            [self.radialWave disco:self.discoSwitch.isOn];
            [self.radialWave show];
            [self.view sendSubviewToBack:self.radialWave];
            self.showProgressButton.enabled = YES;
        });
    });
}

static void dispatch_main_after(NSTimeInterval delay, void (^block)(void))
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}



@end
