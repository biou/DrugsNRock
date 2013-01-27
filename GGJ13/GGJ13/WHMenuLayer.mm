//
//  WHMenuLayer.mm
//  plop
//
//  Created by Alain Vagner on 22/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WHMenuLayer.h"
#import "WHGameScene.h"


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
        
        CCSprite * logo = [CCSprite spriteWithFile: @"fondstart.png"];
		CGSize winsize = [[CCDirector sharedDirector] winSize];
        logo.position = ccp(winsize.width/2 , winsize.height/2 );
		[self addChild:logo z:0];	
		
		//[[GCHelper sharedInstance] setAuthChangeDelegate:self];
		
		// http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:lesson_3._menus_and_scenes
        
		[self setupMenu];

        
		// increment level		
		
    }
    return self;
}

- (void) dealloc
{
	//[[GCHelper sharedInstance] setAuthChangeDelegate:nil];
	
}


-(void)setupMenu {
	if (myMenu != nil) {
		[self removeChild:myMenu cleanup:NO];
	}

	CGSize winsize = [[CCDirector sharedDirector] winSize];

	CCMenuItemImage *menuItem1 = [CCMenuItemImage itemWithNormalImage:@"solo-off.png"
														selectedImage: @"solo-on.png"
															   target:self
															 selector:@selector(menu1)];
	CCMenuItemImage *menuItem4 = [CCMenuItemImage itemWithNormalImage:@"battle-off.png"
														selectedImage: @"battle-on.png"
															   target:self
															 selector:@selector(menu4)];
	CCMenuItemImage *menuItem2 = [CCMenuItemImage itemWithNormalImage:@"credits-off.png"
														selectedImage: @"credits-on.png"
															   target:self
															 selector:@selector(menu2)];

	
	myMenu = [CCMenu menuWithItems:menuItem1, nil];
	/*
	BOOL userAuth = [[GCHelper sharedInstance] isUserAuthenticated];
	if (userAuth) {
		NSLog(@"user authenticated, we add the menu item\n");
		[myMenu addChild:menuItem4];
	}
	*/
	[myMenu addChild:menuItem4];
	[myMenu addChild:menuItem2];
	
	// Arrange the menu items vertically
	[myMenu alignItemsVertically];
	[myMenu alignItemsVerticallyWithPadding:1];
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
		myMenu.position = ccp(winsize.width/2, 120);
	} else {
		myMenu.position = ccp(winsize.width/2, 280);
	}

	// add the menu to your scene
	[self addChild:myMenu];
    BBAudioManager *am = [BBAudioManager sharedAM];
	// play a sound here
	[ am playBGMWithIntro:@"MenuIntro.aifc" andLoop:@"MenuDev.aifc"];
}

-(void)menu1 {
	[self startMenuAction];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHGameScene scene:MODE_SOLO]]];
    
}

-(void)menu2 {
	[self startMenuAction];	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whCredits]]];
}

/*
-(void)menu3 {
	[self startMenuAction];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whHelp]]];
}
 */

-(void)menu4 {
	[self startMenuAction];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHGameScene scene:MODE_MULTI]]];
	//[[GCHelper sharedInstance] displayLeaderboard];
}

-(void)startMenuAction {
	[self unscheduleAllSelectors];
	[self unscheduleUpdate];
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	// play a sound
	[audioManager playSFX:@"Click.caf"];
	[audioManager stopBGM];
	
}

/*
-(void)handleAuthChange:(BOOL) n {
	[self setupMenu];
}
 */

@end
