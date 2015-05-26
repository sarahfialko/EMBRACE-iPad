//
//  PhysicalManipulationSolution.m
//  EMBRACE
//
//  Created by Administrator on 3/31/14.
//  Copyright (c) 2014 Andreea Danielescu. All rights reserved.
//

#import "PhysicalManipulationSolution.h"

@implementation PhysicalManipulationSolution

@synthesize solutionSteps;

-(id) init {
    if (self = [super init]) {
        solutionSteps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) addSolutionStep:(ActionStep*)solStep {
    [solutionSteps addObject:solStep];
}

/*
 * Returns an array containing all the steps for a given sentence number
 */
-(NSMutableArray*) getStepsForSentence:(NSUInteger)sentNum {
    NSMutableArray* stepsForSentence = [[NSMutableArray alloc] init];
    
    for (ActionStep* step in solutionSteps) {
        //Step sentence number matches
        if ([step sentenceNumber] == sentNum) {
            [stepsForSentence addObject:step];
        }
    }
    
    return stepsForSentence;
}

/*
 * Returns the number of steps for a given sentence number
 */
-(NSUInteger) getNumStepsForSentence:(NSUInteger)sentNum {
    NSUInteger numberOfSteps = 0;
    
    for (ActionStep* step in solutionSteps) {
        //Step sentence number matches
        if ([step sentenceNumber] == sentNum) {
            numberOfSteps++; //increase count
        }
    }
    
    return numberOfSteps;
}

/*
 * Returns an array containing the ActionSteps associated with the specified step number
 */
-(NSMutableArray*) getStepsWithNumber:(NSUInteger)stepNum {
    NSMutableArray* steps = [[NSMutableArray alloc] init];
    
    for (ActionStep* step in solutionSteps) {
        //Step number matches
        if ([step stepNumber] == stepNum) {
            [steps addObject:step];
        }
    }
    
    return steps;
}

/*
 * Returns an array containing all the idea numbers associated
 * with the story
 */
-(NSMutableArray*) getIdeaNumbers {
    NSMutableArray* ideaNums = [[NSMutableArray alloc] init];
    
    NSUInteger currIdeaNumber = 0;
    
    for (ActionStep* step in solutionSteps) {
        if ([step sentenceNumber] > currIdeaNumber) {
            [ideaNums addObject:[NSNumber numberWithInteger:[step sentenceNumber]]];
            currIdeaNumber = [step sentenceNumber];
        }
    }
    
    return ideaNums;
}

@end
