//
//  HelloWorldLayer.h
//  SpaceInvaders
//
//  Created by Matt Henkes on 3/28/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
}

@property (strong, nonatomic) UIPopoverController *currentPopover;

// fires a missile projectile
- (void)fireProjectile;

// returns the correct projectile for the ship to fire
- (CCSprite *)getNextProjectile;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

// moves the invader in the correct direction
- (void)moveInvader:(CCSprite *)invader;

// initialize the sprites and position them correctly for the new game
- (void)initializeGame;

// resets the game
- (void)resetGame;

// gives user option to start the game
- (void)startGame;

// gives user the option to end or reset the game
- (void)endGame;

@end
