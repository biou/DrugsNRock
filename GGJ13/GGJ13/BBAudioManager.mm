//
//  BBAudioManager.m
//  inspiration PawAppsExample_SimpleAudioEngine
//
//  Created by Vincent on 27/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BBAudioManager.h"
#import "SimpleAudioEngine.h"
#import "CCNode.h"
#import "BBGCDSingleton.h"

@implementation BBAudioManager

#pragma mark Singleton

static BBAudioManager *sharedAM = nil;


+ (BBAudioManager *) sharedAM
{
	DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
		return sharedAM = [[self alloc] init];
	});
}


#pragma mark AudioManager

-(id) init
{
	if( (self=[super init])) {
		// list all sound effects
		NSArray * caf = [[NSBundle mainBundle] pathsForResourcesOfType:@".caf" inDirectory:@"."];
		self.sfxFiles = [NSMutableArray arrayWithCapacity:[caf count]];
		for (NSString * s in caf) {
			[self.sfxFiles addObject:[s lastPathComponent]];
		}
		
		// list all background music files
		NSArray * aifc = [[NSBundle mainBundle] pathsForResourcesOfType:@".aifc" inDirectory:@"."];
		self.bgmFiles = [NSMutableArray arrayWithCapacity:[aifc count]];
		for (NSString * s in aifc) {
			[self.bgmFiles addObject:[s lastPathComponent]];
		}
    }
   	return self;
}

// playMusic
-(void) playBGMWithName:(NSString *) name {
	if ([self.bgmFiles containsObject:name]) {
		self.currentBGM = [[SimpleAudioEngine sharedEngine] playEffect:name];
	} else {
		NSLog(@"--BGM not found:%@", name);
	}
}

// set next loop to play
-(void) nextBGMWithName:(NSString *) name {
    self.nextBGM = name;
}

-(void) stopBGM {
	[[SimpleAudioEngine sharedEngine] stopEffect:self.currentBGM];
}

-(void) pauseBGM {
	[[SimpleAudioEngine sharedEngine] stopEffect:self.currentBGM];
}

-(void) resumeBGM {
	[self playBGMWithName:self.nextBGM];
}


-(void) playRandomSfx:(NSArray *) names {
	int count = [names count];
	if (count != 0) {
		int r = (arc4random() % count);
		[self playSFX:[names objectAtIndex:r]];
	} else {
		NSLog(@"playRandomSfx: list is empty");
	}
}

// play
-(void) playSFX:(NSString *)soundType {
	if (![soundType isEqual:@""]) {
		if ([self.sfxFiles containsObject:soundType]) {
			[[SimpleAudioEngine sharedEngine] playEffect:soundType];
		} else {
			NSLog(@"--Sfx not found:%@", soundType);
		}
	}
	
}

// preload files
-(void) preload {
	for (NSString* s in self.sfxFiles) {
		[[SimpleAudioEngine sharedEngine] preloadEffect:s];
	}
	for (NSString* s in self.bgmFiles) {
		[[SimpleAudioEngine sharedEngine] preloadEffect:s];
	}
}

-(void)bgmTick:(float)dt {
	
	[self playBGMWithName:self.nextBGM];
}


@end
