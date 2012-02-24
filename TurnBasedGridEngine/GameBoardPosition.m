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

#import "GameBoardPosition.h"
#import "CCDirector.h"
#import "GameConfig.h"

@implementation GameBoardPosition
@synthesize gbX = _gbX;
@synthesize gbY = _gbY;

- (GameBoardPosition*) initWithGameBoardPosition:(CGPoint)position {
    if (self = [super init]) {
        [self setGameBoardPosition:position];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{    
    [coder encodeInt:_gbX forKey:@"gbX"];
    [coder encodeInt:_gbY forKey:@"gbY"];
}

-(id)initWithCoder:(NSCoder*)coder
{
    if (self=[super init]) {
        int x = [coder decodeInt32ForKey:@"gbX"];
        int y = [coder decodeInt32ForKey:@"gbY"];
        [self setGameBoardPosition:CGPointMake(x, y)];
    }
    return self;
}


- (void) setGameBoardPosition:(CGPoint)position {
    _gbX = position.x;
    _gbY = position.y;
}
- (CGPoint) getGameBoardPosition {
    return CGPointMake(_gbX, _gbY);
}

- (CGPoint) getScreenPosition {
    return [GameBoardPosition getScreenPositionFromGameBoardPosition:CGPointMake(_gbX, _gbY)];
}
+ (CGPoint) getScreenPositionFromGameBoardPosition:(CGPoint)gameboardPosition {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // find center a for game board
    float gameboardWidth = GAMEBOARD_TILES_WIDE * GAMEBOARD_TILE_SIZE;
    float gameboardHeight = GAMEBOARD_TILES_TALL * GAMEBOARD_TILE_SIZE;
    float leftDrawOffest = (winSize.width - gameboardWidth)/2;
    float bottomDrawOffset = (winSize.height - gameboardHeight)/2 + GAMEBOARD_UP_OFFEST;
    
    int screenX = leftDrawOffest + (GAMEBOARD_TILE_SIZE * (gameboardPosition.x)) + GAMEBOARD_TILE_SIZE/2;
    int screenY = bottomDrawOffset + (GAMEBOARD_TILE_SIZE * (gameboardPosition.y)) + GAMEBOARD_TILE_SIZE/2;
    return CGPointMake(screenX, screenY);
}
+ (CGPoint) getGameBoardPositionFromScreenPosition:(CGPoint)screenPosition {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    // find center a for game board
    float gameboardWidth = GAMEBOARD_TILES_WIDE * GAMEBOARD_TILE_SIZE;
    float gameboardHeight = GAMEBOARD_TILES_TALL * GAMEBOARD_TILE_SIZE;
    float leftDrawOffest = (winSize.width - gameboardWidth)/2;
    float bottomDrawOffset = (winSize.height - gameboardHeight)/2 + GAMEBOARD_UP_OFFEST;
    
    if (screenPosition.x < leftDrawOffest || 
        screenPosition.y < bottomDrawOffset ||
        screenPosition.x > (winSize.width - leftDrawOffest) ||
        screenPosition.y > (bottomDrawOffset + gameboardHeight) ) {
        // touch point not on gameBoard
        return CGPointMake(-1, -1);
    }
    
    float gameboardX = floor((screenPosition.x - leftDrawOffest)/GAMEBOARD_TILE_SIZE);
    float gameboardY = floor((screenPosition.y - bottomDrawOffset)/GAMEBOARD_TILE_SIZE);

    return CGPointMake(gameboardX, gameboardY);
}

+ (CGRect) gameBoardRect {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    // find center a for game board
    float gameboardWidth = GAMEBOARD_TILES_WIDE * GAMEBOARD_TILE_SIZE;
    float gameboardHeight = GAMEBOARD_TILES_TALL * GAMEBOARD_TILE_SIZE;
    float leftDrawOffest = (winSize.width - gameboardWidth)/2;
    float bottomDrawOffset = (winSize.height - gameboardHeight)/2 + GAMEBOARD_UP_OFFEST;
    return CGRectMake(leftDrawOffest, bottomDrawOffset, gameboardWidth, gameboardHeight);
}

@end
