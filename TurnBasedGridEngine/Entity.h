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
#import "cocos2d.h"
#import "GameBoardPosition.h"
#import "GameConfig.h"

@interface Entity : NSObject<NSCoding> {
    CCSprite * _sprite;
    GameBoardPosition * _gameBoardPosition;
    int _cardSlot;
    enum Direction _facingDirection;
}
@property (nonatomic,retain) CCSprite * sprite;
@property (nonatomic,retain) GameBoardPosition * gameBoardPosition;
@property (nonatomic,assign) int cardSlot;
@property (nonatomic,assign) enum Direction facingDirection;


// public methods that can be over ridden by child classes
- (id) initWithTilePosition:(CGPoint)position;
- (void) setGameBoardStartingPosition:(CGPoint)position;
- (void) setEntitySprite;
- (void) entityTapped;
- (void) handelLaserCollisionFromDirection:(enum Direction)incidentDirection;
- (enum Direction) reflectionDirectionFromIncidentDirection:(enum Direction)incident;
- (void) rotateEntity:(enum RotateDirection)rotateDirection;
- (void) moveToGameBoardPosition:(CGPoint)position;
- (bool) canMove;
- (bool) canRotate;
- (bool) canRemovePiece;
@end
