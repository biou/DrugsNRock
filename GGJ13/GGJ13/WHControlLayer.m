//
//  WHControlLayer.m
//  GGJ13
//
//  Created by noliv on 26/01/13.
//
//

#import "WHControlLayer.h"
#import "WHGameLayer.h"
#import "WHGameScene.h"

@implementation WHControlLayer

- (id)init
{
    self = [super init];
    if (self) {
        self.isTouchEnabled = YES;
    }
    return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        
        if (location.y < 150)
        {
			if (!self.gameLayer.reverse) {
				if (location.x < 80) {
					[self.gameLayer touchBouton:0];
				} else if (location.x < 160) {
					[self.gameLayer touchBouton:1];
				} else if (location.x < 240) {
					[self.gameLayer touchBouton:2];
				} else {
					[self.gameLayer touchBouton:3];
				}
			} else {
				if (location.x < 80) {
					[self.gameLayer touchBouton:3];
				} else if (location.x < 160) {
					[self.gameLayer touchBouton:2];
				} else if (location.x < 240) {
					[self.gameLayer touchBouton:1];
				} else {
					[self.gameLayer touchBouton:0];
				}
			}
        } else if (location.y > 300) {
            NSLog(@"### Sauvegarde de la partition ###");
            [self.gameLayer.recPartition saveDataForTrack:5];
            [self.gameLayer initRecording];
            [self.gameLayer.gameScene restartLevel];
        }
    }
}

- (void)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        
		[self.gameLayer restoreBouton:0];
		[self.gameLayer restoreBouton:1];
		[self.gameLayer restoreBouton:2];
		[self.gameLayer restoreBouton:3];
		
    }
	
}

@end
