//
//  WaitingPenguin.m
//  PeevedPenguins
//
//  Created by William Short on 11/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WaitingPenguin.h"

@implementation WaitingPenguin

-(void)didLoadFromCCB
{
    //generate a random float between 0 and 2
    float delay = (arc4random()%2000)/1000.f;
    //call method to start animation after random delay
    [self performSelector:@selector(startBlinkAndJump) withObject:nil afterDelay:delay];
}

-(void)startBlinkAndJump
{
    //animation manager of each node is stored in the animationManager property
    CCAnimationManager *animationManager = self.animationManager;
    //timelines can be referenced/run by name
    [animationManager runAnimationsForSequenceNamed:@"BlinkAndJump"];
}

@end
