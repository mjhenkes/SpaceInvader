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


#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
// Here is the scene it is automatially created by the template
+(CCScene *) scene
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
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init])) {
        
        CGFloat midX = [[CCDirector sharedDirector] winSize].width/2;
		
        //Create sprites with file here
        //sprites are global for convinence. Could 
		turret = [[CCSprite alloc] initWithFile:@"turret.png"];
        //[[CCDirector sharedDirector] winSize].width +32
        //set turret positon to middle of screen
        [turret setPosition:CGPointMake(midX + 32, 50)];
        [self addChild:turret];
        
        allInvaders = [[NSMutableArray alloc] init];
        
        int xOffset = -144;
        int invaderSpace = -10;
        for (int i = 0; i < 5; i++)
        {
            CCSprite *invader = [CCSprite spriteWithFile:@"invader.png"];
            [invader setPosition:CGPointMake(midX + xOffset + invaderSpace, [[CCDirector sharedDirector] winSize].height -32)];
            [self addChild:invader];
            [allInvaders addObject:invader];
            xOffset += 72;
            invaderSpace += 5;
        }
        
        allProjectiles = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 5; i++)
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
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

// Code to run for each frame executed
- (void) nextFrame:(ccTime)dt 
{
    for (int i = 0; i < 5; i++)
    {
        // move each invader on screen
        CCSprite *invader = [allInvaders objectAtIndex:i];
        if (invader != nil)
        {
            invader.position = ccp( invader.position.x + 100*dt, invader.position.y );
            if (invader.position.x > [[CCDirector sharedDirector] winSize].width +32) 
            {
                invader.position = ccp( -32, invader.position.y );
            }
        }
    }
    
    // move each projectile up if fired
    for (int i = 0; i < 5; i++)
    {
        [self moveProjectile:[allProjectiles objectAtIndex:i]];
    }
}

// moves the projectile upwards and destroys the invader if rects intersect
- (void)moveProjectile:(CCSprite *)projectile
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

    for (int i = 0; i < 5; i++)
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
    if (projectileIndex == 5)
    {
        projectileIndex = 0;
    }
    
    return projectile;
}


- (void) registerWithTouchDispatcher
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
    
    [projectile setPosition:turretPosition];

    CGPoint endPoint = CGPointMake(turretPosition.x, 1000);
    
    [projectile runAction:[CCMoveTo actionWithDuration:1 position:endPoint]];
}

-(void)spriteMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    //[self removeChild:sprite cleanup:YES];
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
-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
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
