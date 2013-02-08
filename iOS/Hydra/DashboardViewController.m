//
//  MasterViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "DashboardViewController.h"
#import "NewsViewController.h"
#import "ActivityViewController.h"
#import "InfoViewController.h"
#import "RestoMenuController.h"
#import "UrgentViewController.h"
#import "SchamperViewController.h"
#import "PreferencesController.h"
#import "TestFlight.h"

#define EasterEggEnabled 0

@interface DashboardViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UISwipeGestureRecognizer *gestureRecognizer;
@property (nonatomic, unsafe_unretained) UITextField *codeField;
@property (nonatomic, strong) NSArray *requiredMoves;
@property (nonatomic, assign) NSUInteger movesPerformed;

@end

@implementation DashboardViewController

- (void)viewDidLoad
{
#if TestFlightEnabled
    self.feedbackButton.hidden = NO;
#endif

#if EasterEggEnabled
    self.requiredMoves = @[
        @(UISwipeGestureRecognizerDirectionUp), @(UISwipeGestureRecognizerDirectionUp),
        @(UISwipeGestureRecognizerDirectionDown), @(UISwipeGestureRecognizerDirectionDown),
        @(UISwipeGestureRecognizerDirectionLeft), @(UISwipeGestureRecognizerDirectionRight),
        @(UISwipeGestureRecognizerDirectionLeft), @(UISwipeGestureRecognizerDirectionRight),
        @"b", @"a"
    ];
    self.codeField = nil;
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

#if EasterEggEnabled
    [self configureMoveDetectionForMove:0];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Home");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button actions

- (IBAction)showNews:(id)sender
{
    DLog(@"Dashboard switching to News");
    NewsViewController *c = [[NewsViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showActivities:(id)sender
{
    DLog(@"Dashboard switching to Activities");
    ActivityViewController *c = [[ActivityViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showInfo:(id)sender
{
    DLog(@"Dashboard switching to Info");
	InfoViewController *c = [[InfoViewController alloc] init];
	[self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showResto:(id)sender
{
    DLog(@"Dashboard switching to Resto");
    UIViewController *c = [[RestoMenuController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showUrgent:(id)sender
{
    DLog(@"Dashboard switching to Urgent");
    UIViewController *c = [[UrgentViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showSchamper:(id)sender
{
    DLog(@"Dashboard switching to Schamper");
    UIViewController *c = [[SchamperViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showFeedbackView:(id)sender
{
    [TestFlight openFeedbackView];
}

-(IBAction)showPreferences:(id)sender
{
    DLog(@"Dashboard switching to Preferences");
    UIViewController *c = [[PreferencesController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark - Surprise feature

#if EasterEggEnabled
- (void)configureMoveDetectionForMove:(NSUInteger)move
{
    if (move == [self.requiredMoves count]) {
    	UrgentPlayer *urgentPlayer = [UrgentPlayer sharedPlayer];
        [urgentPlayer start];
        
        UILog(@"Congratulations, you won the game!");
        move = 0;
    }
    self.movesPerformed = move;

    id nextMove = (self.requiredMoves)[move];
    if ([nextMove isKindOfClass:[NSNumber class]]) {
        if (!self.gestureRecognizer) {
            self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
            [self.gestureRecognizer addTarget:self action:@selector(handleGesture:)];
            [self.view addGestureRecognizer:self.gestureRecognizer];

            [self.codeField removeFromSuperview];
            [self.codeField resignFirstResponder];
            self.codeField = nil;
        }

        self.gestureRecognizer.direction = [nextMove intValue];
    }
    else if ([nextMove isKindOfClass:[NSString class]]) {
        if (!self.codeField) {
            self.codeField = [[UITextField alloc] init];
            self.codeField.hidden = YES;
            self.codeField.delegate = self;
            self.codeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.codeField.returnKeyType = UIReturnKeyDone;
            [self.view addSubview:self.codeField];

            [self.view removeGestureRecognizer:self.gestureRecognizer];
            self.gestureRecognizer = nil;
        }

        // Store the string to be matched in the textfield, for easy comparison
        self.codeField.text = nextMove;
        [self.codeField becomeFirstResponder];
    }
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer
{
    [self configureMoveDetectionForMove:(self.movesPerformed + 1)];
    DLog(@"Surprise progress: %d/%d", self.movesPerformed, [self.requiredMoves count]);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self configureMoveDetectionForMove:0];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string caseInsensitiveCompare:textField.text] == NSOrderedSame) {
        [self configureMoveDetectionForMove:(self.movesPerformed + 1)];
        DLog(@"Surprise progress: %d/%d", self.movesPerformed, [self.requiredMoves count]);
    }
    else {
        [self configureMoveDetectionForMove:0];
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self configureMoveDetectionForMove:0];
    return NO;
}
#endif

@end
