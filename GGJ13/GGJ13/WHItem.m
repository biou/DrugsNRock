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
        
    }
    return self;
}


+(CCSprite *item)randomSpecialItem {
    int itemType = arc4random()%(ItemTypeExta-1)+1;
    NSString *frameName;
    
    switch (itemType) {
        case ItemTypeGHB:
            frameName = @"ch-1-ghb.png";
            break;
        case ItemTypeLSD:
            frameName = @"ch-2-LSD.png";
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
    return [WHItem spriteWithSpriteFrameName:frameName];
}

@end
