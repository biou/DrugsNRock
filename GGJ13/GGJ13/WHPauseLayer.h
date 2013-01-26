//
//  WHPauseLayer.h
//  JumpNPuke
//
//  Created by Alain Vagner on 13/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
//#import "WHAudioManager.h"

@class WHControlLayer;
@class WHGameScene;


@interface WHPauseLayer : CCLayer {
		
}

@property (strong) id controlLayer;
@property (strong) id scene;
- (id)init;

@end
