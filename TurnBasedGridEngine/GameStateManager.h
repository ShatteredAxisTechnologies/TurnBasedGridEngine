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

#import <Foundation/Foundation.h>
#import "GameConfig.h"
#import "ActiveGameScene.h"
#import "TurnBasedMatchController.h"

@class Entity,Player;
@interface GameStateManager : NSObject <TurnBasedMatchControllerDelegate> {
    Player * _leftPlayer;
    Player * _rightPlayer;
    
    Player * _currentPlayer;
    int _remainingMoves;
    
    ActiveGameScene * _activeGameScene;
    bool _viewOnlyFlag;
}
@property (nonatomic,readonly) Player * leftPlayer;
@property (nonatomic,readonly) Player * rightPlayer;
@property (nonatomic,readonly) Player * currentPlayer;
@property (nonatomic,readonly) int remainingMoves;
@property (nonatomic,readonly) bool viewOnlyFlag;

+ (GameStateManager *) sharedInstance;
- (Entity*) entityExistsAtScreenPosition:(CGPoint)position;
- (Entity*) entityExistsAtGameBoardPosition:(CGPoint)position;
- (void) placeEntityOnGameboard:(Entity*)entity;
- (void) playerHasBeenKilled:(Player*)player;
- (bool) canMakeMove;
- (void) registerMove;
- (void) registerActiveGameScene:(ActiveGameScene*)gameScene;
- (void) showTurnNotification;
- (NSArray*) availableMovePositionsAsStringsForEntity:(Entity*)entity;
- (NSMutableArray*) availableStartPositionsForEntity:(Entity*)entity;
- (Player*) playerWithGamePiece:(Entity*)entity;
- (NSData*) gameStateToData;
- (bool) restoreGameStateFromData:(NSData*)data;
- (void) turnComplete:(id)sender;
@end

