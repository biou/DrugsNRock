//
//  BBGCHelper.m
//  
//
//  Created by Alain Vagner on 05/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
// Attention: je n'ai pas ajouté de paramètre à l'init pour régler la valeur de la propriété viewController pour ne pas alourdir le
// code. Ceci est cependant nécessaire pour l'appel à displayLeaderboard.

// Il semblerait que le système de scoreBuffer soit surtout nécessaire sous IOS 4.1. Sous IOS5, quand il n'y a pas de réseau dispo
// le systeme tentera tout seul de renvoyer les scores au retour de la connectivité (et donc pas de network error)
// -> sous IOS 4.1 s'il y a erreur lors de l'envoi des scores, ils ne seront pas réémis.

#import "BBGCHelper.h"
#import "BBGCDSingleton.h"

@implementation GCHelper

@synthesize gameCenterAvailable;
@synthesize authChangeDelegate;

static GCHelper *sharedHelper = nil;

+ (GCHelper *) sharedInstance {
	DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
		return sharedHelper = [[self alloc] init];
	});
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc = 
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(basicAuthenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
        }
    }
    return self;
}


- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer 
										   options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

-(BOOL)isUserAuthenticated {
	return userAuthenticated;
}



- (void)basicAuthenticationChanged {    
	
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
		NSLog(@"Authentication changed: player authenticated.");
		userAuthenticated = TRUE;

    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
		NSLog(@"Authentication changed: player not authenticated");
		userAuthenticated = FALSE;
    }
	if (authChangeDelegate) {
		[authChangeDelegate handleAuthChange:userAuthenticated];
	}
	
}

- (void)authenticateLocalUser { 
	
    if (!gameCenterAvailable) return;
	
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];        
    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void) loadCategoryTitles
{
	
    [GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error) {
        if (error != nil)
        {
			NSLog(@"Error: %@\n", error);
            // handle the error
        }
		NSLog(@"begin categories:\n");
		for(id i in categories) {
			NSLog(@"%@\n",i);
		}
		NSLog(@"end categories\n");
        // use the category and title information
		
	}];
	
}

- (void) reportScore: (int64_t)score forCategory: (NSString*)category
{
    if (!gameCenterAvailable || ![self isUserAuthenticated]) return;	
	
    GKScore * scoreReporter = [[GKScore alloc] initWithCategory:category];	
    scoreReporter.value = score;
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error == nil) {
			NSLog(@"--scoreSent: %lld\n", scoreReporter.value);
		} else {
			NSLog(@"error reportScore: %@", error);
		}
	}];
	

	
}

-(void)displayLeaderboard {
    if (!gameCenterAvailable || ![self isUserAuthenticated]) return;
	

    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)		
    {
        leaderboardController.leaderboardDelegate = self;
		// on affiche le leaderboard
		[[CCDirector sharedDirector] presentModalViewController: leaderboardController animated: YES];
    }		
}


// implémentation de <GKLeaderboardViewControllerDelegate>
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewC
{
	// on revient à la vue standard (appelé par le tap sur le bouton "Done")
	[viewC dismissModalViewControllerAnimated:YES];
}
@end

