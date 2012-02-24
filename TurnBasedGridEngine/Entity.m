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

#import "Entity.h"
#import "GameConfig.h"

@implementation Entity
@synthesize sprite = _sprite;
@synthesize gameBoardPosition = _gameBoardPosition;
@synthesize cardSlot = _cardSlot;
@synthesize facingDirection = _facingDirection;

- (id)init {
    if (self = [super init]) {
        // amazing codz WOWZER!
        [self setEntitySprite]; 
        _cardSlot = -1;
    }
    return self;
}
- (id)initWithTilePosition:(CGPoint)position {
    if (self = [self init]) {
        // amazing codz WOWZER!
        [self setGameBoardStartingPosition:position];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{    
    [coder encodeObject:_gameBoardPosition forKey:@"gameboardPosition"];
    [coder encodeInt:_cardSlot forKey:@"cardSlot"];
    [coder encodeBool:_sprite.flipX forKey:@"flipX"];
    [coder encodeBool:_sprite.flipY forKey:@"flipY"];
    [coder encodeInt:_sprite.rotation forKey:@"rotation"];
}

-(id)initWithCoder:(NSCoder*)coder
{
    if (self=[super init]) {
        [self setEntitySprite];
        _sprite.flipX = [coder decodeBoolForKey:@"flipX"];
        _sprite.flipY = [coder decodeBoolForKey:@"flipY"];
        _sprite.rotation = [coder decodeIntForKey:@"rotation"];
        self.cardSlot = [coder decodeIntForKey:@"cardSlot"];
        self.gameBoardPosition = [coder decodeObjectForKey:@"gameboardPosition"];
        [self moveToGameBoardPosition:[_gameBoardPosition getGameBoardPosition]];
        
    }
    return self;
}

- (void) setEntitySprite {
    _sprite = [CCSprite spriteWithFile:[[NSBundle mainBundle] pathForResource:@"graphics/entity/entity_blank" 
                                                                       ofType:@"png"]];
    [_sprite retain]; 
}
- (void) setGameBoardStartingPosition:(CGPoint)position {
    _gameBoardPosition = [[GameBoardPosition alloc] initWithGameBoardPosition:position];
    [_gameBoardPosition retain];
    // set starting position of the sprite;
    _sprite.position = [_gameBoardPosition getScreenPosition];
}
- (enum Direction) reflectionDirectionFromIncidentDirection:(enum Direction)incident {
    return STOP;
}
- (void) handelLaserCollisionFromDirection:(enum Direction)incidentDirection {
    //NSLog(@"NOOP on base entity");
}

- (void) rotateEntity:(enum RotateDirection)rotateDirection {
    _sprite.flipX = !_sprite.flipX;
}

- (void) moveToGameBoardPosition:(CGPoint)position {
    [_gameBoardPosition setGameBoardPosition:position];
    [self sprite].position = [_gameBoardPosition getScreenPosition];
}
- (void) entityTapped {
    NSLog(@"%@ tapped",[self class]);
}
- (bool) canMove {
    return YES;
}
- (bool) canRotate {
    return YES;
}
- (bool) canRemovePiece {
    return YES;
}
- (void) dealloc {
    [_sprite release];
    [_gameBoardPosition release];
    [super dealloc];
}
@end
