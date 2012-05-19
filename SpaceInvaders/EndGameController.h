//
//  EndGameController.h
//  SpaceInvaders
//
//  Created by Schuster,Kevin on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelloWorldLayer.h"

@interface EndGameController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil 
             delegate:(HelloWorldLayer *)delegate;
- (IBAction)playAgainPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;

@end
