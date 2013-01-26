//
//  BBGCHelper.h
//  
//
//  Created by Alain Vagner on 05/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"

@interface GCHelper : NSObject <GKLeaderboardViewControllerDelegate> {
    BOOL userAuthenticated; 
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (weak) 	id authChangeDelegate;



+ (GCHelper *)sharedInstance;
- (BOOL)isGameCenterAvailable;
- (void)authenticateLocalUser;
-(BOOL)isUserAuthenticated;
-(void)reportScore: (int64_t) score forCategory: (NSString*) category;
- (void) loadCategoryTitles;
-(void)displayLeaderboard;

@end

@protocol GCEnabled
	-(void) handleAuthChange:(BOOL)b;
@end