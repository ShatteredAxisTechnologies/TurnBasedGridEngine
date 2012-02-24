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

#import "ActiveGameScene.h"
#import "GameBoardLayer.h"
#import "EntitiesLayer.h"
#import "HUDLayer.h"
#import "TurnNotificationLayer.h"
#import "GameStateManager.h"
#import "TurnNotificationLayer.h"
#import "GameOverLayer.h"
#import "Player.h"

@implementation ActiveGameScene 
@synthesize layerArray = _layerArray;
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	ActiveGameScene *scene = [ActiveGameScene node];
	[[GameStateManager sharedInstance] registerActiveGameScene:scene];
	// 'layer' is an autorelease object.
    for (CCLayer * layer in [scene layerArray]) {
        // add layer as a child to scene
        [scene addChild: layer];
    }
    // [[GameStateManager sharedInstance] showTurnNotification];
	// return the scene
	return scene;
}

- (id)init {
    
    if ((self = [super init])) {
        
        _layerArray = [[NSMutableArray alloc] init];
        
        [_layerArray addObject:[GameBoardlayer node]]; 
        [_layerArray addObject:[EntitiesLayer node]];
        _hudLayer = [HUDLayer node];
        [_layerArray addObject:_hudLayer];
    }
    return self;
}

- (void) showTurnNotification {
    if (_turnLayer == nil) {
        _turnLayer = [TurnNotificationLayer node];
        [_turnLayer.infoLabel setString:@"Other Players Turn"];
        [self addChild:_turnLayer];    
    }
}
- (void) hideTurnNotification {
    [self removeChild:_turnLayer cleanup:YES];
}

- (void) showGameOverNotification {
    _gameOverLayer = [GameOverLayer node];
    [self addChild:_gameOverLayer];
}
- (void) hideGameOverNotification {
    [self removeChild:_gameOverLayer cleanup:YES];
}
- (void) refreshHUD {
    [_hudLayer refresh];
}
@end
