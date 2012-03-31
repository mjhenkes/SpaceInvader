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
CCSprite *projectile;

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
        
        projectile = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile];
        
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

- (void) nextFrame:(ccTime)dt {
    invader.position = ccp( invader.position.x + 100*dt, invader.position.y );
    if (invader.position.x > [[CCDirector sharedDirector] winSize].width +32) {
        invader.position = ccp( -32, invader.position.y );
    }
    
    CGRect projectileRect = CGRectMake(
                                   projectile.position.x - (projectile.contentSize.width/2), 
                                   projectile.position.y - (projectile.contentSize.height/2), 
                                   projectile.contentSize.width, 
                                   projectile.contentSize.height);

    CGRect invaderRect = CGRectMake(
                                   invader.position.x - (invader.contentSize.width/2), 
                                   invader.position.y - (invader.contentSize.height/2), 
                                   invader.contentSize.width, 
                                   invader.contentSize.height);

    if (CGRectIntersectsRect(projectileRect, invaderRect)) 
    {
        [self removeChild:invader cleanup:YES];
        [self unschedule:_cmd];
    }
}

- (void) registerWithTouchDispatcher
{
    CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
                                         
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

- (void)fireProjectile
{
    //CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
    
    CGPoint turretPosition = [turret position];
    
    [projectile setPosition:turretPosition];
    
    
    //[self addChild:projectile];
    
    CGPoint endPoint = CGPointMake(turretPosition.x, 1000);
    
    [projectile runAction:[CCMoveTo actionWithDuration:1 position:endPoint]];
    //[projectile runAction:[CCSequence actions:
    //                       [CCMoveTo actionWithDuration:1 position:endPoint],
    //                       [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
    //                       nil]];
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
