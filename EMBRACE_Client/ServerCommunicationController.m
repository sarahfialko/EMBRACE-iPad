//
//  ServerCommunicationController.m
//  EMBRACE
//
//  Created by Rishabh Chaudhry on 12/17/13.
//  Copyright (c) 2013 Andreea Danielescu. All rights reserved.
//

#import "ServerCommunicationController.h"
#import "LibraryViewController.h"
#import "BookCellView.h"
#import "BookHeaderView.h"
#import "Book.h"
#import "PMViewController.h"
#import "foundation/foundation.h"
#import "DDXML.h"
#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"
#import "DDXMLPrivate.h"
#import "NSString+DDXML.h"

DDXMLDocument *xmlDocTemp;
DDXMLElement *nodeStudyContext;
DDXMLElement *nodeStudy;

@implementation ServerCommunicationController

@synthesize student;
@synthesize movenum;
@synthesize bookView;
@synthesize study;
@synthesize xmlDoc;
@synthesize UserActionIDTag;
@synthesize studyConditionString;
@synthesize studyExperimenterString;
@synthesize studyDayString;
@synthesize userNameString;
@synthesize studyFileName;
@synthesize studyParticipantString;
@synthesize studySchoolString;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static ServerCommunicationController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        //someProperty = [[NSString alloc] initWithString:@"Default Property Value"];
        
        //initialize xml document
        //study = (DDXMLElement *)[DDXMLNode elementWithName:@"study"];
        //DDXMLDocument *xmlDoctemp = [[DDXMLDocument alloc] initWithXMLString:@"<study/>" options:0 error:nil];
        xmlDocTemp = [[DDXMLDocument alloc] initWithXMLString:@"<study/>" options:0 error:nil];
        study = [xmlDocTemp rootElement];
        NSLog(@"gets to init of logging");
        
        //xmlDoc = xmlDoctemp;
        
        //DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:@"<study/>" options:0 error:nil];
        
        //[xmlDoc setVersion:@"1.0"];
        //[xmlDoc setCharacterEncoding:@"UTF-8"];
        
        UserActionIDTag = 0;
        
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (void)logUserName : (Student *) userdetails;
{
    //[super logDetails];
    //NSLog(@"NameRbh2: %@", [student firstName]);
    //NSLog(@"NameRbh2: %@", num);
    if(userdetails != nil) {
        //Logging Information to the server
        //Author: Udai Arora
        //Create a date object
        NSDate *currentTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy hh-mm"];
        NSString *resultString = [dateFormatter stringFromDate: currentTime];
        
        //Setup POST method with proper encoding
        NSString *post = [NSString stringWithFormat:@"fname=%@&lname=%@&time=%@",[userdetails firstName],[userdetails lastName],resultString];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        //Add the necessary URL, Headers and POST Body toNSMutableURLRequest
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://129.219.28.98/embrace-login.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        //To send and recieve a response
        NSURLResponse *response;
        NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
        NSLog(@"Reply: %@", theReply);
        
        
    }
    
    
}

- (void) resetMovenum{
    movenum=@0;
    
}

- (void) logMovements :(NSString *)objid :(float) posx :(float) posy
{
 
    NSLog(@"%ld", (long)movenum.integerValue);
    movenum = @(movenum.integerValue + 1);
    //Setup POST method with proper encoding
    NSString *post = [NSString stringWithFormat:@"movenum=%ld&objectid=%@&posx=%f&posy=%f", (long)movenum.integerValue, objid, posx, posy];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    //Add the necessary URL, Headers and POST Body toNSMutableURLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://129.219.28.98/embrace-log-objects.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //To send and recieve a response
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *theReply = [[NSString alloc] initWithBytes:[POSTReply bytes] length:[POSTReply length] encoding: NSASCIIStringEncoding];
    NSLog(@"Reply: %@", theReply);
    
   }

//local XML logging starts here

//stores general context of participant, condition and expermenter as global elements
-(void) logContext : (Student *) userdetails
{
    if(userdetails != nil) {
        [self init]; //start a new log file
        
        //formats username string into "firstname lastname"
        NSString *FileNameValue = [NSString stringWithFormat:@"%@ %@ %@",[userdetails schoolName],[userdetails firstName],[userdetails lastName]];
        
        //sets global variables to be used by returnContext function
        studySchoolString = [userdetails schoolName];
        studyExperimenterString = [userdetails experimenterName];
        studyConditionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]; //comes from app name
        studyParticipantString = [userdetails firstName];
        studyDayString = [userdetails lastName];
        studyFileName = FileNameValue;
    }

}


//Logging Computer Actions
//logging object manipulation


/*
 Action Type: Automatic Computer Move Object
 UserActionIDTag: currentIDTag
 Selection: ObjID of image being moved
 Action: Move Object(s)
 Input: What objects, start location, end location
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerMoveObject : (NSString *) movingObjectID : (NSString *) collisionObjectorLocationID : (float) startPosX : (float) startPosY : (float) endPosX : (float) endPosY : (NSString *) computerAction : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection objectID
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Image"];
    
    //input parent
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children
    DDXMLElement *nodeMovingObject = [DDXMLElement elementWithName:@"Moving Object" stringValue:movingObjectID];
    DDXMLElement *nodeWaypointID = [DDXMLElement elementWithName:@"Waypoint ID" stringValue:collisionObjectorLocationID];
    DDXMLElement *nodeStartPosition = [DDXMLElement elementWithName:@"Start Position" stringValue:[NSString stringWithFormat:@"%f, %f", startPosX, startPosY]];
    DDXMLElement *nodeEndPosition = [DDXMLElement elementWithName:@"End Position" stringValue:[NSString stringWithFormat:@"%f, %f", endPosX, endPosY]];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeMovingObject];
    [nodeInput addChild:nodeWaypointID];
    [nodeInput addChild:nodeStartPosition];
    [nodeInput addChild:nodeEndPosition];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Move to Waypoint"];
    //move to waypoint/move to object/move to location
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];

}

/*
 UserActionIDTag: current useractionID
 Selection: objectID
 Action: Reset Object(s)
 Input: What object(s), start location, end location
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerResetObject : (NSString *) movingObjectID : (float) startPosX : (float) startPosY : (float) endPosX : (float) endPosY : (NSString *) computerAction :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    
    
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Image"];
    
    //input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating Input children nodes
    DDXMLElement *nodeObject = [DDXMLElement elementWithName:@"Object" stringValue:movingObjectID];
    DDXMLElement *nodeStartPosition = [DDXMLElement elementWithName:@"Start Position" stringValue:[NSString stringWithFormat:@"%f, %f", startPosX, startPosY]];
    DDXMLElement *nodeEndPosition = [DDXMLElement elementWithName:@"End Position" stringValue:[NSString stringWithFormat:@"%f, %f", endPosX, endPosY]];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeObject];
    [nodeInput addChild:nodeStartPosition];
    [nodeInput addChild:nodeEndPosition];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Reset Object"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: objectID
 Action: Disappear Object(s)
 Input: What object(s)
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerDisappearObject : (NSString *) computerAction : (NSString *) objectID : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Image"];
    
    // input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating Input children nodes
    DDXMLElement *nodeObject = [DDXMLElement elementWithName:@"Object" stringValue:objectID];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeObject];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:computerAction];
    //disappear or appear object
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: objectID
 Action: Swap Images
 Input: What Image, original image source, new image source
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerSwapImages : (NSString *) objectID : (NSString *) swapImageID  : (NSString *) computerAction : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue :(NSString *) sentenceValue : (NSString *) stepValue
{

}

/*
 UserActionIDTag: current useractionID
 Selection: objectID
 Action: Group Objects
 Input: moving object, collision object
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerGroupingObjects : (NSString*) computerActionValue : (NSString *) movingObjectID : (NSString *) collisionObjectID : (NSString *) groupAtLocation :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Image"];
    
    //input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeMovingObj = [DDXMLElement elementWithName:@"Object 1" stringValue:movingObjectID];
    DDXMLElement *nodeCollisionObj = [DDXMLElement elementWithName:@"Object 2" stringValue:collisionObjectID];
    DDXMLElement *nodeGroupAtLocation = [DDXMLElement elementWithName:@"Grouping Location" stringValue:groupAtLocation];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeMovingObj];
    [nodeInput addChild:nodeCollisionObj];
    [nodeInput addChild:nodeGroupAtLocation];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:computerActionValue]; // computerActionValue can be group/ungroup
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to ComputerAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
   // bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

//logging computer navigation functions

/*
 UserActionIDTag: current useractionID
 Selection: Next Button
 Action: Next Chapter
 Input: current chapter, next chapter
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
- (void) logNextChapterNavigation : (NSString *) buttonPressedValue :(NSString *) curChapterValue :(NSString *) nextChapterValue :(NSString *) computerActionValue :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    // Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeNextChapter = [DDXMLElement elementWithName:@"Next Chapter" stringValue:nextChapterValue];
    DDXMLElement *nodeButtonValue = [DDXMLElement elementWithName:@"Button Type" stringValue:buttonPressedValue];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeNextChapter];
    [nodeInput addChild:nodeButtonValue];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:computerActionValue];// computerActionValue can be load first page/no chapters left/load next chapter
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //upon going to next chapter store all chapter log data
    [[ServerCommunicationController sharedManager] writeToFile:studyFileName ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: Next Button
 Action: Next Page
 Input: curent page number, next page number
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
- (void) logNextPageNavigation : (NSString *) buttonPressedValue :(NSString *) curPageValue : (NSString *) nextPageValue :(NSString *) computerActionValue :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for user actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating inpud children nodes
    DDXMLElement *nodeNextPage = [DDXMLElement elementWithName:@"Next Page" stringValue:nextPageValue];
    DDXMLElement *nodeButtonValue = [DDXMLElement elementWithName:@"Button Type" stringValue:buttonPressedValue];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeNextPage];
    [nodeInput addChild:nodeButtonValue];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Load Next Page"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    [[ServerCommunicationController sharedManager] writeToFile:studyFileName ofType:@"txt"];
}

/*
 UserActionIDTag: useractionID
 Selection: Next Button
 Action: Next Chapter
 Input: curent sentence, next sentence
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
- (void) logNextSentenceNavigation : (NSString *) buttonPressedValue :(NSString *) curSentenceValue :(NSString *)nextSentenceValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for computer action
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeNextSentence = [DDXMLElement elementWithName:@"Next Sentence" stringValue:nextSentenceValue];
    DDXMLElement *nodeButtonValue = [DDXMLElement elementWithName:@"Button Type" stringValue:buttonPressedValue];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeNextSentence];
    [nodeInput addChild:nodeButtonValue];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Load Next Sentence"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];

    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: (user action or computer action)
 Action: Next Step
 Input: from where to where
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
- (void) logNextStepNavigation : (NSString *) buttonPressedValue : (NSString *) curStepValue :(NSString *) nextStepValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeNextStep = [DDXMLElement elementWithName:@"Next Step" stringValue:nextStepValue];
    DDXMLElement *nodeButtonValue = [DDXMLElement elementWithName:@"Button Type" stringValue:buttonPressedValue];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeNextStep];
    [nodeInput addChild:nodeButtonValue];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Load Next Step"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}


//logging non-object manipulation actions

/*
 UserActionIDTag: current useractionID
 Selection: objectID
 Action: Action Verification
 Input: correctness, what action
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerVerification: (NSString*)action : (BOOL) verificationValue : (NSString *) objectSelected : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    //logging structure for user actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:objectSelected];
    
    //input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeVerficiation;
    //logging Input
    if (verificationValue)
    {
         nodeVerficiation = [DDXMLElement elementWithName:@"Verification" stringValue:@"Correct"];
    }
    else
    {
        nodeVerficiation = [DDXMLElement elementWithName:@"Verification" stringValue:@"Incorrect"];
    }
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeVerficiation];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:action];//moving object to hotspot/move object to object/menu item selected
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: menu item, object id, word
 Action: Play Audio
 Input: AudioValue
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerPlayAudio: (NSString *) computerAction : (NSString *)  LanguageType : (NSString *) audioFileName : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    UserActionIDTag++;
    
    //logging structure for computer actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Audio"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating inpud children nodes
    DDXMLElement *nodeAudioFilename = [DDXMLElement elementWithName:@"Audio Filename" stringValue:audioFileName];
    DDXMLElement *nodeAudioLanguage = [DDXMLElement elementWithName:@"Audio Language" stringValue:LanguageType];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeAudioFilename];
    [nodeInput addChild:nodeAudioLanguage];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:computerAction];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: ??
 Action: Display Menu Items
 Input: displayedMenuItems
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logComputerDisplayMenuItems :  (NSArray *) displayedMenuInteractions :(NSArray *)displayedMenuImages : (NSArray*) displayedMenuRelationships : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeComputerAction = [DDXMLElement elementWithName:@"Computer Action"];
    [study addChild:nodeComputerAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Image"];
    
    //logging Input
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    DDXMLElement *nodeDisplayedMenuItem1;
    DDXMLElement *nodeDisplayedMenuItem2;
    DDXMLElement *nodeDisplayedMenuItem3;
    
    // checks the number of menu items displayed then extracts the menu item data and parses data into a string for each menu item for logging
    if( [displayedMenuInteractions count] == 2 )
    {
        NSString *menuItem;
        
        //iterates through all menu images
        for( int i=0; i<[displayedMenuImages count];i++ )
        {
            //once the break between both menu items is reached create strings for each
            if( [[displayedMenuImages objectAtIndex:i] isEqual:@"1"])
            {
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:1]];
                
                for (int j=2; j<i; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem1 = [DDXMLElement elementWithName:@"Menu Item 1" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:0], [displayedMenuRelationships objectAtIndex:0]]];
                
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:i+1]];
                
                for (int j=i+2; j<[displayedMenuImages count]; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem2 = [DDXMLElement elementWithName:@"Menu Item 2" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:1], [displayedMenuRelationships objectAtIndex:1]]];
            }
            
        }
        
        //adding child nodes to Input parent
        [nodeInput addChild:nodeDisplayedMenuItem1];
        [nodeInput addChild:nodeDisplayedMenuItem2];
    }
    else
    {
        NSString *menuItem;
        int markMidmenu =0;
        
        for( int i=0; i<[displayedMenuImages count];i++ )
        {
            if ([[displayedMenuImages objectAtIndex:i] isEqual:@"1"])
            {
                markMidmenu = i;
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:1]];
                
                for (int j=2; j<i; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem1 = [DDXMLElement elementWithName:@"Menu Item 1" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:0], [displayedMenuRelationships objectAtIndex:0]]];
            }
            
            if( [[displayedMenuImages objectAtIndex:i] isEqual:@"2"])
            {
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:markMidmenu+1]];
                
                for (int j=markMidmenu+2; j<i; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem2 = [DDXMLElement elementWithName:@"Menu Item 2" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:1], [displayedMenuRelationships objectAtIndex:1]]];
                
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:i+1]];
                
                for (int j=i+2; j<[displayedMenuImages count]; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem3 = [DDXMLElement elementWithName:@"Menu Item 3" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:2], [displayedMenuRelationships objectAtIndex:2]]];
            }
            
        }
        
        //adding child nodes to Input parent
        [nodeInput addChild:nodeDisplayedMenuItem1];
        [nodeInput addChild:nodeDisplayedMenuItem2];
        [nodeInput addChild:nodeDisplayedMenuItem3];
    }
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Display Menu"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeComputerAction addChild:nodeUserActionID];
    [nodeComputerAction addChild:nodeSelection];
    [nodeComputerAction addChild:nodeAction];
    [nodeComputerAction addChild:nodeInput];
    [nodeComputerAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}


//logging User Actions

//logging UserNavigation
/*
 UserActionID : current UserActionIDTag
 Selection: Next Button
 Action: Call Computer Navigation
 Input: Button Type: Next Button
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
-(void) logUserNextButtonPressed: (NSString *) buttonPressedValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeUserAction = [DDXMLElement elementWithName:@"User Action"];
    [study addChild:nodeUserAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeButtonType = [DDXMLElement elementWithName:@"Button Type" stringValue:@"Next"];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeButtonType];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Tap"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeUserAction addChild:nodeUserActionID];
    [nodeUserAction addChild:nodeSelection];
    [nodeUserAction addChild:nodeAction];
    [nodeUserAction addChild:nodeInput];
    [nodeUserAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: ChapterbuttonID
 Action: Load First Page
 Input: Button Type: chapterbuttonID
 Context: story, chapter, page: 1, sentence: 1, step: 1, username, condition, experimenter
 */
-(void) logStoryButtonPressed: (NSString *) buttonPressedValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeUserAction = [DDXMLElement elementWithName:@"User Action"];
    [study addChild:nodeUserAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeButtonType = [DDXMLElement elementWithName:@"Button Type" stringValue:chapterValue];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeButtonType];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Tap"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeUserAction addChild:nodeUserActionID];
    [nodeUserAction addChild:nodeSelection];
    [nodeUserAction addChild:nodeAction];
    [nodeUserAction addChild:nodeInput];
    [nodeUserAction addChild:nodeContext];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

//logging User object Manipulation

/*
 UserActionIDTag: current useractionID
 Selection: objectID
 Action: Move Object
 Input: start location, end location
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
- (void) logUserMoveObject : (NSString *)movingObjID : (NSString*) toLocationOrObject : (float) startposx :(float) startposy :(float) endposx :(float) endposy : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeUserAction = [DDXMLElement elementWithName:@"userAction"];
    
    //logging useraction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection;
    
    nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Image"];
    
     //checks if selected object is grouped if not use movingObjId for selection else groupedObjects array
   /* if([groupedObjects count] == 1)
    {
    
        nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:movingObjID];
    }
    else
    {
        nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:[NSString stringWithFormat:@"%@, %@", groupedObjects[0],groupedObjects[1]]];
    }*/
    
    //[nodeUserAction addChild:nodeSelection];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeMovingObject = [DDXMLElement elementWithName:@"Moving Object" stringValue:movingObjID];
    DDXMLElement *nodeToObjectOrLocation = [DDXMLElement elementWithName:@"Collision Object" stringValue:toLocationOrObject];
    DDXMLElement *nodeStartPosition = [DDXMLElement elementWithName:@"Start Position" stringValue:[NSString stringWithFormat:@"%f, %f", startposx, startposy]];
    DDXMLElement *nodeEndPosition = [DDXMLElement elementWithName:@"End Position" stringValue:[NSString stringWithFormat:@"%f, %f", endposx, endposy]];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeMovingObject];
    [nodeInput addChild:nodeToObjectOrLocation];
    [nodeInput addChild:nodeStartPosition];
    [nodeInput addChild:nodeEndPosition];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:computerActionValue];
    //move to hotspot/move to object/move to location
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeUserAction addChild:nodeUserActionID];
    [nodeUserAction addChild:nodeSelection];
    [nodeUserAction addChild:nodeAction];
    [nodeUserAction addChild:nodeInput];
    [nodeUserAction addChild:nodeContext];

    [study addChild: nodeUserAction];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

/*
 UserActionIDTag: current useractionID
 Selection: SelectedmenuID
 Action: Menu Selection
 Input: displayed menu items
 Context: story, chapter, page, sentence, step, username, condition, experimenter
 */
- (void) logMenuSelection : (int) selectedMenuItemID : (NSArray *) displayedMenuInteractions :(NSArray *)displayedMenuImages : (NSArray *) menuRelationships : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) pageValue : (NSString *) chapterValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeUserAction = [DDXMLElement elementWithName:@"userAction"];
    
    //logging useraction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Menu Item"];
    
    //logging Input
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    DDXMLElement *nodeDisplayedMenuItem1;
    DDXMLElement *nodeDisplayedMenuItem2;
    DDXMLElement *nodeDisplayedMenuItem3;
    
    if( [displayedMenuInteractions count] == 2 )
    {
        NSString *menuItem;
        
        for( int i=0; i<[displayedMenuImages count];i++ )
        {
            if( [[displayedMenuImages objectAtIndex:i] isEqual:@"1"])
            {
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:1]];
                
                for (int j=2; j<i; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem1 = [DDXMLElement elementWithName:@"Menu Item 1" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:0], [menuRelationships objectAtIndex:0]]];
                
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:i+1]];
                
                for (int j=i+2; j<[displayedMenuImages count]; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem2 = [DDXMLElement elementWithName:@"Menu Item 2" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:1], [menuRelationships objectAtIndex:1]]];
            }
            
        }
        
        //adding child nodes to Input parent
        if (selectedMenuItemID == 0) {
            [nodeInput addChild:nodeDisplayedMenuItem1];
        }
        if (selectedMenuItemID == 1)
        {
            [nodeInput addChild:nodeDisplayedMenuItem2];
        }
        
    }
    else
    {
        NSString *menuItem;
        int markMidmenu =0;
        
        for( int i=0; i<[displayedMenuImages count];i++ )
        {
            if ([[displayedMenuImages objectAtIndex:i] isEqual:@"1"])
            {
                markMidmenu = i;
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:1]];
                
                for (int j=2; j<i; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem1 = [DDXMLElement elementWithName:@"Menu Item 1" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:0], [menuRelationships objectAtIndex:0]]];
            }
            
            if( [[displayedMenuImages objectAtIndex:i] isEqual:@"2"])
            {
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:markMidmenu+1]];
                
                for (int j=markMidmenu+2; j<i; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
            
                nodeDisplayedMenuItem2 = [DDXMLElement elementWithName:@"Menu Item 2" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:1], [menuRelationships objectAtIndex:1]]];
                menuItem = [NSString stringWithFormat:@"%@", [displayedMenuImages objectAtIndex:i+1]];
                
                for (int j=i+2; j<[displayedMenuImages count]; j++)
                {
                    menuItem = [NSString stringWithFormat:@"%@, %@", menuItem, [displayedMenuImages objectAtIndex:j] ];
                }
                
                nodeDisplayedMenuItem3 = [DDXMLElement elementWithName:@"Menu Item 3" stringValue:[NSString stringWithFormat:@"%@, %@, %@", menuItem, [displayedMenuInteractions objectAtIndex:2], [menuRelationships objectAtIndex:2]]];
            }
            
        }
        
        //adding child nodes to Input parent
        if (selectedMenuItemID == 0) {
            [nodeInput addChild:nodeDisplayedMenuItem1];
        }
        if (selectedMenuItemID == 1)
        {
            [nodeInput addChild:nodeDisplayedMenuItem2];
        }
        if (selectedMenuItemID ==2) {
            [nodeInput addChild:nodeDisplayedMenuItem3];
        }
    }
   
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Tap"];
    
    //logging Context
     DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeUserAction addChild:nodeUserActionID];
    [nodeUserAction addChild:nodeSelection];
    [nodeUserAction addChild:nodeAction];
    [nodeUserAction addChild:nodeInput];
    [nodeUserAction addChild:nodeContext];
    
    //add userAction to story parent
    [study addChild: nodeUserAction];
    
    //bool successfulWrite = [[ServerCommunicationController sharedManager] writeToFile:userNameString ofType:@"txt"];
}

//logging user word presses
-(void) logUserPressWord : (NSString *) selectedWordID : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) pageValue : (NSString *) chapterValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeUserAction = [DDXMLElement elementWithName:@"User Action"];
    [study addChild:nodeUserAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Word"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeSelectedWord = [DDXMLElement elementWithName:@"Word Pressed" stringValue:selectedWordID];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeSelectedWord];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Tap"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeUserAction addChild:nodeUserActionID];
    [nodeUserAction addChild:nodeSelection];
    [nodeUserAction addChild:nodeAction];
    [nodeUserAction addChild:nodeInput];
    [nodeUserAction addChild:nodeContext];
}

-(void) logUserEmergencyNext :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) pageValue : (NSString *) chapterValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    
    UserActionIDTag++;
    
    //logging structure for user actions
    DDXMLElement *nodeUserAction = [DDXMLElement elementWithName:@"User Action"];
    [study addChild:nodeUserAction];
    
    //logging userAction relationship
    DDXMLElement *nodeUserActionID = [DDXMLElement elementWithName:@"User Action ID" stringValue:[NSString stringWithFormat:@"%ld",(long)UserActionIDTag]];
    
    //logging selection
    DDXMLElement *nodeSelection = [DDXMLElement elementWithName:@"Selection" stringValue:@"Button"];
    
    //Input parent node
    DDXMLElement *nodeInput = [DDXMLElement elementWithName:@"Input"];
    
    //creating input children nodes
    DDXMLElement *nodeButtonType = [DDXMLElement elementWithName:@"Action Type" stringValue:@"Emergency Next"];
    
    //adding child nodes to Input parent
    [nodeInput addChild:nodeButtonType];
    
    //logging action
    DDXMLElement *nodeAction = [DDXMLElement elementWithName:@"Action" stringValue:@"Two Finger Swipe"];
    
    //logging Context
    DDXMLElement *nodeContext = [[ServerCommunicationController sharedManager] returnContext:storyValue :chapterValue :pageValue :sentenceValue :stepValue];
    
    //add SAIC to UserAction parent
    [nodeUserAction addChild:nodeUserActionID];
    [nodeUserAction addChild:nodeSelection];
    [nodeUserAction addChild:nodeAction];
    [nodeUserAction addChild:nodeInput];
    [nodeUserAction addChild:nodeContext];
}

-(DDXMLElement *) returnContext : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue
{
    
    //timestamp
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy'T'hh:mm.ss.SSS"];
    NSString *timeStampValue = [dateFormatter stringFromDate: currentTime];
    
    //logging Context
    DDXMLElement *nodeContext = [DDXMLElement elementWithName:@"Context"];
    DDXMLElement *nodeSchool = [DDXMLElement elementWithName:@"School" stringValue:studySchoolString];
    DDXMLElement *nodeDay = [DDXMLElement elementWithName:@"Day" stringValue:studyDayString];
    DDXMLElement *nodeCondition = [DDXMLElement elementWithName:@"Condition" stringValue:studyConditionString];
    DDXMLElement *nodeParticipant = [DDXMLElement elementWithName:@"Participant" stringValue:studyParticipantString];
    DDXMLElement *nodeExperimenter = [DDXMLElement elementWithName:@"Experimenter" stringValue:studyExperimenterString];
    DDXMLElement *nodeStory = [DDXMLElement elementWithName:@"Story" stringValue:storyValue];
    DDXMLElement *nodeChapter = [DDXMLElement elementWithName:@"Chapter" stringValue:chapterValue];
    DDXMLElement *nodePage = [DDXMLElement elementWithName:@"Page" stringValue:pageValue];
    DDXMLElement *nodeSentence = [DDXMLElement elementWithName:@"Sentence" stringValue:sentenceValue];
    DDXMLElement *nodeStep = [DDXMLElement elementWithName:@"Step" stringValue:stepValue];
    DDXMLElement *nodeTimestamp = [DDXMLElement elementWithName:@"Timestamp" stringValue:timeStampValue];
    
    //adding children nodes to context parent
    [nodeContext addChild:nodeSchool];
    [nodeContext addChild:nodeCondition];
    [nodeContext addChild:nodeDay];
    [nodeContext addChild:nodeParticipant];
    [nodeContext addChild:nodeExperimenter];
    [nodeContext addChild:nodeStory];
    [nodeContext addChild:nodeChapter];
    [nodeContext addChild:nodePage];
    [nodeContext addChild:nodeSentence];
    [nodeContext addChild:nodeStep];
    [nodeContext addChild:nodeTimestamp];
    
    return nodeContext;
}

- (BOOL) writeToFile:(NSString *)fileName ofType:(NSString *)type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, type]];
    NSString *stringxml = [xmlDocTemp XMLStringWithOptions:DDXMLNodePrettyPrint];
    
    //[stringxml writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    /*
    NSString *fullFileName = [NSString stringWithFormat:@"%@.%@", fileName, type];
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    //NSData *xmlData = [xmlDocTemp XMLDataWithOptions:DDXMLNodePrettyPrint];
     */
                      
    
    if (![stringxml writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        //NSBeep();
        NSLog(@"Could not write document out...");
        NSLog(@"%@", stringxml);
        return NO;
    }
    NSLog(@"%@", stringxml);
    NSLog(@"Successfully wrote to file");
    return YES;
}


@end