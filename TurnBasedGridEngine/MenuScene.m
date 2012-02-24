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

#import "MenuScene.h"
#import "cocos2d.h"
#import "TurnBasedMatchController.h"
#import "AppDelegate.h"
#import "GameStateManager.h"

@implementation MenuScene
@synthesize layer = _layer;
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuLayer *layer = [MenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [MenuLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation MenuLayer
@synthesize label = _titleLabel;

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,255)] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.label = [CCLabelTTF labelWithString:@"Turn Based Engine" fontName:@"Arial" fontSize:32];
        _titleLabel.color = ccc3(255,255,255);
        _titleLabel.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_titleLabel];
        
        // Standard method to create a button
        CCMenuItem *starMenuItem = [CCMenuItemImage 
                                    itemFromNormalImage:[[NSBundle mainBundle] pathForResource:@"graphics/menu/startGame" ofType:@"png"]
                                    selectedImage:[[NSBundle mainBundle] pathForResource:@"graphics/menu/startGame" ofType:@"png"] 
                                    target:[GameStateManager sharedInstance]
                                    selector:@selector(startNextTurn:)];
        starMenuItem.position = ccp((winSize.width/2), (winSize.height/2 -40));
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu];
        
    }	
    return self;
}

- (void)dealloc {
    [_titleLabel release];
    _titleLabel = nil;
    [super dealloc];
}

@end
