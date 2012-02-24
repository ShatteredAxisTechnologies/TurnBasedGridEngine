/**
 * Copyright (c) 2012 Shattered Axis Technologies
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
 * is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 **/

#import "TurnBasedMatchController.h"
#import "cocos2d.h"
#import "ActiveGameScene.h"
#import "MenuScene.h"
#import "GameStateManager.h"

@implementation TurnBasedMatchController
@synthesize gameCenterAvailable = _gameCenterAvailable;
@synthesize currentMatch = _currentMatch;
@synthesize delegate = _delegate;

#pragma mark Initialization

static TurnBasedMatchController *sharedHelper = nil;
+ (TurnBasedMatchController *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[TurnBasedMatchController alloc] init];
    }
    return sharedHelper;
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

- (id)init {
    if ((self = [super init])) {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if (_gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self 
                   selector:@selector(authenticationChanged) 
                       name:GKPlayerAuthenticationDidChangeNotificationName 
                     object:nil];
            _delegate = [GameStateManager sharedInstance];
        }
    }
    return self;
}

- (void)authenticationChanged {    
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        _userAuthenticated = TRUE;           
        // Run the intro Scene
        [[CCDirector sharedDirector] runWithScene: [MenuScene scene]];
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        _userAuthenticated = FALSE;
    }
    
}
#pragma mark User functions

- (void)authenticateLocalUser { 
    if (!_gameCenterAvailable) return;
    
    void (^setGKEventHandlerDelegate)(NSError *) = ^(NSError *error)
    {
        GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
        ev.delegate = self;
    };
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {     
        /*
         // uncomment to clear out all matches
         [[GKLocalPlayer localPlayer] 
         authenticateWithCompletionHandler:^(NSError * error) {
             [GKTurnBasedMatch loadMatchesWithCompletionHandler:
              ^(NSArray *matches, NSError *error){
                  for (GKTurnBasedMatch *match in matches) { 
                      NSLog(@"%@", match.matchID); 
                      [match removeWithCompletionHandler:^(NSError *error){
                          NSLog(@"%@", error);}]; 
                  }}];
         }];
         */
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:setGKEventHandlerDelegate];        
    } else {
        NSLog(@"Already authenticated!");
        setGKEventHandlerDelegate(nil);
    }
}


- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController {
    if (!_gameCenterAvailable) return;               
    
    _presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
    request.minPlayers = 2;     
    request.maxPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];    
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
    [_presentingViewController presentModalViewController:mmvc animated:YES];
}

- (bool) otherPlayerQuit:(GKTurnBasedMatch*)match {
    for (int i = 0; i < [match.participants count]; i++) {
        GKTurnBasedParticipant *part = [match.participants objectAtIndex:i];
        if (![part.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            if ([part matchOutcome] == GKTurnBasedMatchOutcomeQuit) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match{
    [_presentingViewController dismissModalViewControllerAnimated:YES];
    NSLog(@"did find match, %@", match);
    GKTurnBasedParticipant *firstParticipant = [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == NULL) {
        // new game
        [_delegate enterNewGame:match];
    } else {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            [_delegate takeTurn:match];
        } else {
            // no toca
            [_delegate layoutMatch:match];
        }        
    }
    _currentMatch = [match retain];
    [[CCDirector sharedDirector] replaceScene:[ActiveGameScene scene]];
}

-(void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    [_presentingViewController 
     dismissModalViewControllerAnimated:YES];
    NSLog(@"has cancelled");
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]];
}

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [_presentingViewController 
     dismissModalViewControllerAnimated:YES];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    [[GameStateManager sharedInstance] playerHasBeenKilled:[[GameStateManager sharedInstance] currentPlayer]];
}

#pragma mark GKTurnBasedEventHandlerDelegate

-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    NSLog(@"new invite");
}

-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
    NSLog(@"Turn has happened");
}

-(void)handleMatchEnded:(GKTurnBasedMatch *)match {
    NSLog(@"Game has ended");
}



@end
