//
//  WHGameLayer.h
//  
//
//  Created by Biou on 28/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//




// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "WHPartition.h"
#import "WHItem.h"
#import "WHControlLayer.h"

@class WHGameScene;

// HelloWorldLayer
@interface WHGameLayer : CCLayer
{
}

@property (strong) WHPartition *partition;
@property (strong) WHPartition *recPartition;
@property (strong) NSDate *dateInit;
@property (strong) NSMutableArray *activeItems;
@property (strong) NSMutableArray *boutons;
@property (weak) WHGameScene *gameScene;
@property (strong) dispatch_queue_t gcdQueue;

-(void)touchBouton:(int)boutonNb;
-(void)newLevel:(int)gameBPM;
-(void)restoreBouton:(int)btn;
//-(void)restartLevel;
-(void)initRecording;
-(void)itemTapped:(WHItem *)item;

@end
