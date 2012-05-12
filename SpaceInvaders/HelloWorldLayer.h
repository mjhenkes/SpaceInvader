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

typedef enum 
{
    Right,
    Down,
    Left
} MovingDirections;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
}

// fires a missile projectile
- (void)fireProjectile;

// checks to see if the projectile has hit any invaders
- (void)checkCollision:(CCSprite *)projectile;

// returns the correct projectile for the ship to fire
- (CCSprite *)getNextProjectile;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

// moves the invader in the correct direction
- (void)moveInvader:(CCSprite *)invader;

// determines the next direction to move the invaders
- (void)determineNextInvaderDirection;

@end
