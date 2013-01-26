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



@interface WHGameScene : CCScene {	
	
}

@property (strong) WHGameLayer * gameLayer;
@property (strong) WHPauseLayer * pauseLayer;
@property (strong) GCDAsyncSocket * socket;

-(void)showPauseLayer;
-(void)hidePauseLayer;


@end
