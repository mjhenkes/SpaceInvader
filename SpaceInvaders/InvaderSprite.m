//
//  InvaderSprite.m
//  SpaceInvaders
//
//  Created by Kevin Schuster on 5/8/12.
//  Copyright (c) 2012 Cerner Corporation. All rights reserved.
//

#import "InvaderSprite.h"

@implementation InvaderSprite

@synthesize movingDirection;

int previousDirection;
int downDistance;

- (id)initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    if (self)
    {
        previousDirection = Right;
        downDistance = 72;
        movingDirection = [[NSNumber alloc] initWithInt:Right];
    }
    
    return self;
}

// sets and returns the next direction for the invader to move
- (NSNumber *)nextDirection
{
    int direction = [movingDirection intValue];
    
    if (direction == Right)
    {
        // hit right side of screen
        movingDirection = [[NSNumber alloc] initWithInt:Down];
    }
    else if (direction == Down)
    {
        if (previousDirection == Left)
        {
            movingDirection = [[NSNumber alloc] initWithInt:Right];
        }
        else 
        {
            movingDirection = [[NSNumber alloc] initWithInt:Left];
        }
    }
    else 
    {
        // hit left side of screen
        movingDirection = [[NSNumber alloc] initWithInt:Down];
    }
    
    previousDirection = direction;
    return movingDirection;
}

// the veritical distance left for the invader to move after subtracting the distance passed in
- (int)downDistanceRemaining:(int)distanceToSubtract
{
    downDistance -= distanceToSubtract;
    if (downDistance <= 0)
    {
        // reset distance for when hit other side of screen
        downDistance = 72;
        return 0;
    }
    
    return downDistance;
}

@end
