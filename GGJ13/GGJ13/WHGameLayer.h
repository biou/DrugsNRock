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

// HelloWorldLayer
@interface WHGameLayer : CCLayer
{
}

@property WHPartition *partition;
@property NSMutableArray *activeItems;

@end
