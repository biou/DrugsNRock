//
//  WHMenuLayer.mm
//  plop
//
//  Created by Alain Vagner on 22/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WHMenuLayer.h"


//JNPAudioManager * audioManager;
CCMenu * myMenu;

@implementation WHMenuLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	
	WHMenuLayer * baseLayer = [[WHMenuLayer alloc] init];
	
	[scene addChild: baseLayer];
	
	// return the scene
	return scene;
}

- (id)init {
    self = [super init];
    if (self) {
		// background music
        
        CCSprite * logo = [CCSprite spriteWithFile: @"fond-menu.png"];
		CGSize winsize = [[CCDirector sharedDirector] winSize];
        logo.position = ccp(winsize.width/2 , winsize.height/2 );
		[self addChild:logo z:0];	
		
		[[GCHelper sharedInstance] setAuthChangeDelegate:self];
		
		// http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:lesson_3._menus_and_scenes
        
		[self setupMenu];

        
		// increment level		
		
    }
    return self;
}

- (void) dealloc
{
	[[GCHelper sharedInstance] setAuthChangeDelegate:nil];
	
}


-(void)setupMenu {
	if (myMenu != nil) {
		[self removeChild:myMenu cleanup:NO];
	}

	CGSize winsize = [[CCDirector sharedDirector] winSize];

	CCMenuItemImage *menuItem1 = [CCMenuItemImage itemWithNormalImage:@"start-over.png"
														selectedImage: @"start.png"
															   target:self
															 selector:@selector(menu1)];
	CCMenuItemImage *menuItem2 = [CCMenuItemImage itemWithNormalImage:@"credits.png"
														selectedImage: @"credits-over.png"
															   target:self
															 selector:@selector(menu2)];
	
	CCMenuItemImage *menuItem4 = [CCMenuItemImage itemWithNormalImage:@"scores.png"
														selectedImage: @"scores-over.png"
															   target:self
															 selector:@selector(menu4)];
	
	
	myMenu = [CCMenu menuWithItems:menuItem1, nil];
	BOOL userAuth = [[GCHelper sharedInstance] isUserAuthenticated];
	if (userAuth) {
		NSLog(@"user authenticated, we add the menu item\n");
		[myMenu addChild:menuItem4];
	}
	[myMenu addChild:menuItem2];
	
	// Arrange the menu items vertically
	[myMenu alignItemsVertically];
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		myMenu.position = ccp(winsize.width/2, 125);
	} else {
		myMenu.position = ccp(winsize.width/2, 280);
	}

	// add the menu to your scene
	[self addChild:myMenu];
	
	
}

-(void)menu1 {
	[self startMenuAction];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHGameScene node]]];
    
}

-(void)menu2 {
	[self startMenuAction];	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whCredits]]];
}

-(void)menu3 {
	[self startMenuAction];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whHelp]]];
}

-(void)menu4 {
	[self startMenuAction];
	[[GCHelper sharedInstance] displayLeaderboard];
}

-(void)startMenuAction {
	[self unscheduleAllSelectors];
	[self unscheduleUpdate];
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	// play a sound
}

-(void)handleAuthChange:(BOOL) n {
	[self setupMenu];
}

@end
