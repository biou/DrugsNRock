//
//  WHMenuLayer.h
//  plop
//
//  Created by Alain Vagner on 22/01/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCMenu.h"
#import "BBAudioManager.h"
//#import "BBGCHelper.h"
#import "WHGameScene.h"
#import "WHBasicLayer.h"


@interface WHMenuLayer : CCLayer {
    
}

+(CCScene *) scene;
-(void)startMenuAction;
-(void)setupMenu;
//-(void)handleAuthChange:(BOOL) n;

@end
