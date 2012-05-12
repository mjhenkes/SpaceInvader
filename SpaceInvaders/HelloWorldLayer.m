//
//  HelloWorldLayer.m
//  SpaceInvaders
//
//  Created by Matt Henkes on 3/28/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

NSMutableArray *allInvaders;
NSMutableArray *allProjectiles;
CCSprite *turret;
int projectileIndex = 0;
int horizontalSpeed = 3;
int verticalSpeed = 12;
int numberOfInvaders = 7;
int numberOfProjectiles = 2;
int currentDirection = Right;
int previousDirection = Right;
int horizontalMoveDistance = 420;
int vertiicalMoveDistance = 36;
int currentHorizontalMoveDistance = 0;
int currentVerticalMoveDistance = 0;

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
// Here is the scene it is automatially created by the template
+(CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
- (id)init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if ((self=[super init])) {
        
        CGFloat midX = [[CCDirector sharedDirector] winSize].width/2;
		
        //Create sprites with file here
        //sprites are global for convinence. Could 
		turret = [[CCSprite alloc] initWithFile:@"turret.png"];
        [turret setPosition:CGPointMake(midX + 32, 50)];
        [self addChild:turret];
        
        currentHorizontalMoveDistance = horizontalMoveDistance;
        currentVerticalMoveDistance = vertiicalMoveDistance;
        
        allInvaders = [[NSMutableArray alloc] init];
        
        int xOffset = 72;
        int invaderSpace = 0;
        
        for (int i = 0; i < numberOfInvaders; i++)
        {
            NSMutableArray *invaderColumn = [[NSMutableArray alloc] init];
            [allInvaders addObject:invaderColumn];
            
            int yOffset = 0;
            
            CCSprite *invader02 = [CCSprite spriteWithFile:@"invader02_1.png"];
            [invader02 setPosition:CGPointMake(xOffset + invaderSpace, [[CCDirector sharedDirector] winSize].height -32 - yOffset)];
            [self addChild:invader02];
            [invaderColumn addObject:invader02];
            
            yOffset += 72;
            
            CCSprite *invaderVic = [CCSprite spriteWithFile:@"invaderVic1.png"];
            [invaderVic setPosition:CGPointMake(xOffset + invaderSpace, [[CCDirector sharedDirector] winSize].height -32 - yOffset)];
            [self addChild:invaderVic];
            [invaderColumn addObject:invaderVic];
            
            yOffset += 72;
            
            CCSprite *invaderPing = [CCSprite spriteWithFile:@"invaderPing1.png"];
            [invaderPing setPosition:CGPointMake(xOffset + invaderSpace, [[CCDirector sharedDirector] winSize].height -32 - yOffset)];
            [self addChild:invaderPing];
            [invaderColumn addObject:invaderPing];
            
            xOffset += 72;
            invaderSpace += 5;
        }
        
        allProjectiles = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < numberOfProjectiles; i++)
        {
            CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
            [self addChild:projectile];
            [allProjectiles addObject:projectile];
        }
        
        
        [self schedule:@selector(nextFrame:)];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void)dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

// Code to run for each frame executed
- (void)nextFrame:(ccTime)dt 
{
    [self determineNextInvaderDirection];
    
    for (int x = 0; x < numberOfInvaders; x++)
    {
        for (int y = 0; y < 3; y++)
        {
            // move each invader on screen
            [self moveInvader:[[allInvaders objectAtIndex:x] objectAtIndex:y]];
        }
    }
    
    // move each projectile up if fired
    for (int i = 0; i < numberOfProjectiles; i++)
    {
        [self checkCollision:[allProjectiles objectAtIndex:i]];
    }
}

// determines the next direction for the invaders to move
- (void)determineNextInvaderDirection
{
    if (currentDirection == Right || currentDirection == Left)
    {
        if (currentHorizontalMoveDistance <= 0)
        {
            currentHorizontalMoveDistance = horizontalMoveDistance;
            previousDirection = currentDirection;
            currentDirection = Down;
        }
        else 
        {
            currentHorizontalMoveDistance -= horizontalSpeed;
        }
    }
    else // (currentDirection == Down)
    {
        if (currentVerticalMoveDistance <= 0)
        {
            currentVerticalMoveDistance = vertiicalMoveDistance;
            
            if (previousDirection == Right)
            {
                previousDirection = currentDirection;
                currentDirection = Left;
            }
            else 
            {
                previousDirection = currentDirection;
                currentDirection = Right;
            }
        }
        else 
        {
            currentVerticalMoveDistance -= verticalSpeed;
        }
    } 
}

// Move the invader in the correct direction
- (void)moveInvader:(CCSprite *)invader
{
    if (invader != nil)
    {
        if (currentDirection == Right)
        {
            // keep moving right
            invader.position = ccp(invader.position.x + horizontalSpeed, invader.position.y);
        }
        else if (currentDirection == Left)
        {
            // keep moving left
            invader.position = ccp(invader.position.x - horizontalSpeed, invader.position.y);
        }
        else // (direction == Down)
        {
            // keep moving down
            invader.position = ccp(invader.position.x, invader.position.y - verticalSpeed);
        }
    }
}

// checks to see if the projectile has hit any invaders
- (void)checkCollision:(CCSprite *)projectile
{
    if (projectile == nil)
    {
        return;
    }

    CGRect projectileRect = CGRectMake(
                                       projectile.position.x - (projectile.contentSize.width/2), 
                                       projectile.position.y - (projectile.contentSize.height/2), 
                                       projectile.contentSize.width, 
                                       projectile.contentSize.height);

    for (int x = 0; x < numberOfInvaders; x++)
    {
        for (int y = 0; y < 3; y++)
        {
            // move each invader on screen
            CCSprite *invader = [[allInvaders objectAtIndex:x] objectAtIndex:y];
            
            if (invader != nil)
            {
                CGRect invaderRect = CGRectMake(
                                                invader.position.x - (invader.contentSize.width/2), 
                                                invader.position.y - (invader.contentSize.height/2), 
                                                invader.contentSize.width,
                                                invader.contentSize.height);
            
                // if the projectile and the invaders rect intersect, we have hit the invader and can remove it
                if (CGRectIntersectsRect(projectileRect, invaderRect)) 
                {
                    [self removeChild:invader cleanup:YES];
                    invader = nil;
                    [self unschedule:_cmd];
                }
            }
        }
    }
}

// will return the next projectile to fire for the ship
- (CCSprite *)getNextProjectile
{
    CCSprite *projectile = [allProjectiles objectAtIndex:projectileIndex];
    
    projectileIndex++;
    if (projectileIndex == numberOfProjectiles)
    {
        projectileIndex = 0;
    }
    
    return projectile;
}

- (void)registerWithTouchDispatcher
{
    CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
                    
// when the user taps the screen, fire a missile and move the ship the correct direction
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGRect shipRect = CGRectMake(turret.position.x - turret.contentSize.width / 2 - 60, turret.position.y - turret.contentSize.height / 2 - 30, turret.contentSize.width + 120, turret.contentSize.height + 60);
    
    CGPoint touchPoint = [self convertTouchToNodeSpace:touch];
    
    if (CGRectContainsPoint(shipRect, touchPoint)) 
    {
        [self fireProjectile];
        [self schedule:@selector(fireProjectile) interval:1];
    }
    
    //ccTime time = 1;
    
    return YES;
}

// fires a projectile
- (void)fireProjectile
{
    CGPoint turretPosition = [turret position];
    
    CCSprite *projectile = [self getNextProjectile];
    
    if ([projectile numberOfRunningActions] > 0)
    {
        return;
    }
    
    [projectile setPosition:turretPosition];

    CGPoint endPoint = CGPointMake(turretPosition.x, 1000);
    
    [projectile runAction:[CCMoveTo actionWithDuration:1 position:endPoint]];
}

- (void)spriteMoveFinished:(id)sender 
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self unschedule:@selector(fireProjectile)];
//    CGPoint location = [self convertTouchToNodeSpace:touch];
//    location.y = 50;
//    
//    [turret stopAllActions];
//    [turret runAction:[CCMoveTo actionWithDuration:1 position:location]];
}
-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    location.y = 50;
    
    turret.position = location;        
}
                                         
                                         
@end
