//
//  Seal.m
//  PeevedPenguins
//
//  Created by William Short on 11/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Seal

-(void)didLoadFromCCB {
    self.physicsBody.collisionType = @"Seal";
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair*)pair Seal:(CCNode*)nodeA wildcard:(CCNode*)nodeB {
    float energy = [pair totalKineticEnergy];
    
    //if energy is high enough remove seal
    if (energy > 5000.f) {
        [[_physicsNode]]
    }
}

@end
