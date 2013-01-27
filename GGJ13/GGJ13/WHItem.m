//
//  WHItem.m
//  GGJ13
//
//  Created by noliv on 26/01/13.
//
//

#import "WHItem.h"

@implementation WHItem

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
    if( (self=[super initWithTexture:texture rect:rect]))
    {
        self.type = ItemTypeNormal;
    }
    return self;
}


+(WHItem *)randomSpecialItem {
    int itemType = arc4random()%(ItemTypeExta-1)+1;
    NSString *frameName;
    
    switch (itemType) {
        case ItemTypeGHB:
            frameName = @"ch-1-ghb.png";
            break;
        case ItemTypeLSD:
            frameName = @"ch-2-lsd.png";
            break;
        case ItemTypeHero:
            frameName = @"moins-1-hero.png";
            break;
        case ItemTypeCanna:
            frameName = @"moins-2-canna.png";
            break;
        case ItemTypeTramadol:
            frameName = @"moins-3-tramadol.png";
            break;
        case ItemTypeAlcool:
            frameName = @"moins-4-alcool.png";
            break;
        case ItemTypeOpium:
            frameName = @"moins-5-opium.png";
            break;
        case ItemTypeCocaine:
            frameName = @"plus-1-cocaine.png";
            break;
        case ItemTypeCafe:
            frameName = @"plus-2-cafe.png";
            break;
        case ItemTypeChampi:
            frameName = @"plus-3-champi.png";
            break;
        case ItemTypeMeth:
            frameName = @"plus-4-meth.png";
            break;
        case ItemTypeExta:
            frameName = @"plus-5-exta";
            break;
            
        default:
            break;
    }
    
    
    WHItem *result = [WHItem spriteWithSpriteFrameName:frameName];
    result.type = itemType;
    return result;
}

-(int)effect {
    float effect = 0;
    
    switch (self.type) {
        case ItemTypeGHB:
            effect = 0;
            break;
        case ItemTypeLSD:
            effect = 0;
            break;
        case ItemTypeHero:
            effect = -10;
            break;
        case ItemTypeCanna:
            effect = -7;
            break;
        case ItemTypeTramadol:
            effect = -5;
            break;
        case ItemTypeAlcool:
            effect = -3;
            break;
        case ItemTypeOpium:
            effect = -9;
            break;
        case ItemTypeCocaine:
            effect = +8;
            break;
        case ItemTypeCafe:
            effect = +3;
            break;
        case ItemTypeChampi:
            effect = +4;
            break;
        case ItemTypeMeth:
            effect = +10;
            break;
        case ItemTypeExta:
            effect = +5;
            break;
            
        default:
            break;
    }
    
    return effect;
}

@end
