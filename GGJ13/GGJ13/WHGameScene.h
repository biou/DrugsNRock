//
//  WHGameScene.h
//  JumpNPuke
//
//  Created by Alain Vagner on 15/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBAudioManager.h"
#import "WHPauseLayer.h"
//#import "WHControlLayer.h"
#import "WHGameLayer.h"
#import "GCDAsyncSocket.h"

#import "ObjectAL.h"
#import "OALAudioTrack.h"




@interface WHGameScene : CCScene {	
	int currentZique;
	int musicBPM;
	int gameBPM;
	int rivalBPM;
	int score;
}

@property (strong) WHGameLayer * gameLayer;
@property (strong) WHGameLayer * headerLayer;
@property (strong) WHPauseLayer * pauseLayer;
@property (strong) GCDAsyncSocket * socket;
@property (strong) NSMutableArray * ziques;



-(void)showPauseLayer;
-(void)hidePauseLayer;
-(void) restartLevel;


@end
