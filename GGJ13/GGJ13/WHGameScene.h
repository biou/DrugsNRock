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
#import "GCHelper.h"

#define MODE_SOLO 0
#define MODE_MULTI 1

typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMange,
	kMessageTypeJauge,
	kMessageTypeBPM,
    kMessageTypeGameOver
} MessageType;

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
    uint32_t number;
} MessageMange;

typedef struct {
    Message message;
    uint32_t number;
} MessageJauge;

typedef struct {
    Message message;
    uint32_t number;
} MessageBPM;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnect
} EndReason;

typedef enum {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
} GameState;


@interface WHGameScene : CCScene <GCHelperDelegate> {
	int currentZique;
	int musicBPM;
	int gameBPM;
	int oldGameBPM;
	int rivalBPM;
	int score;
	int scoreFactor;
	int secondsSinceStart;
	bool started;
	
    BOOL isPlayer1;
    GameState gameState;
    
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
}

@property (strong) WHGameLayer * gameLayer;
@property (strong) WHGameLayer * headerLayer;
@property (strong) WHPauseLayer * pauseLayer;
@property (strong) GCDAsyncSocket * socket;
@property (strong) NSMutableArray * ziques;
@property (strong) CCSprite * jauge;
@property (strong) CCSprite * jaugeRival;


-(void) incrementBPM:(int)bpm;
-(void)showPauseLayer;
-(void)hidePauseLayer;
-(void) restartLevel;
-(int) getGameBPM;
-(void) updateJaugeWith:(int)statut;
-(void) sendDrug:(int)itemType;
-(void) displayMessage:(int)m;
-(void) executeNewZique;
-(void) incrementScore:(int)i;

+(WHGameScene *) scene:(int)m;


@end
