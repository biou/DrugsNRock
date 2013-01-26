//
//  WHDeath.mm
//  JumpNPuke
//
//  Created by Alain Vagner on 28/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WHBasicLayer.h"


static int mode;

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


- (id)init {
    self = [super init];
    if (self) {
		// init du background
		NSString * image;
		NSString * son;
		switch (mode) {
			case whGameover:
				image = @"gameover.png";
				son = @"Game_Over.caf";
				break;
			case whCredits:
				image = @"creditsImg.png";
				son = @"";
				break;
			case whNewLevel:
				image = @"levelup.png";
				son = @"Checkpoint.caf";
				break;
			case whHelp:
				image = @"faq.png";
				son = @"";
				break;
			default:
				break;
		}
		
		CGSize winsize = [[CCDirector sharedDirector] winSize];
		CCSprite *bgpic = Nil;
		if (mode == whHelp && fabs(568.0 - winsize.width) <1 ) {
			bgpic = [CCSprite spriteWithFile:@"faq-i5.png"];
		} else if (mode == whCredits && fabs(568.0 - winsize.width) <1 ) {
			bgpic = [CCSprite spriteWithFile:@"creditsImg-i5.png"];
		} else {
			bgpic = [CCSprite spriteWithFile:image];
		}
		
		
        bgpic.position = ccp(winsize.width/2 , winsize.height/2 );
		[self addChild:bgpic];
		
		
		if (mode == whGameover) {
			WHScore * s = [WHScore sharedInstance];
			int t = [s getScore];
			s.vomis = [NSMutableArray array];
			[[GCHelper sharedInstance] reportScore:t forCategory:@"WHScore1"];
		}
		
		if (mode != whCredits && mode != whHelp)
		{
			WHScore * s = [WHScore sharedInstance];
			int newScore = [s getScore] + [s getTime]*100;
			NSString * str = nil;
			int fontSize = 0;
			CGPoint labelPos;
			
			if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
				fontSize = 21;
				labelPos = ccp(winsize.width/2, winsize.height-20);
			} else {
				fontSize = 42;
				labelPos = ccp(winsize.width/2, winsize.height-50);
			}
			
			if (mode == whGameover) {
				str = [NSString stringWithFormat:@"Score: %d", [s getScore]];
			} else {
				str = [NSString stringWithFormat:@"Score: %d + %d x 100 = %d", [s getScore], [s getTime], newScore];
				[s setScore:newScore];
			}
			CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"Chalkduster" fontSize:fontSize];
			[label setPosition: labelPos];
			[self addChild: label];
		}
		
		if (mode == whNewLevel)
		{
			WHScore * s = [WHScore sharedInstance];
			[s incrementLevel];
			int t = [s getLevel];
			[s setTime:90];
			int fontSize = 0;
			CGPoint labelPos;
			
			if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
				fontSize = 32;
				labelPos = ccp(winsize.width/2, 20);
			} else {
				fontSize = 64;
				labelPos = ccp(winsize.width/2, 50);
			}
			NSString * str = [NSString stringWithFormat:@"Level %d", t];
			CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"Chalkduster" fontSize:fontSize];
			[label setPosition: labelPos];
			[self addChild: label];
		}
		
		
		
		
		
		
        WHAudioManager *audioManager = [WHAudioManager sharedAM];
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
		case WHGameover:
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHMenuBaseLayer scene]]];
			break;
		case WHCredits:
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHMenuBaseLayer scene]]];
			break;
		case WHHelp:
            [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHGameScene node]]];
			break;
		case WHNewLevel:
			[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[WHGameScene node]]];
			break;
		default:
			break;
	}
	
	
	
}


@end
