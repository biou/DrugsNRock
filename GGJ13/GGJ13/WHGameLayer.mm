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
#define ITEMS_SPEED 400.0f

#define RECORDING_MODE YES

// HelloWorldLayer implementation
@implementation WHGameLayer
{
    float _elapsedTime;
    int _currentMusicBPM;
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
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SpriteSheet.plist"];
        
        // Layer de contrôle
        WHControlLayer *ctrl = [WHControlLayer node];
        ctrl.gameLayer = self;
        [self addChild:ctrl];
        
        // chargement de partition
        self.partition = [WHPartition new];
        [self.partition loadData];
        
        // éléments utiles uniquement pour enregistrer une partoche
#ifdef RECORDING_MODE
        self.dateInit = [NSDate new];
        self.recPartition = [WHPartition new];
        self.recPartition.array = [NSMutableArray new];
#endif
        
        // init du tick
        [self schedule: @selector(tick:) interval:1.0/30.0];
        _elapsedTime = 0.0;
        
        // Boutons de jeu
        CCSprite *bouton = [CCSprite spriteWithSpriteFrameName:@"item00.png"];
        bouton.position = ccp(40, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
        
        bouton = [CCSprite spriteWithSpriteFrameName:@"item00.png"];
        bouton.position = ccp(120, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
        
        bouton = [CCSprite spriteWithSpriteFrameName:@"item00.png"];
        bouton.position = ccp(200, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
        
        bouton = [CCSprite spriteWithSpriteFrameName:@"item00.png"];
        bouton.position = ccp(280, 60);
        [self addChild:bouton];
        [self.boutons addObject:bouton];
	}
	return self;
}


-(void) tick: (ccTime) dt
{
    _elapsedTime+=dt;
    while ([self.partition nextItemTimestamp] != 0.0 && _elapsedTime > [self.partition nextItemTimestamp]) {
        NSLog(@"New Item");
        [self newItem:ItemTypeNormal atLane:[self.partition itemLane]];
        [self.partition goToNextItem];
    }


if ([self.activeItems count]>0){
    WHItem *item = (WHItem *)[self.activeItems objectAtIndex:0];
    NSLog(@"%f",item.position.y);
    if(item.position.y >HIT_Y-1 && item.position.y <HIT_Y+1) {
        NSLog(@"First point -- y:%f temps:%f",item.position.y,_elapsedTime);
    }
}
}


-(void) newItem:(ItemType)itemType atLane: (int)itemLane
{
    WHItem *itemSprite = [WHItem spriteWithSpriteFrameName:@"item01.png"];
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    itemSprite.position = ccp(40.0f+80*(itemLane), winsize.height + 50);
    [self addChild:itemSprite];
    [self.activeItems addObject:itemSprite];
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:6.0f position:ccp(itemSprite.position.x, -50)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(itemMoveFinished:)];
    [itemSprite runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

-(void)itemMoveFinished:(id)target
{
    NSLog(@"Fin de move… Suppr. de l’item");
    CCNode *node = (CCNode *)[self.activeItems objectAtIndex:0];
    [self.activeItems removeObjectAtIndex:0];
    [self removeChild:node cleanup:YES];
}

-(void)touchBoutonX: (float)bx
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
        NSLog(@"Hit!");
    } else {
        NSLog(@"Miss");
    }
}

-(void)touchBouton:(int)boutonNb
{
    switch (boutonNb) {
        case 0:
            [self touchBoutonX:40];
            break;
            
        case 1:
            [self touchBoutonX:120];
            break;
            
        case 2:
            [self touchBoutonX:200];
            break;
            
        case 3:
            [self touchBoutonX:280];
            break;
            
        default:
            break;
    }
    
#ifdef RECORDING_MODE
    NSTimeInterval dt = -[self.dateInit timeIntervalSinceNow];
    [self.recPartition.array addObject:@[[NSNumber numberWithDouble:dt],[NSNumber numberWithInt:boutonNb]]];
     
     NSLog(@"touch %d", self.recPartition.array.count);
#endif
}

@end
