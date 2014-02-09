//
//  JNPDeath.h
//  JumpNPuke
//
//  Created by Alain Vagner on 28/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BBAudioManager.h"
//#import "BBGCHelper.h"
//#import "WHScore.h"
#import "WHMenuLayer.h"
#import "WHGameScene.h"



#define whGameover 0
#define whCredits 1
#define whWin 2
#define whNewLevel 2
//#define whHelp 3

@interface WHBasicLayer : CCLayer {

}

// returns a CCScene that contains the WHBasicLayer layer as the only child
+(CCScene *) scene:(int)m;

@end
