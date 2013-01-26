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

- (id)init {
    self = [super init];
    if (self) {
	
		//pauseLayer = [JNPPauseLayer node];
		gameLayer = [WHGameLayer node];
		//controlLayer = [JNPControlLayer node];
		//[controlLayer assignGameLayer:gameLayer];


        /**** parallax ****/
        /*
		parallax = [CCParallaxScrollNode node];
        CCSprite *clouds1 = [CCSprite spriteWithFile:@"paralaxe1.png"];
        CCSprite *clouds2 = [CCSprite spriteWithFile:@"paralaxe2.png"];
        CCSprite *clouds1bis = [CCSprite spriteWithFile:@"paralaxe1.png"];
        CCSprite *clouds2bis = [CCSprite spriteWithFile:@"paralaxe2.png"];
        float totalWidth = 4 * clouds1.contentSize.width;
        [parallax addChild:clouds1 z:0 Ratio:ccp(1.3,1) Pos:ccp(0,0) ScrollOffset:ccp(totalWidth,0)];
        [parallax addChild:clouds2 z:0 Ratio:ccp(0.6,1) Pos:ccp(0,0) ScrollOffset:ccp(totalWidth,0)];
        [parallax addChild:clouds1bis z:0 Ratio:ccp(1.3,1) Pos:ccp(clouds1.contentSize.width,0) ScrollOffset:ccp(totalWidth,0)];
        [parallax addChild:clouds2bis z:0 Ratio:ccp(0.6,1) Pos:ccp(clouds2.contentSize.width,0) ScrollOffset:ccp(totalWidth,0)];
        // Add to layer, sprite, etc.
        [self addChild:parallax z:-1];	
		*/
		
		//[gameLayer setGameScene:self];
		//[controlLayer setGameScene:self];
		//[pauseLayer setControlLayer:controlLayer];
		
		
		
		CCLayer *bgLayer = [CCLayer node];
		CGSize s = [CCDirector sharedDirector].winSize;		
		// init du background
		CCSprite *bgpic = [CCSprite spriteWithFile:@"fondpapier.png"];
		bgpic.position = ccp(bgpic.position.x + s.width/2.0, bgpic.position.y+s.height/2.0);
		//bgpic.opacity = 160;
		bgpic.color = ccc3(160, 160, 160);
		[bgLayer addChild:bgpic];
		// [self addChild:bgLayer z:-10];

		
		
		BBAudioManager *audioManager = [BBAudioManager sharedAM];

		//[gameLayer setAudioManager:audioManager];
		
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

@end
