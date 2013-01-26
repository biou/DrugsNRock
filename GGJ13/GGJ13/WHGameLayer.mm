//
//  WHGameLayer.m
//  
//
//  Created by Biou on 28/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "WHGameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#define HIT_Y 50.0f
#define HIT_TOLERANCE 30.0f
#define PERFECT_TOLERANCE 8.0f
#define MAX_DURATION 8.0f

#define RECORDING_MODE YES

// HelloWorldLayer implementation
@implementation WHGameLayer
{
    float _elapsedTime;
    int _currentMusicBPM;
    BOOL flip;
}


// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
		
//		// create and initialize a Label
//		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
//
//		// ask director for the window size
//		CGSize size = [[CCDirector sharedDirector] winSize];
//	
//		// position the label on the center of the screen
//		label.position =  ccp( size.width /2 , size.height/2 );
//		
//		// add the label as a child to this Layer
//		[self addChild: label];
		
        // init des variables
        self.activeItems = [NSMutableArray new];
        
		// initialisation de textures
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spritesheet.plist"];
        
        // Layer de contrôle
        WHControlLayer *ctrl = [WHControlLayer node];
        ctrl.gameLayer = self;
        [self addChild:ctrl];
        
        _currentMusicBPM = 0;
        _elapsedTime = 0.0;
        // [self startPartitionWithBPM:_currentMusicBPM];
        
        // éléments utiles uniquement pour enregistrer une partoche
#ifdef RECORDING_MODE
        self.dateInit = [NSDate new];
        self.recPartition = [WHPartition new];
        self.recPartition.array = [NSMutableArray new];
#endif
        
        // init du tick
        [self schedule: @selector(tick:) interval:1.0/30.0];
        
        // Boutons de jeu
		self.boutons = [NSMutableArray arrayWithCapacity:4];
        CCSprite *bouton = [CCSprite spriteWithSpriteFrameName:@"bouton-off.png"];
        bouton.position = ccp(40, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
        
        bouton = [CCSprite spriteWithSpriteFrameName:@"bouton-off.png"];
        bouton.position = ccp(120, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
        
        bouton = [CCSprite spriteWithSpriteFrameName:@"bouton-off.png"];
        bouton.position = ccp(200, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
        
        bouton = [CCSprite spriteWithSpriteFrameName:@"bouton-off.png"];
        bouton.position = ccp(280, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
	}
	return self;
}


-(void) tick: (ccTime) dt
{
    _elapsedTime+=dt;
    while ([self.partition nextItemTimestamp] != 0.0 && _elapsedTime > [self.partition nextItemTimestamp] - [self adjustedDuration]*(0.82f+_currentMusicBPM*0.01)) {
        // NSLog(@"New Item");
        [self newItem:ItemTypeNormal atLane:[self.partition itemLane]];
        [self.partition goToNextItem];
    }


if ([self.activeItems count]>0){
    WHItem *item = (WHItem *)[self.activeItems objectAtIndex:0];
    if(item.position.y >HIT_Y-2 && item.position.y <HIT_Y+2) {
        // NSLog(@"########## First point -- y:%f temps:%f",item.position.y,_elapsedTime);
    }
}
}


-(void) newItem:(ItemType)itemType atLane: (int)itemLane
{
    WHItem *itemSprite = [WHItem spriteWithSpriteFrameName:@"neutre.png"];
    
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    itemSprite.position = ccp(40.0f+80*(itemLane), winsize.height + 50);
    [self addChild:itemSprite];
    [self.activeItems addObject:itemSprite];
    NSLog(@"Ligne de nouvel élément: %d", itemLane);
    
    WHItem *specialItemSprite = [WHItem randomSpecialItem];
    itemLane += flip?5:3;
    flip=!flip;
    specialItemSprite.position = ccp(40.0f+80*(itemLane%4), winsize.height + 50);
    [self addChild:specialItemSprite];
    [self.activeItems addObject:specialItemSprite];
    
    NSLog(@"Ligne d’élément spécial: %d", itemLane);

    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:[self adjustedDuration] position:ccp(itemSprite.position.x, -50)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(itemMoveFinished:)];
    [itemSprite runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
    // Create the actions
    id actionMove2 = [CCMoveTo actionWithDuration:[self adjustedDuration] position:ccp(specialItemSprite.position.x, -50)];
    id actionMoveDone2 = [CCCallFuncN actionWithTarget:self selector:@selector(itemMoveFinished:)];
    [specialItemSprite runAction:[CCSequence actions:actionMove2, actionMoveDone2, nil]];
}

-(void)itemMoveFinished:(id)target
{
    // NSLog(@"Fin de move… Suppr. de l’item");
    CCNode *node = (CCNode *)[self.activeItems objectAtIndex:0];
    [self.activeItems removeObjectAtIndex:0];
    [self removeChild:node cleanup:YES];
}

-(void)touchBoutonX: (float)bx withNumber: (int)n
{
    NSArray *items = [self.activeItems copy];
    BOOL hit = NO;
    for (WHItem *item in items) {
        // todo : comparer les coordonnées.
        float y = item.position.y;
        float x = item.position.x;
        if (y>HIT_Y-HIT_TOLERANCE && y <HIT_Y+HIT_TOLERANCE && x>bx-HIT_TOLERANCE && x<bx+HIT_TOLERANCE) {
            hit = YES;
        }
    }

    if(hit) {
        NSLog(@"Hit!: %d", n);
		[[self.boutons objectAtIndex:n] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bouton-on-yes.png"]];
		NSLog(@"%@", self.boutons);
    } else {
		[[self.boutons objectAtIndex:n] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bouton-on-no.png"]];
        NSLog(@"Miss");
    }
}

-(void)restoreBouton:(int)btn {
	[[self.boutons objectAtIndex:btn] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bouton-off.png"]];
}

-(void)touchBouton:(int)boutonNb
{
    switch (boutonNb) {
        case 0:
            [self touchBoutonX:40 withNumber:0];
            break;
            
        case 1:
            [self touchBoutonX:120 withNumber:1];
            break;
            
        case 2:
            [self touchBoutonX:200 withNumber:2];
            break;
            
        case 3:
            [self touchBoutonX:280 withNumber:3];
            break;
            
        default:
            break;
    }
	
#ifdef RECORDING_MODE
    NSTimeInterval dt = -[self.dateInit timeIntervalSinceNow];
    [self.recPartition.array addObject:@[[NSNumber numberWithDouble:dt],[NSNumber numberWithInt:boutonNb]]];
     
     // NSLog(@"touch %d", self.recPartition.array.count);
#endif
}

-(void)newLevel:(int)gameBPM {
	// NSLog(@"newLevel: %d", gameBPM);
    _currentMusicBPM = gameBPM;
    [self startPartitionWithBPM:_currentMusicBPM];
}

-(void)startPartitionWithBPM:(int)bpm
{
    // chargement de partition
    for (WHItem *item in self.activeItems) {
        [self removeChild:item cleanup:YES];
    }
    [self.activeItems removeAllObjects];
    
    self.partition = [WHPartition new];
    [self.partition loadTrackWithBPM:bpm];
    // NSLog(@"#### partition chargée : %@",self.partition.array);
    _elapsedTime = 0.0;
}

-(float)adjustedDuration {
    return MAX_DURATION-_currentMusicBPM*1.15f;
}

@end
