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

#import "StartGameContoller.h"
#import "EndGameController.h"

CCSprite *turret;

//projectiles
NSMutableArray *allProjectiles;
NSMutableArray *allEnemyProjectiles;
int projectileIndex = 0;
int enemyProjectileIndex = 0;
int numberOfProjectiles = 2;
int numberOfEnemyProjectiles = 100;
CGFloat enemyFireProbability = 0.02;

// general
int leftMargin = 32;
int rightMargin;

// invaders
NSMutableArray *allInvaderColumns;
int numberOfInvaderColumns = 10;
int invaderOffset = 22;
int invaderXMoveTimeInterval = 360;
int invaderYMoveTimeInterval = 10;
int invaderFrameCount = 0;
CGPoint invaderVelocity;
int invaderYMoveDistance = 44;

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
// Here is the scene it is automatially created by the template
+ (CCScene *)scene
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
	if ((self=[super init])) 
    {
        srand(time(NULL));
        
        [self startGame];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

// initialize the sprites and position them correctly for the new game
- (void)initializeGame
{
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
    
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
        NSString *invaderPath = [NSString stringWithFormat:@"invader02_%d", i];
        
        [invaderFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] 
                                   spriteFrameByName:invaderPath]];
        [pingFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] 
                                spriteFrameByName: [NSString stringWithFormat:@"invaderPing%d", i]]];
        [vicFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] 
                               spriteFrameByName: [NSString stringWithFormat:@"invaderVic%d", i]]];
    }
    
    CCAnimation *invaderAnim = [CCAnimation animationWithSpriteFrames:invaderFrames delay:1];
    CCAnimation *pingAnim = [CCAnimation animationWithSpriteFrames:pingFrames delay:1];
    CCAnimation *vicAnim = [CCAnimation animationWithSpriteFrames:vicFrames delay:1];
    
    allInvaderColumns = [[NSMutableArray alloc] init];
    
    int xOffset = leftMargin;
    
    for (int i = 0; i < numberOfInvaderColumns; i++)
    {
        NSMutableArray *invaderColumn = [[NSMutableArray alloc] init];
        [allInvaderColumns addObject:invaderColumn];
        
        int yOffset = 0;
        
        CCSprite *invader02 = [CCSprite spriteWithFile:@"invader02_1.png"];
        CGRect invader02BoundingBox = [invader02 boundingBox];
        [invader02 setPosition:CGPointMake(xOffset + [invader02 contentSize].width/2, [[CCDirector sharedDirector] winSize].height - [invader02 contentSize].height/2 - 0)];
        [invader02 runAction:[CCRepeatForever actionWithAction: 
                              [CCAnimate actionWithAnimation:invaderAnim]]];
        [self addChild:invader02];
        [invaderColumn addObject:invader02];
        
        yOffset += invader02BoundingBox.size.height + invaderOffset;
        
        CCSprite *invaderVic = [CCSprite spriteWithFile:@"invaderVic1.png"];
        [invaderVic setPosition:CGPointMake(xOffset + [invader02 contentSize].width/2, [[CCDirector sharedDirector] winSize].height - [invader02 contentSize].height/2 - yOffset)];
        [invaderVic runAction:[CCRepeatForever actionWithAction: 
                               [CCAnimate actionWithAnimation:vicAnim]]];
        [self addChild:invaderVic];
        [invaderColumn addObject:invaderVic];
        
        yOffset += invader02BoundingBox.size.height + invaderOffset;
        
        CCSprite *invaderPing = [CCSprite spriteWithFile:@"invaderPing1.png"];
        [invaderPing setPosition:CGPointMake(xOffset + [invader02 contentSize].width/2, [[CCDirector sharedDirector] winSize].height - [invader02 contentSize].height/2 - yOffset)];
        [invaderPing runAction:[CCRepeatForever actionWithAction: 
                                [CCAnimate actionWithAnimation:pingAnim]]];
        [self addChild:invaderPing];
        [invaderColumn addObject:invaderPing];
        
        xOffset += invader02BoundingBox.size.width + invaderOffset;
    }
    
    rightMargin = [[CCDirector sharedDirector] winSize].width - leftMargin;
    
    allProjectiles = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numberOfProjectiles; i++)
    {
        CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile];
        [allProjectiles addObject:projectile];
    }
    
    allEnemyProjectiles = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numberOfEnemyProjectiles; i++)
    {
        CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
        [self addChild:projectile];
        [allEnemyProjectiles addObject:projectile];
    }
    
    [self schedule:@selector(nextFrame:)];
}

- (void)startGame
{
    if (![[CCDirector sharedDirector] isPaused])
    {
        StartGameContoller *controller = [[StartGameContoller alloc] initWithNibName:@"StartGame" 
                                                                              bundle:nil 
                                                                            delegate:self];
        
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [[CCDirector sharedDirector] presentModalViewController:controller animated:YES];
    }
    else 
    {
        // from replacing the scene during reset
        [self initializeGame];
    }
}

- (void)resetGame
{
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    [[CCDirector sharedDirector] resume];
}

- (void)endGame
{
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
    [[CCDirector sharedDirector] popScene];
    [[[CCDirector sharedDirector] runningThread] release];
    exit(0);
}

#pragma mark initization

// on "dealloc" you need to release all your retained objects
- (void)dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (NSMutableArray *)frontlineInvaders
{
    NSMutableArray *frontline = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [allInvaderColumns count]; i++) 
    {
        if ([[allInvaderColumns objectAtIndex:i] count] > 0) 
        {
            [frontline addObject:[[allInvaderColumns objectAtIndex:i] lastObject]];
        }        
    }
    
    return frontline;
}

// Code to run for each frame executed
- (void)nextFrame:(ccTime)dt 
{
    [self moveAllInvaders];
    
    [self fireEnemyProjectile];
    
    [self checkInvaderCollision];
    
    [self checkShipCollision];
}


#pragma mark Invader Movement

// determines the next direction for the invaders to move
- (void)determineInvaderVelocity
{   
    //Is Time Up?
    if (invaderFrameCount == 0) {
        //March
        if (invaderVelocity.x == 0) {
            
            NSMutableArray *frontlineInvaders = [self frontlineInvaders];
            CGPoint leftCorner = [[frontlineInvaders objectAtIndex:0] position];
            leftCorner.x -= [[frontlineInvaders objectAtIndex:0] contentSize].width/2;
        
            CGPoint rightCorner = [[frontlineInvaders lastObject] position];
            rightCorner.x += [[frontlineInvaders lastObject] contentSize].width/2;
        
            CGFloat rightDistance = rightMargin - rightCorner.x;
            CGFloat leftDistance = leftCorner.x - leftMargin;
            CGFloat distance = 0;
            
            // Move in the direction of the greater distance.
            if (rightDistance > leftDistance) {
                distance = rightDistance;
            }
            else {
                distance = -leftDistance;
            }
            
            invaderVelocity = CGPointMake(distance/invaderXMoveTimeInterval, 0);
            
            invaderFrameCount = invaderXMoveTimeInterval;
        }
        //Decend
        else
        {
            invaderVelocity = CGPointMake(0, -invaderYMoveDistance/invaderYMoveTimeInterval);
            
            invaderFrameCount = invaderYMoveTimeInterval;
        }
    }
    else {
        invaderFrameCount--;
    }
}

- (void)moveAllInvaders
{
    [self determineInvaderVelocity];
    
    for (int x = 0; x < [allInvaderColumns count]; x++)
    {
        for (int y = 0; y < [[allInvaderColumns objectAtIndex:x] count]; y++) 
        {
            // move each invader on screen
            [self moveInvader:[[allInvaderColumns objectAtIndex:x] objectAtIndex:y]];                        
        }        
    }
}

// Move the invader in the correct direction
- (void)moveInvader:(CCSprite *)invader
{
    if (invader != nil)
    {
        invader.position = CGPointMake(invader.position.x + invaderVelocity.x, invader.position.y + invaderVelocity.y);
    }
}

#pragma mark Collision Detection

- (BOOL)checkCollisionOfSprite:(CCSprite *)sprite1 withSprite:(CCSprite *)sprite2
{
    BOOL collide = NO;
    if (sprite1 && sprite2)
    {
        if (CGRectIntersectsRect([sprite1 boundingBox], [sprite2 boundingBox])) {
            collide = YES;
        }
    }
    
    return collide;
}

- (void)checkShipCollision
{
    NSMutableArray *collideableObjects = [NSMutableArray arrayWithArray:allEnemyProjectiles];
    [collideableObjects addObjectsFromArray:[self frontlineInvaders]];
    
    for (int i = 0; i < [collideableObjects count]; i++)
    {
        if ([self checkCollisionOfSprite:[collideableObjects objectAtIndex:i] withSprite:turret]) 
        {
            [self removeChild:turret cleanup:YES];
            turret = nil;
            [self unschedule:_cmd];
        
            // end game popup
            [[CCDirector sharedDirector] pause];
            
            EndGameController *controller = [[EndGameController alloc] initWithNibName:@"EndGame" 
                                                                                bundle:nil 
                                                                              delegate:self];
            
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [[CCDirector sharedDirector] presentModalViewController:controller animated:YES];
        }
    }
}

// checks to see if the projectile has hit any invaders
- (void)checkInvaderCollision
{
    for (int i = 0; i < numberOfProjectiles; i++)
    {
        CCSprite *projectile = [allProjectiles objectAtIndex:i];
        
        for (int x = 0; x < [allInvaderColumns count]; x++)
        {
            for (int y = 0; y < [[allInvaderColumns objectAtIndex:x] count]; y++)
            {
                CCSprite *invader = [[allInvaderColumns objectAtIndex:x] objectAtIndex:y];
            
                if (invader)
                {
                    // if the projectile and the invaders rect intersect, we have hit the invader and can remove it
                    if ([self checkCollisionOfSprite:projectile withSprite:invader]) 
                    {
                        [self removeChild:invader cleanup:YES];
                        [self unschedule:_cmd];
                    
                        [[allInvaderColumns objectAtIndex:x] removeObject:invader];
                    
                        invader = nil;
                    
                        [self removeChild:projectile cleanup:YES];
                        projectile.position = CGPointMake(-1, -1);
                    }
                }
            }
        }
    }
}

#pragma mark Projectile Creation

// will return the next projectile to fire for the ship
- (CCSprite *)getNextProjectile
{
    CCSprite *projectile = [allProjectiles objectAtIndex:projectileIndex];
    
    projectileIndex++;
    if (projectileIndex == numberOfProjectiles)
    {
        projectileIndex = 0;
    }
    
    if (![[self children] containsObject:projectile]) 
    {
        [self addChild:projectile];
    }
        
    return projectile;
}

// will return the next projectile to fire for the ship
- (CCSprite *)getNextEnemyProjectile
{
    CCSprite *projectile = [allEnemyProjectiles objectAtIndex:enemyProjectileIndex];
    
    enemyProjectileIndex++;
    if (enemyProjectileIndex == numberOfEnemyProjectiles)
    {
        enemyProjectileIndex = 0;
    }
    
    return projectile;
}

// fires a projectile
- (void)fireProjectile
{
    CGPoint turretPosition = [turret position];
    turretPosition.y += [turret contentSize].height/2;
    
    CCSprite *projectile = [self getNextProjectile];
    
    if ([projectile numberOfRunningActions] > 0)
    {
        return;
    }
    
    [projectile setPosition:turretPosition];

    CGPoint endPoint = CGPointMake(turretPosition.x, turretPosition.y + [[CCDirector sharedDirector] winSize].height);
    
    [projectile runAction:[CCMoveTo actionWithDuration:2 position:endPoint]];
}

- (void)fireEnemyProjectile
{
    for (CCSprite *bottomInvader in [self frontlineInvaders]) 
    {
        int random = rand() % 100;
    
        CGFloat fireCalculations = random;
    
        CGFloat difference = fireCalculations - (enemyFireProbability * 100);
    
        if (difference < 0)
        {                    
            [self fireEnemyProjectileFromInvader:bottomInvader];
        }
    }
}

- (void)fireEnemyProjectileFromInvader:(CCSprite *)invaderSprite
{
    CGPoint invaderPosition = [invaderSprite position];
    invaderPosition.y -= [invaderSprite contentSize].height/2;
    
    CCSprite *projectile = [self getNextEnemyProjectile];
    
    if ([projectile numberOfRunningActions] > 0)
    {
        return;
    }
    
    [projectile setPosition:invaderPosition];
    
    CGPoint endPoint = CGPointMake(invaderPosition.x, invaderPosition.y - [[CCDirector sharedDirector] winSize].height);
    
    [projectile runAction:[CCMoveTo actionWithDuration:3 position:endPoint]];
}

#pragma mark Touch Events

- (void)registerWithTouchDispatcher
{
    CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
                    
// when the user taps the screen, fire a missile and move the ship the correct direction
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGRect shipRect = [turret boundingBox];
    //Inflate rect
    shipRect.size.width += 120;
    shipRect.size.height += 60;
    shipRect.origin.x -= 60;
    shipRect.origin.y -= 120;
    
    
    CGPoint touchPoint = [self convertTouchToNodeSpace:touch];
    
    if (CGRectContainsPoint(shipRect, touchPoint)) 
    {
        [self fireProjectile];
        [self schedule:@selector(fireProjectile) interval:1];
        
        return YES;
    }
    
    //ccTime time = 1;
    
    return NO;
}

- (void)spriteMoveFinished:(id)sender 
{
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self unschedule:@selector(fireProjectile)];
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
