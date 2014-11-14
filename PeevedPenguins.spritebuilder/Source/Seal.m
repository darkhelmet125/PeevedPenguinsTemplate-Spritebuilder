//
//  Seal.m
//  PeevedPenguins
//
//  Created by William Short on 11/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

-(void)didLoadFromCCB {
    self.physicsBody.collisionType = @"Seal";
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair*)pair Seal:(CCNode*)nodeA wildcard:(CCNode*)nodeB {
    //
}

@end
