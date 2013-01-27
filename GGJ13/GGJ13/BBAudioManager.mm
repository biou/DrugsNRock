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

-(void) playBGMWithIntro:(NSString *)introName andLoop:(NSString *)loopName {
    
    NSLog(@"IntroName %@",introName);
    
    self.introTrack = [OALAudioTrack track];
    self.mainTrack = [OALAudioTrack track];
    
    
    if ([introName length]==0) {
        [self.mainTrack preloadFile:loopName];
        self.mainTrack.numberOfLoops = -1;
        [self.mainTrack play];
    } else if ([loopName length] ==0) {
		[self.introTrack preloadFile:introName];
		[self.introTrack play];
	} else {
        [self.introTrack preloadFile:introName];
        [self.mainTrack preloadFile:loopName];
        
        self.mainTrack.numberOfLoops = -1;
        
        // Play the main track at volume 0 to secure the hardware channel for it.
        self.mainTrack.volume = 0;
        [self.mainTrack play];
        
        // Start the intro playing on a software channel, then stop the main track.
        [self.introTrack play];
        [self.mainTrack stop];
        
        // Have the main track start again after the intro track's duration elapses.
        NSTimeInterval playAt = self.mainTrack.deviceCurrentTime + self.introTrack.duration;
        [self.mainTrack playAtTime:playAt];
        self.mainTrack.volume = 1;
    }
}




// set next loop to play
-(void) nextBGMWithName:(NSString *) name {
    self.nextBGM = name;
}

-(void) stopBGM {
	// [[SimpleAudioEngine sharedEngine] stopEffect:self.currentBGM];
    [self.mainTrack stop];
    [self.introTrack stop];
}

-(void) pauseBGM {
    [self stopBGM];
	// [[SimpleAudioEngine sharedEngine] stopEffect:self.currentBGM];
}

-(void) resumeBGM {
	// [self playBGMWithName:self.nextBGM];
    NSLog(@"RESUME TA MERE");
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
    /*
	for (NSString* s in self.bgmFiles) {
		[[SimpleAudioEngine sharedEngine] preloadEffect:s];
	}
     */
}

-(void)bgmTick:(float)dt {
	
	[self playBGMWithName:self.nextBGM];
}


@end
