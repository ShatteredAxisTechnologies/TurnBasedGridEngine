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

@class Entity;
@interface Player : NSObject <NSCoding>{
    float _health;
    NSMutableArray * _pieces;
    NSMutableArray * _placeableEntities;;
    enum PlayerSide _side;
    NSString * _gcPlayerId;
}
@property(nonatomic,assign) float health; 
@property(nonatomic,retain) NSMutableArray * pieces; 
@property(nonatomic,retain) NSMutableArray * placeableEntities; 
@property(nonatomic,assign) enum PlayerSide side;
@property(nonatomic,retain) NSString * gcPlayerId;


- (id) initWithPlayerSide:(enum PlayerSide)playerSide;
- (void) takeDamage:(float)damage;
- (void) addPieceToPlayer:(Entity*)entity;
- (bool) hasPiece:(Entity*)entity;
- (void) grantPlaceablePieces;
- (void) removePiece:(Entity*)piece;
@end