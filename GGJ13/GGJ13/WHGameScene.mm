//
//  WHGameScene.mm
//  JumpNPuke
//
//  Created by Alain Vagner on 15/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WHGameScene.h"


@implementation WHGameScene

//@synthesize controlLayer;
@synthesize gameLayer;
@synthesize pauseLayer;
@synthesize socket;
@synthesize ziques;

- (id)init {
    self = [super init];
    if (self) {
	
		BBAudioManager *audioManager = [BBAudioManager sharedAM];
		[audioManager preload];
		//pauseLayer = [JNPPauseLayer node];
		gameLayer = [WHGameLayer node];
		//controlLayer = [JNPControlLayer node];
		//[controlLayer assignGameLayer:gameLayer];

		
		
		//[gameLayer setGameScene:self];
		//[controlLayer setGameScene:self];
		//[pauseLayer setControlLayer:controlLayer];
		currentZique = 0;
		ziques = [NSMutableArray arrayWithCapacity:2];
		NSDictionary * zique1 = [NSDictionary dictionaryWithObjectsAndKeys:@"70", @"bpm", @"", @"intro", @"ReggaeDev-70bpm.aifc", @"loop", [NSNumber numberWithFloat:82.0], @"loopLen", [NSNumber numberWithFloat:0.0], @"introLen", nil];
		[ziques addObject:zique1];
		NSDictionary * zique2 = [NSDictionary dictionaryWithObjectsAndKeys:@"150", @"bpm", @"MetalIntro-150bpm.aifc", @"intro", @"MetalDev-150bpm.aifc", @"loop", [NSNumber numberWithFloat:51.0], @"loopLen", [NSNumber numberWithFloat:1.7], @"introLen", nil];
		[ziques addObject:zique2];
		
		CCLayer *bgLayer = [CCLayer node];
		CGSize s = [CCDirector sharedDirector].winSize;		
		// init du background
		CCSprite *bgpic = [CCSprite spriteWithFile:@"fondpapier.png"];
		bgpic.position = ccp(bgpic.position.x + s.width/2.0, bgpic.position.y+s.height/2.0);
		//bgpic.opacity = 160;
		bgpic.color = ccc3(160, 160, 160);
		[bgLayer addChild:bgpic];
		// [self addChild:bgLayer z:-10];

		
		
		[self ziqueUpdate:0];
		//[gameLayer setAudioManager:audioManager];
		//[self schedule:@selector(plop:) interval:5];
		
		// add layer as a child to scene
		//[self addChild: pauseLayer z:-15 tag:3];
		[self addChild: gameLayer z:5 tag:1];
		//[self addChild: controlLayer z:10 tag:2];
		
		socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		NSError *err = nil;
		if (![socket connectToHost:@"10.45.18.197" onPort:1337 error:&err]) // Asynchronous!
		//if (![socket connectToHost:@"10.45.18.157" onPort:1337 error:&err]) // Asynchronous!
		{
			NSLog(@"I goofed: %@", err);
		}
		NSError* error;
		NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:@"biou", @"wiener", nil];
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
		[socket writeData:jsonData withTimeout:-1 tag:1];
		NSData *term = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        [socket readDataToData:term withTimeout:-1 tag:1];
    }
    return self;
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
}



@end
