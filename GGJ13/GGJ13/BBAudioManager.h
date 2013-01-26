//
//  BBAudioManager.h
//  inspiration PawAppsExample_SimpleAudioEngine
//
//  Created by Vincent on 27/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"
#import "CCNode.h"


@interface BBAudioManager : CCNode {
	
}

// preload all sfx and bgm files
-(void) preload;

// background music management

// must be scheduled to the length of a loop
-(void) bgmTick:(float)dt;

// the file will be looped until nextBGMWithName is called with another file name
-(void) playBGMWithName:(NSString *)name;
-(void) nextBGMWithName:(NSString *)name;

-(void) stopBGM;
-(void) pauseBGM;
-(void) resumeBGM;


// play an sfx file
-(void) playSFX:(NSString *)soundType;
// play a random sfx file in a list
-(void) playRandomSfx:(NSArray *) names;


+(BBAudioManager *) sharedAM;
@property (strong) NSMutableArray * sfxFiles;
@property (strong) NSMutableArray * bgmFiles;
@property (strong, nonatomic) NSString * nextBGM;
@property (nonatomic) ALuint currentBGM;


@end
