//
//  WHItem.h
//  GGJ13
//
//  Created by noliv on 26/01/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    ItemTypeNormal,
    ItemTypeExtasy
} ItemType;

@interface WHItem : CCSprite {
    
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;

@end
