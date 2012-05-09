//
//  InvaderSprite.h
//  SpaceInvaders
//
//  Created by Kevin Schuster on 5/8/12.
//  Copyright (c) 2012 Cerner Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum 
{
    Right,
    Down,
    Left
} MovingDirections;

@interface InvaderSprite : CCSprite

// the current direction the invader is moving
@property (strong, nonatomic) NSNumber *movingDirection;

// sets and returns the next direction for the invader to move
- (NSNumber *)nextDirection;

// the veritical distance left for the invader to move after subtracting the distance passed in
- (int)downDistanceRemaining:(int)distanceToSubtract;

@end
