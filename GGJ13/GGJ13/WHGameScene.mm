//
//  WHGameScene.mm
//  JumpNPuke
//
//  Created by Alain Vagner on 15/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#define whNetworking 1


#import "WHGameScene.h"
#import "WHBasicLayer.h"

#define LEVEL_INITIAL 1


static int gameMode;

@implementation WHGameScene

//@synthesize controlLayer;
@synthesize gameLayer;
@synthesize pauseLayer;
@synthesize socket;
@synthesize ziques;
@synthesize headerLayer;


+(WHGameScene *) scene:(int) m
{

	gameMode = m;	
	// 'scene' is an autorelease object.
	WHGameScene *scene = [WHGameScene node];
	
	// return the scene
	return scene;
}

- (id)init {
    self = [super init];
    if (self) {
	
		BBAudioManager *audioManager = [BBAudioManager sharedAM];
		[audioManager preload];
		//pauseLayer = [JNPPauseLayer node];
		gameLayer = [WHGameLayer node];
        gameLayer.gameScene = self;
		//controlLayer = [JNPControlLayer node];
		//[controlLayer assignGameLayer:gameLayer];

		
		socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		NSError *err = nil;
		if (![socket connectToHost:@"10.45.18.197" onPort:1337 error:&err]) // Asynchronous!
		//if (![socket connectToHost:@"10.45.18.157" onPort:1337 error:&err]) // Asynchronous!
		{
			NSLog(@"I goofed: %@", err);
		}
		
		#ifdef whNetworking
		[self sendSocketWithKey:@"wiener" andValue:@"biou"];
		NSData *term = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        [socket readDataToData:term withTimeout:-1 tag:1];
		if (gameMode == MODE_SOLO) {
			NSLog(@"mode solo");
			[self sendSocketWithKey:@"ready" andValue:@"1"];
		} else {
			NSLog(@"mode multi");
		}
		
		CGSize s = [CCDirector sharedDirector].winSize;		
		
		CCLayer *tmpLayer = [CCLayer node];
		CCSprite *bgpic2 = [CCSprite spriteWithFile:@"pleasewait.png"];
		bgpic2.position = ccp(s.width/2.0, s.height/2);
		[tmpLayer addChild:bgpic2];
		[self addChild:tmpLayer z:1 tag:1];
		#endif
		#ifndef whNetworking
		[self initGame];
		#endif
    }
    return self;
}

-(void)initGame {
	[self setBPM: 80];
	
	//[gameLayer setGameScene:self];
	//[controlLayer setGameScene:self];
	//[pauseLayer setControlLayer:controlLayer];
	currentZique = 0;
	ziques = [NSMutableArray arrayWithCapacity:2];
	NSDictionary * zique1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:70], @"bpm", @"", @"intro", @"ReggaeDev-70bpm.aifc", @"loop", [NSNumber numberWithFloat:82.0], @"loopLen", [NSNumber numberWithFloat:0.0], @"introLen", nil];
	[ziques addObject:zique1];
	NSDictionary * zique2 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:90], @"bpm", @"", @"intro", @"HipHop-90bpm.aifc", @"loop", [NSNumber numberWithFloat:85.0], @"loopLen", [NSNumber numberWithFloat:0.0], @"introLen", nil];
	[ziques addObject:zique2];
	NSDictionary * zique3 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:128], @"bpm", @"ElectroIntro-128bpm.aifc", @"intro", @"ElectroDev-128bpm.aifc", @"loop", [NSNumber numberWithFloat:30.0], @"loopLen", [NSNumber numberWithFloat:8.0], @"introLen", nil];
	[ziques addObject:zique3];
	NSDictionary * zique4 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:150], @"bpm", @"MetalIntro-150bpm.aifc", @"intro", @"MetalDev-150bpm.aifc", @"loop", [NSNumber numberWithFloat:51.0], @"loopLen", [NSNumber numberWithFloat:1.7], @"introLen", nil];
	[ziques addObject:zique4];
	NSDictionary * zique5 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:165], @"bpm", @"", @"intro", @"DNB-165bpm.aifc", @"loop", [NSNumber numberWithFloat:58.0], @"loopLen", [NSNumber numberWithFloat:0.0], @"introLen", nil];
	[ziques addObject:zique5];
	NSDictionary * zique6 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:187], @"bpm", @"TechnoIntro-187bpm.aifc", @"intro", @"TechnoIntro-187bpm.aifc", @"loop", [NSNumber numberWithFloat:26.0], @"loopLen", [NSNumber numberWithFloat:10.0], @"introLen", nil];
	[ziques addObject:zique6];
	
	CCLayer *bgLayer = [CCLayer node];
	CGSize s = [CCDirector sharedDirector].winSize;
	// init du background
	CCSprite *bgpic = [CCSprite spriteWithFile:@"fond-jeu.png"];
	bgpic.position = ccp(bgpic.position.x + s.width/2.0, bgpic.position.y+s.height/2.0);
	//bgpic.opacity = 160;
	//bgpic.color = ccc3(160, 160, 160);
	[bgLayer addChild:bgpic];
	[self addChild:bgLayer z:-10];
	
	headerLayer = [CCLayer node];
	CCSprite *bgpic2 = [CCSprite spriteWithFile:@"header.png"];
	bgpic2.position = ccp(s.width/2.0, s.height-48);
	[headerLayer addChild:bgpic2];
	[self addChild:headerLayer z:+10];
	[self updateHeaderBPM];

	score = 0;
	[self updateHeaderScore];
	
	
	[self ziqueUpdate:LEVEL_INITIAL];
	[self.gameLayer newLevel:currentZique];
	//[gameLayer setAudioManager:audioManager];
	//[self schedule:@selector(simulateBPM:) interval:10];
	
	// add layer as a child to scene
	//[self addChild: pauseLayer z:-15 tag:3];
	[self addChild: gameLayer z:5 tag:1];
	//[self addChild: controlLayer z:10 tag:2];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
        NSLog(@"login request sent");
    else if (tag == 2)
        NSLog(@"Second request sent");
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
		NSLog(@"tag: %ld", tag);
		//NSString* s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSError* error;
		NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
		NSLog(@"data: %@", json);
		NSData *term = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
		[socket readDataToData:term withTimeout:-1 tag:1];
		if ([json objectForKey:@"welcome"] != Nil) {
			NSLog(@"welcome");
		} else if ([json objectForKey:@"start"] != Nil) {
			NSLog(@"start");
			[self removeChildByTag:1 cleanup:true];
			[self initGame];
		} else if ([json objectForKey:@"bpm"] != Nil) {
			rivalBPM = [[json objectForKey:@"bpm"] intValue];
			[self updateHeaderRivalBPM];
		} else if ([json objectForKey:@"totalplayers"] != Nil) {
			NSLog(@"totalplayers %@", [json objectForKey:@"totalplayers"]);
		} else if ([json objectForKey:@"end"] != Nil) {
			if ([[json objectForKey:@"end"] intValue] == 1) {
				NSLog(@"win");
				[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whWin]]];
			} else {
				NSLog(@"lose");
				[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whGameover]]];
			}
			NSLog(@"end");
		} else if ([json objectForKey:@"mange"] != Nil) {
			[self mange:[[json objectForKey:@"mange"] intValue]];
		}
}

-(void)mange:(int)m {
	NSLog(@"mange: %d", m);
	NSLog(@"FIXME Noliv");
	
}

-(void)showPauseLayer
{
	//pauseLayer = [JNPPauseLayer node];
	//[pauseLayer setControlLayer:controlLayer];
	[self addChild: pauseLayer z:15 tag:3];
}


-(void)hidePauseLayer
{
	[self removeChild:pauseLayer cleanup:YES];
}

- (void) bgmUpdate:(ccTime) dt {
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	[audioManager bgmTick:dt];
}


-(void) ziqueUpdate:(int) zique {
    currentZique = zique;
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	[audioManager stopBGM];
	
	NSDictionary * bob = [ziques objectAtIndex:zique];
    
    [audioManager playBGMWithIntro:[bob objectForKey:@"intro"] andLoop:[bob objectForKey:@"loop"]];
    
    musicBPM = [[bob objectForKey:@"bpm"] intValue];

    
    /*
	currentZique = zique;
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	[audioManager stopBGM];
	[self unschedule:@selector(bgmUpdate:)]; // synchroniser
	
	NSDictionary * bob = [ziques objectAtIndex:zique];
	if ([[bob objectForKey:@"introLen"] floatValue] > 0.1) {
		[audioManager nextBGMWithName:[bob objectForKey:@"loop"]];
		[audioManager playBGMWithName: [bob objectForKey:@"intro"]];
		[self schedule:@selector(bgmUpdate:) interval:[[bob objectForKey:@"loopLen"] floatValue] repeat:-1 delay:[[bob objectForKey:@"introLen"] floatValue]];
	} else {
		[audioManager nextBGMWithName:[bob objectForKey:@"loop"]];
		[audioManager playBGMWithName: [bob objectForKey:@"loop"]];
		[self schedule:@selector(bgmUpdate:) interval:[[bob objectForKey:@"loopLen"] floatValue]];
	}
	musicBPM = [[bob objectForKey:@"bpm"] intValue];
     */
}

-(void) incrementBPM:(int)bpm {
	[self setBPM:gameBPM+bpm];
}

-(int) getGameBPM {
    return gameBPM;
}

-(void) updateJaugeWith:(int)statut {
    NSLog(@"Update jauge with statut %d (0,1,2,3)", statut);
    NSLog(@"--> Fix me baby one more time!");
}

-(void) sendDrug:(int)itemType {
    NSLog(@"Envoi de drogue à l’autre connard: type %d",itemType);
	[self sendSocketWithKey:@"faitmanger" andValue:[NSString stringWithFormat:@"%d",itemType]];
}


-(void) setBPM:(int)bpm {
	gameBPM=bpm;
	if ((bpm > 220) || (bpm < 50)) {
		[self sendSocketWithKey:@"bye" andValue:@"1"];
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whGameover]]];
	} else {
		[self sendSocketWithKey:@"mybpm" andValue:[NSString stringWithFormat:@"%d",bpm]];
	}
}

-(void) sendSocketWithKey:(NSString *)key andValue:(NSString *)val {
	NSError* error;
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:val, key, nil];
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:Nil error:&error];
	NSString* str = @"\n\n";
	NSData* fin=[str dataUsingEncoding: [NSString defaultCStringEncoding] ];

	NSMutableData *msgData = [NSMutableData data];
	[msgData appendData:jsonData];
	[msgData appendData:fin];
	
	[socket writeData:msgData withTimeout:-1 tag:1];
}

-(void) simulateBPM:(ccTime) dt {
	[self setBPM: (gameBPM+10)];
	[self updateHeaderBPM];
	NSLog(@"simulate new BPM: %d", gameBPM);
	[self updateMusicBPM];
}

-(int) ziqueWithBPM:(int) bpm {
	if (bpm< 80) {
		return 0;
	} else if (bpm < 105){
		return 1;
	} else if (bpm < 135) {
		return 2;
	} else if (bpm < 158) {
		return 3;
	} else if (bpm < 176) {
		return 4;
	} else {
        return 5;
    }
}

-(void) updateMusicBPM {
	int newZique = [self ziqueWithBPM:gameBPM];
	if (newZique != currentZique) {
			NSLog(@"changeZique %d", newZique);
		if (newZique > currentZique) {
			[self displayMessage:1];
		} else {
			[self displayMessage:0];
		}
		[self ziqueUpdate:newZique];
		[self.gameLayer newLevel:newZique];
	}
	
}

-(void) restartLevel {
    NSLog(@"Restart level");
    int newZique = LEVEL_INITIAL;
    [self ziqueUpdate:newZique];
    [self.gameLayer newLevel:newZique];
}
-(void) updateHeaderBPM {
	[headerLayer removeChildByTag:10 cleanup:true];
	CGSize winsize = [CCDirector sharedDirector].winSize;
	int fontSize = 32;
	CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", gameBPM] fontName:@"DBLCDTempBlack" fontSize:fontSize];
	[label setColor:ccc3(0, 218, 221)];
	[label setPosition: ccp(winsize.width/2+10, winsize.height-30)];
	[headerLayer addChild: label z:1 tag:10];
}

-(void) updateHeaderRivalBPM {
	if (rivalBPM != 0) {
		[headerLayer removeChildByTag:11 cleanup:true];
		CGSize winsize = [CCDirector sharedDirector].winSize;
		int fontSize = 16;
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", rivalBPM] fontName:@"DBLCDTempBlack" fontSize:fontSize];
		[label setColor:ccc3(193, 228, 228)];
		[label setPosition: ccp(270, winsize.height-34)];
		[headerLayer addChild: label z:1 tag:11];
	}
}

-(void) updateHeaderScore {
		[headerLayer removeChildByTag:12 cleanup:true];
		CGSize winsize = [CCDirector sharedDirector].winSize;
		int fontSize = 16;
		CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", score] fontName:@"DBLCDTempBlack" fontSize:fontSize];
		[label setColor:ccc3(181, 216, 19)];
		[label setPosition: ccp(60, winsize.height-34)];
		[headerLayer addChild: label z:1 tag:12];
}

-(void) updateJauge {
	[headerLayer removeChildByTag:12 cleanup:true];
	CGSize winsize = [CCDirector sharedDirector].winSize;
	int fontSize = 16;
	CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", score] fontName:@"DBLCDTempBlack" fontSize:fontSize];
	[label setColor:ccc3(181, 216, 19)];
	[label setPosition: ccp(60, winsize.height-34)];
	[headerLayer addChild: label z:1 tag:12];
}


-(void) displayMessage:(int)m {
		[headerLayer removeChildByTag:13 cleanup:true];
		CGSize winsize = [CCDirector sharedDirector].winSize;
	NSString * image;
	NSString * son;
	switch (m) {
		case 0:
			image = @"slowdown.png";
			son = @"";
		break;
		case 1:
			image = @"speedup.png";
			son = @"";
		break;
		case 2:
			image = @"lsd.png";
			son = @"";
		break;
		case 3:
			image = @"ghb.png";
			son = @"";
		break;
		default:
		break;
	}
	CCSprite * bgpic = [CCSprite spriteWithFile:image];
	
	bgpic.position = ccp(winsize.width/2 , winsize.height/2 );
	[headerLayer addChild:bgpic z:1 tag:13];
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	[audioManager playSFX:son];
	[self scheduleOnce:@selector(removeMessage:) delay:2.0];
}

- (void) removeMessage:(ccTime) dt {
	[headerLayer removeChildByTag:13 cleanup:true];
}


@end
