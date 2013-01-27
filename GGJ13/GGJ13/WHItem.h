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
    ItemTypeGHB,
    ItemTypeLSD,
    ItemTypeHero,
    ItemTypeCanna,
    ItemTypeTramadol,
    ItemTypeAlcool,
    ItemTypeOpium,
    ItemTypeCocaine,
    ItemTypeCafe,
    ItemTypeChampi,
    ItemTypeMeth,
    ItemTypeExta
} ItemType;

@interface WHItem : CCSprite {
    
}

@property ItemType type;
@property (weak) WHItem *specialPeer;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect;

-(int)effect;

+(WHItem *)randomSpecialItem;
+(int)effectForType:(ItemType)type;


@end
