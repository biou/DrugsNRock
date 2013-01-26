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



// HelloWorldLayer implementation
@implementation WHGameLayer


// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		
	}
	return self;
}

@end
