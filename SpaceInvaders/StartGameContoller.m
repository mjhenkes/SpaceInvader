//
//  StartGamepContoller.m
//  SpaceInvaders
//
//  Created by Schuster,Kevin on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StartGameContoller.h"

HelloWorldLayer *delegate;

@implementation StartGameContoller

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

- (IBAction)startGamePressed:(id)sender 
{
    [delegate initializeGame];
}

- (IBAction)exitGamePressed:(id)sender 
{
    [delegate endGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
