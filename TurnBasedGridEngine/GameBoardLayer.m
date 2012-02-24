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

#import "GameBoardlayer.h"
#import "CCDirector.h"
#import "GameConfig.h"

@implementation GameBoardlayer
- (id) init {
    if (self = [super init]) {
        // do cool stuff
    }
    return self;
}

- (void) draw {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    glLineWidth(2.0f);
    // find center a for game board
    float gameboardWidth = GAMEBOARD_TILES_WIDE * GAMEBOARD_TILE_SIZE;
    float gameboardHeight = GAMEBOARD_TILES_TALL * GAMEBOARD_TILE_SIZE;
    NSAssert(winSize.width > gameboardWidth,@"Gameboard too wide for screen");
    float leftDrawOffest = (winSize.width - gameboardWidth)/2;
    float bottomDrawOffset = (winSize.height - gameboardHeight)/2 + GAMEBOARD_UP_OFFEST;
    //CGPoint * center;
    
    glColor4f(1.0, 1.0, 1.0, 1.0); 
    for (int i = 0; i <= GAMEBOARD_TILES_WIDE; i++) {
        CGPoint origin = CGPointMake(i*GAMEBOARD_TILE_SIZE + leftDrawOffest, bottomDrawOffset);
        CGPoint destination = CGPointMake(i*GAMEBOARD_TILE_SIZE+leftDrawOffest,bottomDrawOffset+gameboardHeight);
        ccDrawLine(origin, destination);
    }
    for (int i = 0; i <= GAMEBOARD_TILES_TALL; i++) {
        CGPoint origin = CGPointMake(leftDrawOffest, i*GAMEBOARD_TILE_SIZE+bottomDrawOffset);
        CGPoint destination = CGPointMake(leftDrawOffest+gameboardWidth,i*GAMEBOARD_TILE_SIZE+bottomDrawOffset);
        ccDrawLine(origin, destination);
    }
}
@end
