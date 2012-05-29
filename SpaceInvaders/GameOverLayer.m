//
//  GameOverLayer.m
//  SpaceInvaders
//
//  Created by Tyler Biethman on 5/27/12.
//  Copyright 2012 Cerner Corporation. All rights reserved.
//

#import "GameOverLayer.h"
#import "HelloWorldLayer.h"

@implementation GameOverLayer

// Helper class method that creates a Scene with the GameOverLayer as the only child.
// Here is the scene it is automatially created by the template
+ (CCScene *)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an GameOverLayer object.
	GameOverLayer *layer = [GameOverLayer node];
	
	// add layer as a child to scene
	[scene addChild:layer];
	
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
        self.isTouchEnabled = YES;
        
        [self createMenu];
	}
    
	return self;
}

- (void)createMenu
{    
    // Create some menu items
    CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"retry_default.png"
                                                         selectedImage:@"retry_selected.png"
                                                                target:self
                                                              selector:@selector(retry)];
    
    CCMenuItemImage * menuItem2 = [CCMenuItemImage itemFromNormalImage:@"quit_default.png"
                                                         selectedImage:@"quit_selected.png"
                                                                target:self
                                                              selector:@selector(endGame)];
    
    // Create a menu and add your menu items to it
    CCMenu * myMenu = [CCMenu menuWithItems:menuItem1,menuItem2,nil];
    
    // Arrange the menu items vertically
    [myMenu alignItemsVertically];
    
    // add the menu to your scene
    [self addChild:myMenu];
}

- (void)retry
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void)endGame
{
    while ([[CCDirector sharedDirector] runningScene]) 
    {
        [[CCDirector sharedDirector] popScene];
    }
    
    [[[CCDirector sharedDirector] runningThread] release];
    exit(0);
}

@end
