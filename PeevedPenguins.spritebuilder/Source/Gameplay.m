//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by William Short on 11/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {

    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    
}

//called when CCB is loaded
-(void) didLoadFromCCB {
    //tell scene to accept touches
    self.userInteractionEnabled = TRUE;
}

//called on every touch
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self launchPenguin];
}

-(void) launchPenguin {
    //loads penguin from ccb file set up in spritebuilder
    CCNode *penguin = [CCBReader load:@"Penguin"];
    
    //position penguin in catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16, 50));
    
    //add penguin to physicsNode of the scene
    [_physicsNode addChild:penguin];
    
    //manually create force to launch penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
}
@end
