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
    self.physicsBody.collisionType = @"seal";
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair*)pair seal:(CCNode*)nodeA wildcard:(CCNode*)nodeB {
    //
}

@end
