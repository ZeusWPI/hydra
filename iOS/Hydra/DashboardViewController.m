//
//  MasterViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 20/03/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "DashboardViewController.h"
#import "RestoViewController.h"
#import "SchamperViewController.h"
#import "InfoViewController.h"

@implementation DashboardViewController

- (void)viewDidLoad
{
    requiredMoves = [[NSArray alloc] initWithObjects:
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionUp],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionUp],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionDown],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionDown],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionLeft],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionRight],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionLeft],
                     [NSNumber numberWithInt:UISwipeGestureRecognizerDirectionRight],
                     @"b", @"a", nil];

    // Testing
    //[self showInfo:nil];
}

- (void)viewDidUnload
{
    gestureRecognizer = nil;
    codeField = nil;
    requiredMoves = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self configureDetectionForMove:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Button actions

- (IBAction)showNews:(id)sender {
    if([sender tag] == 5) {
        DLog(@"Dashboard switching to GSR");
    } else {
        DLog(@"Dashboard switching to News");
    }
}

- (IBAction)showActivities:(id)sender {
    DLog(@"Dashboard switching to Activities");
}

- (IBAction)showInfo:(id)sender {
    DLog(@"Dashboard switching to Info");
	InfoViewController *c = [[InfoViewController alloc] init];
	[self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showResto:(id)sender {
    DLog(@"Dashboard switching to Resto");
    UIViewController *c = [[RestoViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)showSchamper:(id)sender {
    DLog(@"Dashboard switching to Schamper");
    UIViewController *c = [[SchamperViewController alloc] init];
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark - Surprise feature

- (void)configureDetectionForMove:(NSUInteger)move
{
    DLog(@"Surprise progress: %d/%d", move, [requiredMoves count]);

    // TODO: replace by something cool
    if (move == [requiredMoves count]) {
        ULog(@"Congratulations, you won the game!");
        move = 0;
    }
    movesPerformed = move;

    id nextMove = [requiredMoves objectAtIndex:move];
    if ([nextMove isKindOfClass:[NSNumber class]]) {
        if (!gestureRecognizer) {
            gestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
            [gestureRecognizer addTarget:self action:@selector(handleGesture:)];
            [[self view] addGestureRecognizer:gestureRecognizer];

            [codeField removeFromSuperview];
            [codeField resignFirstResponder];
            codeField = nil;
        }

        UISwipeGestureRecognizerDirection direction = [nextMove intValue];
        [gestureRecognizer setDirection:direction];
    }
    else if ([nextMove isKindOfClass:[NSString class]]) {
        if (!codeField) {
            codeField = [[UITextField alloc] init];
            [[self view] addSubview:codeField];
            [codeField setHidden:YES];
            [codeField setDelegate:self];
            [codeField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [codeField setReturnKeyType:UIReturnKeyDone];

            [[self view] removeGestureRecognizer:gestureRecognizer];
            gestureRecognizer = nil;
        }

        // Store the string to be matched in the textfield, for easy comparison
        [codeField becomeFirstResponder];
        [codeField setText:nextMove];
    }
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer
{
    [self configureDetectionForMove:(movesPerformed + 1)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self configureDetectionForMove:0];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:[textField text]]) {
        [self configureDetectionForMove:(movesPerformed + 1)];
    }
    else {
        [self configureDetectionForMove:0];
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self configureDetectionForMove:0];
    return NO;
}

@end
