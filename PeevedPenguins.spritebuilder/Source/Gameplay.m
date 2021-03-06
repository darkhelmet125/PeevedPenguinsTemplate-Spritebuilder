//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by William Short on 11/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Penguin.h"

@implementation Gameplay {
    
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCPhysicsNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    Penguin *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    CCAction *_followPenguin;
    
}

static const float MIN_SPEED = 5.f;

//called when CCB is loaded
-(void) didLoadFromCCB {
    
    _physicsNode.collisionDelegate = self;
    
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
-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    //start catapult dragging when touch begins in catapult arm.
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        //move _mouseJointNode to touch location
        _mouseJointNode.position = touchLocation;
        
        //setup spring joint between _mouseJoint and _catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
    }
    
    //create penguin from ccb file
    _currentPenguin = (Penguin*)[CCBReader load:@"Penguin"];
    
    //initial position in catapult bowl; 34, 138 is position of the node
    CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
    
    //transform world position to node space to which penguin will be added (_physicsNode)
    _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
    
    //add to physics world
    [_physicsNode addChild:_currentPenguin];
    
    //don't allow rotation for penguin
    _currentPenguin.physicsBody.allowsRotation = FALSE;
    
    //create joint to keep penguin in catapult bowl
    _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
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

-(void) touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
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
    
    //releases joint and lets penguin fly
    [_penguinCatapultJoint invalidate];
    _penguinCatapultJoint = nil;
    
    //after snapping rotation is okay
    _currentPenguin.physicsBody.allowsRotation = TRUE;
    
    //follow current penguin
    _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
    [_contentNode runAction:_followPenguin];
    
    _currentPenguin.launched = TRUE;
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    //when touches end release catapult
    [self releaseCatapult];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    //when touches are cancelled release catapult
    [self releaseCatapult];
}

-(void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    float energy = [pair totalKineticEnergy];
    
    //if energy is high enough remove seal
    if (energy > 5000.f) {
        [[_physicsNode space]addPostStepBlock:^{[self sealRemoved:nodeA];} key:nodeA];
    }
}

-(void) sealRemoved:(CCNode*)seal {
    //load particle effect
    CCParticleSystem* explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    //make the particle effect clean itself up, once it is complete
    explosion.autoRemoveOnFinish = TRUE;
    //place the particle effect on the seals position
    explosion.position = seal.position;
    //add particle effect to the same node as the seal is on
    [seal.parent addChild:explosion];
    
    [seal removeFromParent];
}

-(void)update:(CCTime)delta {
    if (_currentPenguin.launched) {
        //if speed is below min speed, assume this attempt is over
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED) {
            [self nextAttempt];
            return;
        }
        
        int xMin = _currentPenguin.boundingBox.origin.x;
        
        if(xMin < self.boundingBox.origin.x) {
            [self nextAttempt];
            return;
        }
        
        int xMax = xMin + _currentPenguin.boundingBox.size.width;
        
        if(xMax > (self.boundingBox.origin.x + self.boundingBox.size.width)) {
            [self nextAttempt];
            return;
        }
    }
}

-(void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0,0)];
    [_contentNode runAction:actionMoveTo];
}

@end
