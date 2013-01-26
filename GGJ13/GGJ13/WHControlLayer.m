//
//  WHControlLayer.m
//  GGJ13
//
//  Created by noliv on 26/01/13.
//
//

#import "WHControlLayer.h"

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
        NSLog(@"TOUCHE TOI !");
    }
}

@end
