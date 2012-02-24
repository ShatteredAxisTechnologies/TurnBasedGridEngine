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

#import "HUDLayer.h"
#import "cocos2d.h"
#import "GameConfig.h"
#import "GameStateManager.h"
#import "Player.h"
#import "CCDirector.h"

@interface HUDLayer(private)
- (void) placeHUDButtons;
@end

@implementation HUDLayer
- (id) init {
    if (self = [super init]) {
        // do cool stuff
        [self placeHUDButtons];
    }
    return self;
}

- (void) placeHUDButtons {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCMenu * menu = [CCMenu menuWithItems: nil];
    menu.position = CGPointMake(0, 0);
    [self addChild:menu];

    NSString * imagePath = nil;
    if (![[GameStateManager sharedInstance] viewOnlyFlag]) {
        imagePath = [[NSBundle mainBundle] pathForResource:@"graphics/buttons/button_turn_complete" ofType:@"png"];
        _turnCompleteButton = [CCMenuItemImage itemFromNormalImage:imagePath selectedImage:imagePath target:[GameStateManager sharedInstance] selector:@selector(turnComplete:)];
        _turnCompleteButton.position = CGPointMake(winSize.width - (_turnCompleteButton.contentSize.width + 40), _turnCompleteButton.contentSize.height/2+5);
        [menu addChild:_turnCompleteButton];
    }
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"graphics/buttons/button_cancel_turn" ofType:@"png"];
    _cancelTurnButton = [CCMenuItemImage itemFromNormalImage:imagePath selectedImage:imagePath target:[GameStateManager sharedInstance] selector:@selector(cancelTurn:)];
    _cancelTurnButton.position = CGPointMake(winSize.width - (_cancelTurnButton.contentSize.width + 40) + 60, _cancelTurnButton.contentSize.height/2+5);   
    [menu addChild:_cancelTurnButton];
    
    NSString * remainingMovesText = [NSString stringWithFormat:@"Moves:%i",[[GameStateManager sharedInstance] remainingMoves]];
    _remainingMovesLabel = [CCLabelTTF labelWithString:remainingMovesText fontName:@"Helvetica" fontSize:14];
    _remainingMovesLabel.position = CGPointMake(80,20);
    [self addChild:_remainingMovesLabel];
}

- (void)refresh {
    NSString * remainingMovesText = [NSString stringWithFormat:@"Moves:%i",[[GameStateManager sharedInstance] remainingMoves]];
    [_remainingMovesLabel setString:remainingMovesText];
}

- (void) draw {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // find center a for game board
    float gameboardWidth = GAMEBOARD_TILES_WIDE * GAMEBOARD_TILE_SIZE;
    float gameboardHeight = GAMEBOARD_TILES_TALL * GAMEBOARD_TILE_SIZE;
    float leftDrawOffest = (winSize.width - gameboardWidth)/2;
    float bottomDrawOffset = (winSize.height - gameboardHeight)/2 + GAMEBOARD_UP_OFFEST;
    glColor4f(0.0, 1.0, 0.0, 1.0);
    glLineWidth(10.0);
    float hudY = bottomDrawOffset+gameboardHeight + 15;
    float player1Health = [[[GameStateManager sharedInstance] leftPlayer] health];
    CGPoint origin1 = CGPointMake(leftDrawOffest, hudY);
    CGPoint destination1 = CGPointMake(leftDrawOffest + player1Health , hudY);
    ccDrawLine(origin1, destination1);
    
    float player2Health = [[[GameStateManager sharedInstance] rightPlayer] health];
    CGPoint origin2 = CGPointMake(winSize.width - leftDrawOffest, hudY);
    CGPoint destination2 = CGPointMake(winSize.width - leftDrawOffest - player2Health, hudY);
    ccDrawLine(origin2, destination2);
}
@end
