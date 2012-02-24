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

#import "Player.h"
#import "Entities.h"
#import "GameStateManager.h"

@implementation Player 
@synthesize health = _health;
@synthesize pieces = _pieces;
@synthesize placeableEntities = _placeableEntities;
@synthesize side = _side;
@synthesize gcPlayerId = _gcPlayerId;

- (id) initWithPlayerSide:(enum PlayerSide)playerSide {
    if(self = [super init]) {
        _health = PLAYER_HEALTH_START;
        _side = playerSide;
        _pieces = [[NSMutableArray alloc] init];
        _placeableEntities = [[NSMutableArray alloc] init];  
        [self grantPlaceablePieces];
    }
    return self;
}

- (NSMutableArray*)shuffleArray:(NSMutableArray*)array
{
    srandom(time(NULL)%arc4random());
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return array;
}
- (void)grantPlaceablePieces {
    // give the player his placeable entities here    
    
    // uncomment this if you would like to randomize the piecec
    //[self shuffleArray:_placeableEntities];
}

- (void) addPieceToPlayer:(Entity*)entity {
    [_pieces addObject:entity];
}

- (bool) hasPiece:(Entity*)entity {
    for (Entity* e in _pieces) {
        if (e == entity){
            return true;
        }
    }
    for (Entity* e in _placeableEntities) {
        if (e == entity){
            return true;
        }
    }
    return false;
}
- (void) takeDamage:(float)damage {
    _health -= damage;
    if (_health <= 0) {
        [[GameStateManager sharedInstance] playerHasBeenKilled:self];
    }
}
- (void) removePiece:(Entity*)piece {
    [piece.sprite removeFromParentAndCleanup:YES];
    if ([piece canRemovePiece]) {
        [_pieces removeObject:piece];
    }    
}
-(void)encodeWithCoder:(NSCoder*)coder
{    
    [coder encodeFloat:_health forKey:@"health"];
    [coder encodeObject:_pieces forKey:@"pieces"];
    [coder encodeObject:_placeableEntities forKey:@"placeableEntities"];
    
    [coder encodeInt:_side forKey:@"side"];
    [coder encodeObject:_gcPlayerId forKey:@"playerId"];
}

-(id)initWithCoder:(NSCoder*)coder
{
    if (self=[super init]) {
        self.health = [coder decodeFloatForKey:@"health"];
        self.pieces = [coder decodeObjectForKey:@"pieces"];
        self.placeableEntities = [coder decodeObjectForKey:@"placeableEntities"];
        
        self.side = [coder decodeInt32ForKey:@"side"];
        self.gcPlayerId = [coder decodeObjectForKey:@"playerId"];
    }
    return self;
}

- (void) dealloc {
    [_pieces release];
    [super dealloc];
}
@end
