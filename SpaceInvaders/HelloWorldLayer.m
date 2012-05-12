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
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"invaderSpriteMap.plist"];
        
        NSMutableArray *invaderFrames = [NSMutableArray array];
        NSMutableArray *pingFrames = [NSMutableArray array];
        NSMutableArray *vicFrames = [NSMutableArray array];
        
        for (int i = 1; i <= 2; ++i)
        {
            NSString *invaderPath = [NSString stringWithFormat:@"invader02_%d.png", i];
            
            [invaderFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] 
                                    spriteFrameByName:invaderPath]];
            [pingFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] 
                                    spriteFrameByName: [NSString stringWithFormat:@"invaderPing%d.png", i]]];
            [vicFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] 
                                    spriteFrameByName: [NSString stringWithFormat:@"invaderVic%d.png", i]]];
        }
        
        CCAnimation *invaderAnim = [CCAnimation animationWithSpriteFrames:invaderFrames delay:1];
        CCAnimation *pingAnim = [CCAnimation animationWithSpriteFrames:pingFrames delay:0.0333f];
        CCAnimation *vicAnim = [CCAnimation animationWithSpriteFrames:vicFrames delay:0.0333f];
        
        currentHorizontalMoveDistance = horizontalMoveDistance;
        currentVerticalMoveDistance = vertiicalMoveDistance;
        
        allInvaders = [[NSMutableArray alloc] init];
        
        int xOffset = 72;
        int invaderSpace = 0;
        
        for (int i = 0; i < numberOfInvaders; i++)
        {
            CCSprite *invader = [CCSprite spriteWithFile:@"invader02_1.png"];
            [invader setPosition:CGPointMake(xOffset + invaderSpace, [[CCDirector sharedDirector] winSize].height -32)];
            [invader runAction:[CCRepeatForever actionWithAction: 
                                [CCAnimate actionWithAnimation:invaderAnim]]];
            
            [self addChild:invader];
            [allInvaders addObject:invader];
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
    
    for (int i = 0; i < numberOfInvaders; i++)
    {
        // move each invader on screen
        [self moveInvader:[allInvaders objectAtIndex:i]];
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

    for (int i = 0; i < numberOfInvaders; i++)
    {
        CCSprite *invader = [allInvaders objectAtIndex:i];
        
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
    //ccTime time = 1;
    [self fireProjectile];
    [self schedule:@selector(fireProjectile) interval:1];
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
    location.y = 50;
    
    [turret stopAllActions];
    [turret runAction:[CCMoveTo actionWithDuration:1 position:location]];
    
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
//	CGPoint touchLocation = [touch locationInView: [touch view]];
//	CGPoint prevLocation = [touch previousLocationInView: [touch view]];
//    
//	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
//	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
//    
//	CGPoint diff = ccpSub(touchLocation,prevLocation);
//    diff.y = 0;
//    
//	//CCNode *node = [self getChildByTag:kTagNode];
//	CGPoint currentPos = [turret position];
//	[turret setPosition: ccpAdd(currentPos, diff)];
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
    location.y = 50;
    
    [turret stopAllActions];
    [turret runAction:[CCMoveTo actionWithDuration:1 position:location]];
}
                                         
                                         
@end
