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

#import "GameStateManager.h"
#import "Entities.h"
#import "Player.h"
#import "CCScheduler.h"
#import "CCDirector.h"
#import "GameBoardPosition.h"
#import <GameKit/GameKit.h>
#import "TurnBasedMatchController.h"
#import <GameKit/GameKit.h>
#import "AppDelegate.h"

@implementation GameStateManager
@synthesize leftPlayer = _leftPlayer;
@synthesize rightPlayer = _rightPlayer;
@synthesize currentPlayer = _currentPlayer;
@synthesize remainingMoves = _remainingMoves;
@synthesize viewOnlyFlag = _viewOnlyFlag;

static GameStateManager * sharedInstance;
+ (GameStateManager *) sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[GameStateManager alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {      
      
    }
    return self;
}

-(void)enterNewGame:(GKTurnBasedMatch *)match {
    NSLog(@"Entering new game...");
    // set up the gameboard
    _leftPlayer = [[Player alloc] initWithPlayerSide:LEFT];
    _leftPlayer.gcPlayerId = [GKLocalPlayer localPlayer].playerID;
    
    _rightPlayer = [[Player alloc] initWithPlayerSide:RIGHT];
    
    _currentPlayer = _leftPlayer;
    _remainingMoves = MOVES_PER_TURN;
    
    _viewOnlyFlag = NO;
}

-(void)takeTurn:(GKTurnBasedMatch *)match {
    NSLog(@"Taking turn for existing game...");
    if ([match.matchData bytes]) {
        [self restoreGameStateFromData:match.matchData];
        _remainingMoves = MOVES_PER_TURN;
        
        if (_rightPlayer.gcPlayerId == nil) {
            // first time the other person gets a turn
            _rightPlayer.gcPlayerId = [GKLocalPlayer localPlayer].playerID;
            _currentPlayer = _rightPlayer;
        } else if ([_leftPlayer.gcPlayerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            _currentPlayer = _leftPlayer;
        } else if([_rightPlayer.gcPlayerId isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            _currentPlayer = _rightPlayer;
        } else {
            //Throw game error ...
            NSAssert(false, @"Problem figuring out whos turn it is");
        }
        // unlock player moves
        _viewOnlyFlag = NO;
    }
}

- (void)layoutMatch:(GKTurnBasedMatch *)match {
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString;
    
    if (match.status == GKTurnBasedMatchStatusEnded) {
        statusString = @"Match Ended";
    } else {
        int playerNum = [match.participants indexOfObject:match.currentParticipant] + 1;
        statusString = [NSString stringWithFormat:@"Player %d's Turn", playerNum];
    }
    // set up the gameboard
    [self restoreGameStateFromData:match.matchData];
    // lock the gameboard
    _viewOnlyFlag = YES;
    
}
- (void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"Recieved End game Notif");
}
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {
    
}

- (void)sendTurn {
    GKTurnBasedMatch *currentMatch = [[TurnBasedMatchController sharedInstance] currentMatch];
    NSData *data = [self gameStateToData];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count])];

    [currentMatch endTurnWithNextParticipant:nextParticipant 
                                   matchData:data 
                           completionHandler:^(NSError *error) {
                               if (error) {
                                   NSLog(@"%@", error);
                               }
                           }];
}

// this is used to also capture entities not on the gameboard
- (Entity*) entityExistsAtScreenPosition:(CGPoint)position {
    // Left player
    NSArray * leftPlayerEntities = [_leftPlayer placeableEntities];
    for (Entity * e in leftPlayerEntities) {
        if (position.x > (e.sprite.position.x- e.sprite.contentSize.width/2) &&
            position.x < (e.sprite.position.x+ e.sprite.contentSize.width/2) &&
            position.y > (e.sprite.position.y- e.sprite.contentSize.height/2) &&
            position.y < (e.sprite.position.y+ e.sprite.contentSize.height/2) ) {
            return e;
        }
    }
    
    // Right player
    NSArray * rightPlayerEntities = [_rightPlayer placeableEntities];
    for (Entity * e in rightPlayerEntities) {
        if (position.x > (e.sprite.position.x- e.sprite.contentSize.width/2) &&
            position.x < (e.sprite.position.x+ e.sprite.contentSize.width/2) &&
            position.y > (e.sprite.position.y- e.sprite.contentSize.height/2) &&
            position.y < (e.sprite.position.y+ e.sprite.contentSize.height/2) ) {
            return e;
        }
    }
    
    return nil;
}
- (Entity*) entityExistsAtGameBoardPosition:(CGPoint)position {
    // Left player
    NSArray * leftPlayerEntities = [_leftPlayer pieces];
    for (Entity * e in leftPlayerEntities) {
        GameBoardPosition * gameboardPosition = [e gameBoardPosition];
        if (position.x == gameboardPosition.gbX &&
            position.y == gameboardPosition.gbY) {
            return e;
        }
    }
    
    // Right player
    NSArray * rightPlayerEntities = [_rightPlayer pieces];
    for (Entity * e in rightPlayerEntities) {
        GameBoardPosition * gameboardPosition = [e gameBoardPosition];
        if (position.x == gameboardPosition.gbX &&
            position.y == gameboardPosition.gbY) {
            return e;
        }
    }
    return nil;
}


- (void) placeEntityOnGameboard:(Entity*)entity {
    switch ([_currentPlayer side]) {
        case LEFT:
            [_leftPlayer addPieceToPlayer:entity];
            break;
        case RIGHT:
            [_rightPlayer addPieceToPlayer:entity];
            break;
    }
    [self registerMove];
}

- (void) showTurnNotification {
    if (_activeGameScene){ 
        [_activeGameScene showTurnNotification];
    }
}
- (bool) canMakeMove {
    if (_remainingMoves > 0) {
        return TRUE;
    }
    return FALSE;
}

- (void) turnComplete:(id)sender {
    // Turn Complete
    [self sendTurn];
    _remainingMoves = MOVES_PER_TURN;
    [_activeGameScene refreshHUD];
    [self showTurnNotification];
}

- (void) registerMove {
    _remainingMoves --;
    [_activeGameScene refreshHUD];
}
- (void) removeAllEntitiesForGameBoard {
    // Left player
    NSArray * leftPlayerEntities = [_leftPlayer pieces];
    for (Entity * e in leftPlayerEntities) {
        [[e sprite] removeFromParentAndCleanup:YES];
    }
    
    // Right player
    NSArray * rightPlayerEntities = [_rightPlayer pieces];
    for (Entity * e in rightPlayerEntities) {
        [[e sprite] removeFromParentAndCleanup:YES];
    }
}
- (void) startNextTurn:(id)sender {
    [_activeGameScene hideTurnNotification];
    [_activeGameScene hideGameOverNotification];
    [self removeAllEntitiesForGameBoard];
    id vc = [(AppDelegate*)[[UIApplication sharedApplication] delegate] viewController];
    [[TurnBasedMatchController sharedInstance] findMatchWithMinPlayers:2 maxPlayers:1 viewController:vc];
}
- (void) cancelTurn:(id)sender {
    [self startNextTurn:self];
}
- (void) registerActiveGameScene:(ActiveGameScene*)gameScene {
    [_activeGameScene release];
    _activeGameScene = [gameScene retain];
}

- (void) playerHasBeenKilled:(Player*)player {
    [_activeGameScene showGameOverNotification];
    GKTurnBasedMatch *currentMatch = [[TurnBasedMatchController sharedInstance] currentMatch];
    NSData *data = [self gameStateToData];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count])];

    [currentMatch.currentParticipant setMatchOutcome:GKTurnBasedMatchOutcomeWon];
    [nextParticipant setMatchOutcome:GKTurnBasedMatchOutcomeLost];
    [currentMatch endMatchInTurnWithMatchData:data 
                            completionHandler:^(NSError *error) {
                                if (error) {
                                    NSLog(@"%@", error);
                                }
                            }];
}
                                                                                          
- (void) startNewGame:(id)sender {
    [_activeGameScene hideGameOverNotification];
    
    [_leftPlayer release];
    [_rightPlayer release];
    _leftPlayer = [[Player alloc] initWithPlayerSide:LEFT];
    _rightPlayer = [[Player alloc] initWithPlayerSide:RIGHT];
    
    _currentPlayer = _leftPlayer;
    _remainingMoves = MOVES_PER_TURN;
    
    // Run the intro Scene
	[[CCDirector sharedDirector] replaceScene:[ActiveGameScene scene]];
}

- (NSArray*) availableMovePositionsAsStringsForEntity:(Entity*)entity {
    NSMutableArray * availableTiles = [NSMutableArray array];
    CGPoint entityGameBoardLocation = [[entity gameBoardPosition] getGameBoardPosition];
    for (int dx = -1; dx <= 1 ; dx += 1) {
        for (int dy = -1; dy <= 1 ; dy += 1) {
            CGPoint newPoint = CGPointMake(entityGameBoardLocation.x+dx, entityGameBoardLocation.y+dy);
            if ((newPoint.x >= 0 && newPoint.x < GAMEBOARD_TILES_WIDE) &&
                (newPoint.y >= 0 && newPoint.y < GAMEBOARD_TILES_TALL))
            {
                if (![self entityExistsAtGameBoardPosition:newPoint]) {
                    [availableTiles addObject:NSStringFromCGPoint(newPoint)];
                }
            }
        }
    }
    return availableTiles;
}

- (NSMutableArray*) availableStartPositionsForEntity:(Entity*)entity {
    int startX=0;
    int max=GAMEBOARD_TILES_WIDE/2;
    if ([[[GameStateManager sharedInstance] currentPlayer] side]==RIGHT){
        startX=GAMEBOARD_TILES_WIDE/2;
        max=GAMEBOARD_TILES_WIDE;
    }

    NSMutableArray * startingPositions = [NSMutableArray array];
    for (int x=startX;x<max;x++) {
        for (int y=0;y<GAMEBOARD_TILES_TALL;y++) {
            CGPoint newPoint = CGPointMake(x, y);
            if (![[GameStateManager sharedInstance] entityExistsAtGameBoardPosition:newPoint]){
                [startingPositions addObject:NSStringFromCGPoint(newPoint)];
            }
        }
    }
    return startingPositions;

}

-(Player*)playerWithGamePiece:(Entity*)entity {
    if ([_leftPlayer hasPiece:entity]) {
        return _leftPlayer;
    } else if ([_rightPlayer hasPiece:entity]) {
        return _rightPlayer;
    }
    return nil;
}

- (NSData*) gameStateToData {
    NSMutableData * data = [[[NSMutableData alloc] init] autorelease];
    NSMutableDictionary * stateDictionary = [NSMutableDictionary dictionary];
    
    [stateDictionary setObject:_leftPlayer forKey:@"leftPlayer"];
    [stateDictionary setObject:_rightPlayer forKey:@"rightPlayer"];    
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:stateDictionary forKey:@"stateDictionary"];
    [archiver finishEncoding];
    [archiver release];
    return data;
}

- (bool) restoreGameStateFromData:(NSData*)data {
    
    NSMutableDictionary * stateDictionary = [NSMutableDictionary dictionary];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    stateDictionary = [unarchiver decodeObjectForKey: @"stateDictionary"];
    [unarchiver finishDecoding];
    [unarchiver release];
    
    if (_leftPlayer != nil) {
        [_leftPlayer release];
    }
    _leftPlayer = [stateDictionary objectForKey:@"leftPlayer"];
    [_leftPlayer retain];

    if (_rightPlayer != nil) {
        [_rightPlayer release];
    }
    _rightPlayer = [stateDictionary objectForKey:@"rightPlayer"];
    [_rightPlayer retain];
      
    return true;
}


- (void) dealloc {
    [sharedInstance release];
    [_leftPlayer release];
    [_rightPlayer release];
    [_activeGameScene release];
    [super dealloc];
}

@end
