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

#import "EntitiesLayer.h"
#import "Entities.h"
#import "cocos2d.h"
#import "GameConfig.h"
#import "GameStateManager.h"
#import "Player.h"

@interface EntitiesLayer (private) 
- (void) placeInitialEntities;
- (void) placeEntity:(Entity*)entity inCardSlotForPlayer:(Player*)player index:(NSUInteger)index ;
@end

@implementation EntitiesLayer
- (id) init {
    if (self = [super init]) {
        self.isTouchEnabled = YES;
        // do cool stuff
        [self placeInitialEntities];
    }
    return self;
}

- (void) placeInitialEntities {
    // Left player
    NSArray * leftPlayerEntities = [[[GameStateManager sharedInstance] leftPlayer] pieces];
    for (Entity * e in leftPlayerEntities) {
        [e sprite].color = ccc3(255, 0, 0);
        [self addChild:[e sprite]];
    }
    if ([[GameStateManager sharedInstance] leftPlayer] == [[GameStateManager sharedInstance] currentPlayer]) {
        int count = 0;
        leftPlayerEntities = [[[GameStateManager sharedInstance] leftPlayer] placeableEntities];
        for (Entity * e in leftPlayerEntities) {
            if (count>2) {
                break;
            }
            [self placeEntity:e inCardSlotForPlayer:[[GameStateManager sharedInstance] leftPlayer] index:count];
            count ++;
        }
    }
    // Right player
    NSArray * rightPlayerEntities = [[[GameStateManager sharedInstance] rightPlayer] pieces];
    for (Entity * e in rightPlayerEntities) {
        [e sprite].color = ccc3(0, 0, 255);
        [self addChild:[e sprite]];
    }
    if ([[GameStateManager sharedInstance] rightPlayer] == [[GameStateManager sharedInstance] currentPlayer]) {
        int count = 0;
        rightPlayerEntities = [[[GameStateManager sharedInstance] rightPlayer] placeableEntities];
        for (Entity * e in rightPlayerEntities) {
            if (count>2) {
                break;
            }
            [self placeEntity:e inCardSlotForPlayer:[[GameStateManager sharedInstance] rightPlayer] index:count];
            count ++;
        }
    } 
}
- (void) placeEntity:(Entity*)entity inCardSlotForPlayer:(Player*)player index:(NSUInteger)index {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint screenPosition;
    if ([player side] == LEFT) {
        screenPosition = CGPointMake(30,index * 50 + 150);
    } else if ([player side] == RIGHT) {
        screenPosition = CGPointMake(winSize.width-30,index * 50 + 150);
    }
    [entity sprite].position = screenPosition;
    entity.cardSlot = index;
    [self addChild:[entity sprite]];
}

- (void) tileSelected:(CCMenuItemImage*)sender {
    CGPoint gameboardPosition = [GameBoardPosition getGameBoardPositionFromScreenPosition:sender.position];
    [_selectedEntity moveToGameBoardPosition:gameboardPosition];
    _selectedEntity = nil;
    [self removeChild:_availableMovesMenu cleanup:YES];
    [[GameStateManager sharedInstance] registerMove];
}
- (void) rotateEntityLeft:(CCMenuItemImage*)sender {
    [_selectedEntity rotateEntity:ANTICLOCKWISE];
    _selectedEntity = nil;
    [self removeChild:_availableMovesMenu cleanup:YES];
    [[GameStateManager sharedInstance] registerMove];
}
- (void) rotateEntityRight:(CCMenuItemImage*)sender {
    [_selectedEntity rotateEntity:CLOCKWISE];
    _selectedEntity = nil;
    [self removeChild:_availableMovesMenu cleanup:YES];
    [[GameStateManager sharedInstance] registerMove];
}

- (void) refillCardSlot:(int)slotIndex forPlayer:(Player*)player {
    NSArray * entities = [player placeableEntities];
    for (Entity * e in entities) {
        if (e.cardSlot == -1) {
            [self placeEntity:e inCardSlotForPlayer:player index:slotIndex];
            break;
        }
    }
}
- (void) placeEntity:(CCMenuItemImage*)sender {
    int selectedCardIndex = _selectedEntity.cardSlot;
    CGPoint gameboardPosition = [GameBoardPosition getGameBoardPositionFromScreenPosition:sender.position];
    _selectedEntity.cardSlot = -1;
    [[[GameStateManager sharedInstance] currentPlayer] addPieceToPlayer:_selectedEntity];    
    [[[[GameStateManager sharedInstance] currentPlayer] placeableEntities] removeObject:_selectedEntity];
    [_selectedEntity moveToGameBoardPosition:gameboardPosition];
    
    _selectedEntity = nil;
    [self removeChild:_availableMovesMenu cleanup:YES];
    [[GameStateManager sharedInstance] registerMove];
    
    [self refillCardSlot:selectedCardIndex forPlayer:[[GameStateManager sharedInstance] currentPlayer]];
}
- (void)showEntityPlacmentMode:(Entity*)entity {
    
    if (_availableMovesMenu){
        [self removeChild:_availableMovesMenu cleanup:YES];
    }
    if (_selectedEntity == entity) {
        _selectedEntity = nil;
        return;
    }
    _selectedEntity = entity;
    [_availableMovesArray release];
    // this returns an auto released obj so retain it to hold with the paradigm we have been using for thi shiz. 
    _availableMovesArray = [[[GameStateManager sharedInstance] availableStartPositionsForEntity:_selectedEntity] retain];
    _availableMovesMenu = [CCMenu menuWithItems:nil];
    _availableMovesMenu.position = CGPointMake(0, 0);
    for (NSString * ptString in _availableMovesArray) {
        NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"graphics/buttons/button_selectable_tile" ofType:@"png"];
        CCMenuItemImage * mItem = [CCMenuItemImage itemFromNormalImage:imagePath selectedImage:imagePath target:self selector:@selector(placeEntity:) ];
        mItem.position = [GameBoardPosition getScreenPositionFromGameBoardPosition:CGPointFromString(ptString)];
        [_availableMovesMenu addChild:mItem];
    }
    [self addChild:_availableMovesMenu];
}
- (void)showSelectedEntityMode:(Entity*)entity {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (_availableMovesMenu){
        [self removeChild:_availableMovesMenu cleanup:YES];
    }
    if (_selectedEntity == entity) {
        _selectedEntity = nil;
        return;
    }
    _selectedEntity = entity;
    [_availableMovesArray release];
    _availableMovesArray = [[NSMutableArray alloc] init];
    NSArray * availableGameBoardPositions = [[GameStateManager sharedInstance] availableMovePositionsAsStringsForEntity:_selectedEntity];
    if ([_selectedEntity canMove]) {
        for (NSString * ptStr in availableGameBoardPositions) {
            CGPoint pt = CGPointFromString(ptStr);
            NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"graphics/buttons/button_selectable_tile" ofType:@"png"];
            CCMenuItemImage * mItem = [CCMenuItemImage itemFromNormalImage:imagePath selectedImage:imagePath target:self selector:@selector(tileSelected:) ];
            mItem.position = [GameBoardPosition getScreenPositionFromGameBoardPosition:pt];
            [_availableMovesArray addObject:mItem];
        }
    }
    if ([_selectedEntity canRotate]){
        NSString * imagePath = [[NSBundle mainBundle] pathForResource:@"graphics/buttons/button_rotate" ofType:@"png"];
        CCMenuItemImage * mItem = [CCMenuItemImage itemFromNormalImage:imagePath selectedImage:imagePath target:self selector:@selector(rotateEntityRight:) ];
        mItem.position = CGPointMake(winSize.width/2+50, 25);
        [_availableMovesArray addObject:mItem];
        
        CCMenuItemImage * mItem2 = [CCMenuItemImage itemFromNormalImage:imagePath selectedImage:imagePath target:self selector:@selector(rotateEntityLeft:) ];
        mItem2.scaleX = -1;
        mItem2.position = CGPointMake(winSize.width/2, 25);
        [_availableMovesArray addObject:mItem2];
    }
    
    _availableMovesMenu = [CCMenu menuWithItems:nil];
    _availableMovesMenu.position = CGPointMake(0, 0);
    for (CCMenuItemImage * item in _availableMovesArray) {
        [_availableMovesMenu addChild:item];
    }
    [self addChild:_availableMovesMenu];
}

#pragma mark Touch handlers
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
 
    
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![[GameStateManager sharedInstance] canMakeMove]) {
        return;
    }
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location]; 
    
    CGPoint drawPoint = [GameBoardPosition getGameBoardPositionFromScreenPosition:location];
    
    Entity *tappedEntity = [[GameStateManager sharedInstance] entityExistsAtGameBoardPosition:drawPoint];
    if ( tappedEntity != nil) {
        if ([[[GameStateManager sharedInstance] currentPlayer] hasPiece:tappedEntity]) {
            [tappedEntity entityTapped];    
            [self showSelectedEntityMode:tappedEntity];
        }
    } else if ((tappedEntity = [[GameStateManager sharedInstance] entityExistsAtScreenPosition:location])){
        if ([[[GameStateManager sharedInstance] currentPlayer] hasPiece:tappedEntity]) {
            [self showEntityPlacmentMode:tappedEntity];
        }
    } else {
    
    }
}

- (void)dealloc {
    [_availableMovesArray release];
    [super dealloc];
}
@end
