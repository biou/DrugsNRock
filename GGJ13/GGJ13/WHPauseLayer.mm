//
//  WHPauseLayer.mm
//  JumpNPuke
//
//  Created by Alain Vagner on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WHPauseLayer.h"

#import "WHMenuLayer.h"


@implementation WHPauseLayer

@synthesize controlLayer;
@synthesize scene;

- (id)init {
    self = [super init];
    if (self) {
		CGSize winsize = [[CCDirector sharedDirector] winSize];
		
		CCMenuItemImage *menuItem1 = [CCMenuItemImage itemWithNormalImage:@"resume-off.png"
															selectedImage: @"resume-on.png"
																   target:self
																 selector:@selector(menu1)];
		CCMenuItemImage *menuItem2 = [CCMenuItemImage itemWithNormalImage:@"quit-off.png"
															selectedImage: @"quit-on.png"
																   target:self
																 selector:@selector(menu2)];
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, nil];
		// Arrange the menu items vertically
		[myMenu alignItemsVertically];
		
		myMenu.position = ccp(winsize.width/2, winsize.height/2);
        
        CCLayerColor *lc = [CCLayerColor layerWithColor:ccc4(20, 20, 40, 140)];
        [self addChild:lc z:-1];
        
		// add the menu to your scene
		[self addChild:myMenu];
		
        
    }
    return self;
}

- (void)onEnter
{
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director touchDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	
}



-(void)startMenuAction {
	//[self unscheduleUpdate];
	JNPAudioManager *audioManager = [JNPAudioManager sharedAM];
	[audioManager play:jnpSndMenu];	
}

-(void)menu1 {
	[self startMenuAction];
	
	[controlLayer resume];
}

-(void)menu2 {
	[self startMenuAction];	
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [JNPMenuBaseLayer scene]]];    
}






@end
