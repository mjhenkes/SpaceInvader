//
//  EndGameController.m
//  SpaceInvaders
//
//  Created by Schuster,Kevin on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EndGameController.h"

HelloWorldLayer *delegate;

@implementation EndGameController

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil 
             delegate:(HelloWorldLayer *)delegateObject
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        delegate = delegateObject;
    }
    
    return self;
}

- (IBAction)playAgainPressed:(id)sender 
{
    [delegate resetGame];
}

- (IBAction)exitPressed:(id)sender 
{
    [delegate endGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
