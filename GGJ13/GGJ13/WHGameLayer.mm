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

// HelloWorldLayer implementation
@implementation WHGameLayer
{
    float _elapsedTime;
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
        [self addChild:ctrl];
        
        // chargement de partition
        self.partition = [WHPartition new];
        [self.partition loadData];
        
        // init du tick
        [self schedule: @selector(tick:) interval:1.0/30.0];
        _elapsedTime = 0.0;
        
        // Boutons de jeu
        CCMenuItemImage *bouton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] target:self selector:@selector(touchBouton1)];
        CCMenu * controls = [CCMenu menuWithItems:bouton, nil];
        controls.position = ccp(40, 60);
        [self addChild:controls];
        
        bouton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] target:self selector:@selector(touchBouton2)];
        controls = [CCMenu menuWithItems:bouton, nil];
        controls.position = ccp(120, 60);
        [self addChild:controls];
        
        bouton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] target:self selector:@selector(touchBouton3)];
        controls = [CCMenu menuWithItems:bouton, nil];
        controls.position = ccp(200, 60);
        [self addChild:controls];
        
        bouton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"item00.png"] target:self selector:@selector(touchBouton4)];
        controls = [CCMenu menuWithItems:bouton, nil];
        controls.position = ccp(280, 60);
        [self addChild:controls];
	}
	return self;
}


-(void) tick: (ccTime) dt
{
    _elapsedTime+=dt;
    while ([self.partition nextItemTimestamp] != 0.0 && _elapsedTime > [self.partition nextItemTimestamp]) {
        NSLog(@"New Item");
        [self newItem:ItemTypeNormal];
        [self.partition goToNextItem];
    }
}


-(void) newItem:(ItemType)itemType
{
    WHItem *itemSprite = [WHItem spriteWithSpriteFrameName:@"item01.png"];
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    itemSprite.position = ccp(40.0f+80*(arc4random()%4), winsize.height + 50);
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

-(void)touchBouton1
{
    [self touchBoutonX:40];
}

-(void)touchBouton2
{
    [self touchBoutonX:120];
}

-(void)touchBouton3
{
    [self touchBoutonX:200];
}

-(void)touchBouton4
{
    [self touchBoutonX:280];
}


@end
