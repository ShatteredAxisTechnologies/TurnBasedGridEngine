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

#import "TurnNotificationLayer.h"
#import "cocos2d.h"
#import "GameStateManager.h"

@implementation TurnNotificationLayer
@synthesize infoLabel = _infoLabel;

- (id) init {
    if (self = [super initWithColor:ccc4(100 , 100, 100, 200)]) {
        // do cool stuff
        [self setUpLayer];
        self.isTouchEnabled = YES;
    }
    return self;
}

- (void) setUpLayer {

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _infoLabel = [CCLabelTTF labelWithString:@"Turn" fontName:@"Arial" fontSize:32];
    _infoLabel.color = ccc3(255,255,255);
    _infoLabel.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:_infoLabel];
    
    // Standard method to create a button
    NSString * buttonImage = [[NSBundle mainBundle] pathForResource:@"graphics/buttons/button_turn_complete" ofType:@"png"];
    CCMenuItem *starMenuItem = [CCMenuItemImage 
                                itemFromNormalImage:buttonImage
                                selectedImage:buttonImage 
                                target:[GameStateManager sharedInstance] selector:@selector(startNextTurn:)];
    starMenuItem.position = ccp(winSize.width/2, winSize.height/3);
    CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
    starMenu.position = CGPointZero;
    [self addChild:starMenu];   
    _buttonMenu = starMenu;
}

@end
