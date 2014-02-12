//
//  WHDeath.mm
//  JumpNPuke
//
//  Created by Alain Vagner on 28/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WHBasicLayer.h"


static int mode;
static int score;
static int timeBonus;

@implementation WHBasicLayer

+(CCScene *) scene:(int) m
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	mode = m;
	WHBasicLayer * baseLayer = [[WHBasicLayer alloc] init];
	
	[scene addChild: baseLayer];
	
	// return the scene
	return scene;
}

+(CCScene *) scene:(int) m withScore:(int) s andTime:(int)t
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	mode = m;
	score = s;
	timeBonus = t;
	WHBasicLayer * baseLayer = [[WHBasicLayer alloc] init];
	
	[scene addChild: baseLayer];
	
	// return the scene
	return scene;
}


- (id)init {
    self = [super init];
    if (self) {
		// init du background
		NSString * image;
		NSString * son;
		switch (mode) {
			case whGameover:
				image = @"gameover.png";
				son = @"ECGFast.caf";
				break;
			case whCredits:
				image = @"credits.png";
				son = @"";
				break;
			case whWin:
				image = @"win.png";
				son = @"Win.caf";
				break;
				
			/*
			case whNewLevel:
				image = @"levelup.png";
				son = @"Checkpoint.caf";
				break;
			case whHelp:
				image = @"faq.png";
				son = @"";
				break;
			 */
			default:
				break;
		}
		
		CGSize winsize = [[CCDirector sharedDirector] winSize];
		CCSprite * bgpic = [CCSprite spriteWithFile:image];

		
        bgpic.position = ccp(winsize.width/2 , winsize.height/2 );
		[self addChild:bgpic];
		if (mode == whGameover) {
			int total = score + timeBonus * 10;
			CGSize winsize = [CCDirector sharedDirector].winSize;
			int fontSize = 16;
			CCLabelTTF *sLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Points: %d", score] fontName:@"DBLCDTempBlack" fontSize:fontSize];
			[sLabel setColor:ccc3(181, 216, 19)];
			[sLabel setPosition: ccp(winsize.width/2, 60)];
			[self addChild: sLabel];
			CCLabelTTF *tLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Time: %ds x 10", timeBonus] fontName:@"DBLCDTempBlack" fontSize:fontSize];
			[tLabel setColor:ccc3(181, 216, 19)];
			[tLabel setPosition: ccp(winsize.width/2, 40)];
			[self addChild: tLabel];
			CCLabelTTF *fLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total: %d", total] fontName:@"DBLCDTempBlack" fontSize:fontSize];
			[fLabel setColor:ccc3(181, 216, 19)];
			[fLabel setPosition: ccp(winsize.width/2, 20)];
			[self addChild: fLabel];
		}
				
		
        BBAudioManager *audioManager = [BBAudioManager sharedAM];
        [audioManager stopBGM];
		[audioManager playSFX:son];
		self.isTouchEnabled = YES;
		
    }
    return self;
}

- (void)onEnter
{
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
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
	switch (mode) {
		case whGameover:
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHMenuLayer scene]]];
			break;
		case whCredits:
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHMenuLayer scene]]];
			break;
		case whWin:
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHMenuLayer scene]]];
			break;
		default:
			break;
	}
	
	
	
}


@end
