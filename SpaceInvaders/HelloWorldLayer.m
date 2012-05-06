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

CCSprite *turret;
CCSprite *invader;
CCSprite *projectile1;
CCSprite *projectile2;
CCSprite *projectile3;
CCSprite *projectile4;
CCSprite *projectile5;
int projectileIndex = 0;


#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
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
		
		turret = [[CCSprite alloc] initWithFile:@"turret.png"];
        //[[CCDirector sharedDirector] winSize].width +32
        [turret setPosition:CGPointMake(midX + 32, 50)];
        [self addChild:turret];
        
        invader = [CCSprite spriteWithFile:@"invader.png"];
        [invader setPosition:CGPointMake(midX, [[CCDirector sharedDirector] winSize].height -32)];
        [self addChild:invader];
        
        projectile1 = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile1];
        
        projectile2 = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile2];
        
        projectile3 = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile3];
        
        projectile4 = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile4];
        
        projectile5 = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile5];
        
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
    if (invader != nil)
    {
        // moves invader from left to right
        invader.position = ccp( invader.position.x + 100*dt, invader.position.y );
        if (invader.position.x > [[CCDirector sharedDirector] winSize].width +32) {
            invader.position = ccp( -32, invader.position.y );
        }
    }
    
    // move each projectile up if fired
    [self moveProjectile:(projectile1)];
    [self moveProjectile:(projectile2)];
    [self moveProjectile:(projectile3)];
    [self moveProjectile:(projectile4)];
    [self moveProjectile:(projectile5)];
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

// will return the next projectile to fire for the ship
- (CCSprite *)getNextProjectile
{
    CCSprite *projectile = nil;
    if (projectileIndex == 0)
    {
        projectile = projectile1;
    }

    if (projectileIndex == 1)
    {
        projectile = projectile2;
    }

    if (projectileIndex == 2)
    {
        projectile = projectile3;
    }
    
    if (projectileIndex == 3)
    {
        projectile = projectile4;
    }
    
    if (projectileIndex == 4)
    {
        projectile = projectile5;
    }
    
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
