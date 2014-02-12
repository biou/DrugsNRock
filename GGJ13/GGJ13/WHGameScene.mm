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
#import "WHItem.h"
#import "AppDelegate.h"
#import "WHMenuLayer.h"

#define LEVEL_INITIAL 1


static int gameMode;

@implementation WHGameScene

//@synthesize controlLayer;
@synthesize gameLayer;
@synthesize pauseLayer;
@synthesize socket;
@synthesize ziques;
@synthesize headerLayer;
@synthesize jauge;
@synthesize jaugeRival;


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

		
		isPlayer1 = YES;
		if (gameMode == MODE_SOLO) {
			NSLog(@"mode solo");
			[self initGame];
			[self schedule:@selector(updateTime) interval:1.0];
		} else {
			NSLog(@"mode multi");
			AppController * delegate = (AppController *) [UIApplication sharedApplication].delegate;
			NSLog(@"navController%@", delegate.navController);
			[[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.navController delegate:self];
			
			ourRandom = arc4random();
			[self setGameState:kGameStateWaitingForMatch];
		}
		/*
		socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		NSError *err = nil;
		NSString * host = [self getServerAddress];

		if (![socket connectToHost:host onPort:1337 error:&err])
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
		 */
		 
    }
    return self;
}

-(void)initGame {	
	//[gameLayer setGameScene:self];
	//[controlLayer setGameScene:self];
	//[pauseLayer setControlLayer:controlLayer];
	currentZique = LEVEL_INITIAL;
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
	NSDictionary * zique6 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:187], @"bpm", @"TechnoIntro-187bpm.aifc", @"intro", @"TechnoDev-187bpm.aifc", @"loop", [NSNumber numberWithFloat:26.0], @"loopLen", [NSNumber numberWithFloat:10.0], @"introLen", nil];
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
	
	jauge = [CCSprite spriteWithSpriteFrameName:@"jauge-0.png"];
	jauge.position = ccp(50, s.height-60);
	[headerLayer addChild: jauge z:11 tag:14];
	jaugeRival = [CCSprite spriteWithSpriteFrameName:@"rival-jauge-0.png"];
	jaugeRival.position = ccp(s.width-50, s.height-60);
	[headerLayer addChild: jaugeRival z:11 tag:15];
	
	gameBPM = 80;
	[self setBPM: 80];

	score = 0;
	scoreFactor = 1;
	secondsSinceStart = 0;
	[self updateHeaderScore];
	[self updateHeaderTime];
	
	
	[self ziqueUpdate:LEVEL_INITIAL];
	[self.gameLayer newLevel:currentZique];
	//[gameLayer setAudioManager:audioManager];
	//[self schedule:@selector(simulateBPM:) interval:10];
	
	// add layer as a child to scene
	//[self addChild: pauseLayer z:-15 tag:3];
	[self addChild: gameLayer z:5 tag:1];
	//[self addChild: controlLayer z:10 tag:2];
}

/*
-(NSString *)getServerAddress {
	NSError *error;
	NSString * file = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"txt"];
	NSString * s = [NSString stringWithContentsOfFile:file encoding:[NSString defaultCStringEncoding] error:&error];
    NSLog(@"server: %@", s);
	s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return s;
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
		} else if ([json objectForKey:@"jauge"] != Nil) {
			[self updateRivalJauge:[[json objectForKey:@"jauge"] intValue]];
			
		}
}

 */
 
-(void)mange:(int)m {
    switch (m) {
        case ItemTypeGHB:
            [self displayMessage:3];
            break;
            
        case ItemTypeLSD:
            [self displayMessage:2];
            break;
            
        default:
            
            [self setBPM: gameBPM + [WHItem effectForType:(ItemType)m]];
            break;
    }
}

-(void)updateTime
{
	secondsSinceStart++;
	[self updateHeaderTime];
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
	NSLog(@"bob: %@", bob);
    
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

-(void) sendDrug:(int)itemType {
    // NSLog(@"Envoi de drogue à l’autre connard: type %d",itemType);

	[self sendMange:itemType];
	//[self sendSocketWithKey:@"faitmanger" andValue:[NSString stringWithFormat:@"%d",itemType]];
}


-(void) setBPM:(int)bpm {
	oldGameBPM = gameBPM;
	gameBPM=bpm;
	[self updateHeaderBPM];
	[self updateMusicBPM];
	if ((bpm > 220) || (bpm < 50)) {
		[self endScene:kEndReasonLose];
		/*
		[self sendSocketWithKey:@"bye" andValue:@"1"];
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whGameover]]];
		 */
	} else {
		[self sendBPM:bpm];
		//[self sendSocketWithKey:@"mybpm" andValue:[NSString stringWithFormat:@"%d",bpm]];
	}
}

/*
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
 */

-(void) simulateBPM:(ccTime) dt {
	[self setBPM: (gameBPM+10)];
	[self updateHeaderBPM];
	NSLog(@"simulate new BPM: %d", gameBPM);
	[self updateMusicBPM];
}

-(int) ziqueWithBPM:(int) bpm {
	if (bpm == oldGameBPM) {
		return currentZique;
	}
	if (bpm > oldGameBPM) {
		NSLog(@"bpm: %d, old: %d", bpm, oldGameBPM);
		return [self ziqueWithBPMUp:bpm];
	} else {
		NSLog(@"bpm: %d, old: %d", bpm, oldGameBPM);		
		return [self ziqueWithBPMDown:bpm];
	}
}
-(int) ziqueWithBPMUp:(int) bpm {
	int val = 0;
	if (bpm< 75) {
		val = 0;
	} else if (bpm < 110){
		val = 1;
	} else if (bpm < 140) {
		val = 2;
	} else if (bpm < 162) {
		val = 3;
	} else if (bpm < 181) {
		val = 4;
	} else {
        val = 5;
    }
	return val;
}

-(int) ziqueWithBPMDown:(int) bpm {
	int val = 0;
	if (bpm< 65) {
		val = 0;
	} else if (bpm < 100){
		val = 1;
	} else if (bpm < 130) {
		val = 2;
	} else if (bpm < 152) {
		val = 3;
	} else if (bpm < 171) {
		val = 4;
	} else {
        val = 5;
    }
	return val;
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
		currentZique = newZique;
		[self scheduleOnce:@selector(executeNewZique) delay:0.1];
	}
	
}

-(void) executeNewZique {
	[self ziqueUpdate:currentZique];
	[self.gameLayer newLevel:currentZique];
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

-(void) setScore:(int)s {
	score = s;
	[self updateHeaderScore];
}

-(void) incrementScore:(int)i {

	i *= scoreFactor;
	if (score+i < 0) {
		[self setScore:0];
	} else {
		[self setScore:score+i];
	}
}

-(int) getTime
{
	return secondsSinceStart;
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

-(void) updateHeaderTime {
	[headerLayer removeChildByTag:16 cleanup:true];
	CGSize winsize = [CCDirector sharedDirector].winSize;
	int fontSize = 16;
	CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%02d:%02d", secondsSinceStart/60, secondsSinceStart % 60] fontName:@"DBLCDTempBlack" fontSize:fontSize];
	[label setColor:ccc3(181, 216, 19)];
	[label setPosition: ccp(winsize.width-60, winsize.height-34)];
	[headerLayer addChild: label z:1 tag:16];
}

-(void) updateJaugeWith:(int)statut {
	scoreFactor = 0x1<<statut;
	NSLog(@"scoreFactor %d", scoreFactor);
	
	if (statut>=0 && statut <4) {
		[jauge setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"jauge-%d.png",statut]]];
	}
	[self sendJauge:statut];
	//[self sendSocketWithKey:@"jauge" andValue:[NSString stringWithFormat:@"%d",statut]];
}

-(void) updateRivalJauge:(int)i {
	if (i>=0 && i <4) {
		[jaugeRival setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"jauge-%d.png",i]]];
	}
}


-(void) displayMessage:(int)m {
		[headerLayer removeChildByTag:13 cleanup:true];
		CGSize winsize = [CCDirector sharedDirector].winSize;
	NSString * image;
	NSString * son;
	switch (m) {
		case 0:
			image = @"slowdown.png";
			son = @"Swoosh4.caf";
		break;
		case 1:
			image = @"speedup.png";
			son = @"Swoosh3.caf";
		break;
		case 2:
			image = @"lsd.png";
			son = @"Swoosh1.caf";
		break;
		case 3:
			image = @"ghb.png";
			son = @"Swoosh2.caf";
			score = 0;
		break;
		default:
		break;
	}
	CCSprite * bgpic = [CCSprite spriteWithFile:image];
	
	bgpic.position = ccp(winsize.width/2 , winsize.height/2 );
	[headerLayer addChild:bgpic z:1 tag:13];
    
    // Create fade out action
    //id actionFadeOut = [CCFadeIn actionWithDuration:1.0f];
    //[bgpic runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1.0f position:ccp(0,0)], actionFadeOut, nil]];
    
	BBAudioManager *audioManager = [BBAudioManager sharedAM];
	[audioManager playSFX:son];
	[self scheduleOnce:@selector(removeMessage:) delay:2.0];
}

- (void) removeMessage:(ccTime) dt {
	[headerLayer removeChildByTag:13 cleanup:true];
}

- (void)lsdGlowingEffect {
    //fixme
    // élément blanc à glower
    CGSize s = [CCDirector sharedDirector].winSize;
    
    CCSprite *sprite = [self rectangleSpriteWithSize:CGSizeMake(s.width, s.height) color:ccc3(255, 255, 255)];
    
    sprite.position = ccp(s.width/2.0f,s.height/2.0f);

    [self addChild:sprite];
}

-(CCSprite *) rectangleSpriteWithSize:(CGSize)cgsize color:(ccColor3B) c
{
    CCSprite *sg = [CCSprite spriteWithFile:@"blank.png"];
    [sg setTextureRect:CGRectMake( 0, 0, cgsize.width, cgsize.height)];
    sg.color = c;
    return sg;
}

#pragma mark multiplayer

- (void)setGameState:(GameState)state {
    
    gameState = state;
    if (gameState == kGameStateWaitingForMatch) {
        NSLog(@"Waiting for match");
    } else if (gameState == kGameStateWaitingForRandomNumber) {
        NSLog(@"Waiting for rand #");
    } else if (gameState == kGameStateWaitingForStart) {
        NSLog(@"Waiting for start");
    } else if (gameState == kGameStateActive) {
        NSLog(@"Active");
    } else if (gameState == kGameStateDone) {
        NSLog(@"Done");
    }
    
}

- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    
    if (gameMode != MODE_SOLO) {
		MessageRandomNumber message;
		message.message.messageType = kMessageTypeRandomNumber;
		message.randomNumber = ourRandom;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
		[self sendData:data];
	}
}

- (void)sendGameBegin {
    if (gameMode != MODE_SOLO) {
		MessageGameBegin message;
		message.message.messageType = kMessageTypeGameBegin;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
		[self sendData:data];
	}
    
}

/*
- (void)sendMove {
    
    MessageMove message;
    message.message.messageType = kMessageTypeMove;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMove)];
    [self sendData:data];
    
}
*/

- (void)sendBPM:(uint32_t) val {
	if (gameMode != MODE_SOLO) {
		MessageBPM message;
		message.message.messageType = kMessageTypeBPM;
		message.number = val;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageBPM)];
		[self sendData:data];
	}
    
}

- (void)sendJauge:(uint32_t) val {
	if (gameMode != MODE_SOLO) {
		MessageJauge message;
		message.message.messageType = kMessageTypeJauge;
		message.number = val;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageJauge)];
		[self sendData:data];
	}
}

- (void)sendMange:(uint32_t) val {
	if (gameMode != MODE_SOLO) {
		MessageMange message;
		message.message.messageType = kMessageTypeMange;
		message.number = val;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageMange)];
		[self sendData:data];
	}
}


- (void)sendGameOver:(BOOL)player1Won {
	if (gameMode != MODE_SOLO) {
		MessageGameOver message;
		message.message.messageType = kMessageTypeGameOver;
		message.player1Won = player1Won;
		NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
		[self sendData:data];
	}
    
}
#pragma mark GCHelperDelegate

- (void)matchStarted {
    CCLOG(@"Match started");
    if (receivedRandom) {
        [self setGameState:kGameStateWaitingForStart];
    } else {
        [self setGameState:kGameStateWaitingForRandomNumber];
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)inviteReceived {
    [self restartTapped:nil];
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[WHGameScene scene:gameMode]]];
    
}

-(void)matchMakingCancelled {
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHMenuLayer scene]]];
}

- (void)matchEnded {
    CCLOG(@"Match ended");
    [[GCHelper sharedInstance].match disconnect];
    [GCHelper sharedInstance].match = nil;
    [self endScene:kEndReasonDisconnect];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    // Store away other player ID for later
    if (otherPlayerID == nil) {
        otherPlayerID = playerID;
    }
    
    Message *message = (Message *) [data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        
        MessageRandomNumber * messageInit = (MessageRandomNumber *) [data bytes];
        CCLOG(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
        bool tie = false;
        
        if (messageInit->randomNumber == ourRandom) {
            CCLOG(@"TIE!");
            tie = true;
            ourRandom = arc4random();
            [self sendRandomNumber];
        } else if (ourRandom > messageInit->randomNumber) {
            CCLOG(@"We are player 1");
            isPlayer1 = YES;
        } else {
            CCLOG(@"We are player 2");
            isPlayer1 = NO;
        }
        
        if (!tie) {
            receivedRandom = YES;
            if (gameState == kGameStateWaitingForRandomNumber) {
                [self setGameState:kGameStateWaitingForStart];
            }
            [self tryStartGame];
        }
        
    } else if (message->messageType == kMessageTypeGameBegin) {
        
        [self setGameState:kGameStateActive];
        [self setupStringsWithOtherPlayerId:playerID];
		NSLog(@"start");
		[self removeChildByTag:1 cleanup:true];
		[self initGame];
		
	} else if (message->messageType == kMessageTypeMange) {
		MessageMange * messageMange = (MessageMange *)[data bytes];
		[self mange:messageMange->number];
		
	} else if (message->messageType == kMessageTypeJauge) {
		MessageJauge * messageJauge = (MessageJauge *) [data bytes];
		[self updateRivalJauge:messageJauge->number];
		
	} else if (message->messageType == kMessageTypeBPM) {
		MessageBPM * messageBPM = (MessageBPM *) [data bytes];
		rivalBPM = messageBPM->number;
		[self updateHeaderRivalBPM];

/*
    } else if (message->messageType == kMessageTypeMove) {
        
        CCLOG(@"Received move");
        
        if (isPlayer1) {
            [player2 moveForward];
        } else {
            [player1 moveForward];
        }
 
 */
    } else if (message->messageType == kMessageTypeGameOver) {
        
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        CCLOG(@"Received game over with player 1 won: %d", messageGameOver->player1Won);
        
        if (messageGameOver->player1Won) {
            [self endScene:kEndReasonLose];
        } else {
            [self endScene:kEndReasonWin];
        }
        
    }
}

- (void)tryStartGame {
    
    if (isPlayer1 && gameState == kGameStateWaitingForStart) {
        [self setGameState:kGameStateActive];
        [self sendGameBegin];
        [self setupStringsWithOtherPlayerId:otherPlayerID];
		[self removeChildByTag:1 cleanup:true];
		[self initGame];
    }
}

- (void)endScene:(EndReason)endReason {
	
    if (gameState == kGameStateDone) return;
    [self setGameState:kGameStateDone];
    
    if (isPlayer1) {
        if (endReason == kEndReasonWin) {
            [self sendGameOver:true];
        } else if (endReason == kEndReasonLose) {
            [self sendGameOver:false];
        }
    }
	if (endReason == kEndReasonWin) {
		NSLog(@"win");
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whWin withScore:score andTime:secondsSinceStart]]];
	} else if (endReason == kEndReasonLose) {
		NSLog(@"lose");
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whGameover withScore:score andTime:secondsSinceStart]]];
	} else if (endReason == kEndReasonDisconnect) {
		NSLog(@"disconnect");
		// FIXME disconnect screen
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene: [WHBasicLayer scene:whDisconnect]]];
	}
	
}

- (void)setupStringsWithOtherPlayerId:(NSString *)playerID {
    
    if (isPlayer1) {
        /*
        player1Label = [CCLabelBMFont labelWithString:[GKLocalPlayer localPlayer].alias fntFile:@"Arial.fnt"];
        [self addChild:player1Label];
        
        GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:playerID];
        player2Label = [CCLabelBMFont labelWithString:player.alias fntFile:@"Arial.fnt"];
        [self addChild:player2Label];
		 */
        
    } else {
        /*
        player2Label = [CCLabelBMFont labelWithString:[GKLocalPlayer localPlayer].alias fntFile:@"Arial.fnt"];
        [self addChild:player2Label];
        
        GKPlayer *player = [[GCHelper sharedInstance].playersDict objectForKey:playerID];
        player1Label = [CCLabelBMFont labelWithString:player.alias fntFile:@"Arial.fnt"];
        [self addChild:player1Label];
        */
    }
    
}


@end
