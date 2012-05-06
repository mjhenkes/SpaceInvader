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
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
}

// fires a missile projectile
- (void)fireProjectile;

// moves the missile projectile forward
- (void)moveProjectile:(CCSprite *)projectile;

// returns the correct projectile for the ship to fire
- (CCSprite *)getNextProjectile;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
