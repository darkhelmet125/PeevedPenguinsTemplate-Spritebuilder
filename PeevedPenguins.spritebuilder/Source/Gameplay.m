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
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCPhysicsNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    
}

//called when CCB is loaded
-(void) didLoadFromCCB {
    //tell scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    //visualize physics joint
    _physicsNode.debugDraw = TRUE;
    
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
}

//called on every touch
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //start catapult dragging when touch begins in catapult arm.
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        //move _mouseJointNode to touch location
        _mouseJointNode.position = touchLocation;
        
        //setup spring joint between _mouseJoint and _catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
    }
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
    
    //make sure penguin is visible before following
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}

-(void) retry {
    //reloads entire scene
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //when a touch moves make _mouseJointNode same as touchLocation
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void) releaseCatapult {
    if (_mouseJoint != nil) {
        //release the joint and lets the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    //when touches end release catapult
    [self releaseCatapult];
    [self launchPenguin];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    //when touches are cancelled release catapult
    [self releaseCatapult];
}

@end
