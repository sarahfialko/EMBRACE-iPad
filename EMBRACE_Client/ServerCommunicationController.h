//
//  ServerCommunicationController.h
//  EMBRACE
//
//  Created by Rishabh on 12/13/13.
//  Copyright (c) 2013 Andreea Danielescu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EbookImporter.h"
#import "Book.h"
#import "Student.h"
#import "LibraryViewController.h"
#import "DDXML.h"
#import "DDXMLNode.h"
#import "DDXMLElement.h"
#import "DDXMLDocument.h"
#import "DDXMLElementAdditions.h"
#import "DDXMLPrivate.h"
#import "NSString+DDXML.h"

@interface ServerCommunicationController : UIViewController{
    Student *student;
    NSNumber *movenum;
    DDXMLElement *study;
    DDXMLDocument *xmlDoc;
}
@property (nonatomic, strong) Student* student;
@property (nonatomic, strong) IBOutlet UIWebView *bookView;
@property (nonatomic, retain) NSNumber* movenum;
@property (nonatomic, retain) DDXMLElement *study;
@property (nonatomic, retain) DDXMLDocument *xmlDoc;
@property (nonatomic) NSInteger UserActionIDTag;
@property(nonatomic, strong) NSString *studyDayString;
@property (nonatomic, strong) NSString *userNameString;
@property(nonatomic, strong) NSString *studyConditionString;
@property (nonatomic, strong) NSString *studyExperimenterString;
@property (nonatomic, strong) NSString *studyParticipantString;
@property (nonatomic, strong) NSString *studySchoolString;
@property (nonatomic, strong) NSString *studyFileName;

+ (id)sharedManager;
- (void) logUserName : (Student *) userdetails;
- (void) logMovements : (NSString *)objid :(float) posx :(float) posy;
- (void) resetMovenum;

//logging study context
//add logging should be included for each log action, maybe use this funciton to set global properties and just draw from those for each function????
-(void) logContext : (Student *) userdetails;

//Logging Computer Actions
//logging object manipulation

//computer action -> recording why an action occured
//which object(s), start, end location, which hotspots,context, userActionIDTag, why?
-(void) logComputerMoveObject : (NSString *) movingObjectID : (NSString *) collisionObjectOrLocationID : (float) startPosX : (float) startPosY : (float) endPosX : (float) endPosY : (NSString *) computerAction : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//which object(s), start, end location, which hotspots,context, userActionIDTag, why?
-(void) logComputerResetObject : (NSString *) movingObjectID : (float) startPosX : (float) startPosY : (float) endPosX : (float) endPosY : (NSString *) storyValue : (NSString *) computerAction :(NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//
-(void) logComputerSwapImages : (NSString *) objectID : (NSString *) swapImageID  : (NSString *) computerAction : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue :(NSString *) sentenceValue : (NSString *) stepValue;

//which object(s),context, userActionIDTag, why?
-(void) logComputerDisappearObject : (NSString *) computerAction : (NSString *) objectID : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//which object(s), start, end location, which hotspots,context, userActionIDTag, why?
-(void) logComputerGroupingObjects : (NSString*) computerActionValue : (NSString *) movingObjectID : (NSString *) collisionObjectID : (NSString *) groupAtLocation :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//logging none object manipulation actions

//logging object verificiation: correct | incorrect
-(void) logComputerVerification: (NSString*)action : (BOOL) verficationValue : (NSString *) objectSelected : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//logging audio: incorrect | introduction
-(void) logComputerPlayAudio: (NSString *) computerAction : (NSString *) LanguageType : (NSString *) audioFileName : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//logging displayMenuItems
-(void) logComputerDisplayMenuItems : (NSArray *) displayedMenuInteractions : (NSArray *)displayedMenuImages : (NSArray*) displayedMenuRelationships : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;


//Logging User Actions
//logging move object
- (void) logUserMoveObject : (NSString *)movingObjID : (NSString*) toLocationOrObject :(float) startposx :(float) startposy :(float) endposx :(float) endposy : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//logging menu selection
- (void) logMenuSelection : (int) selectedMenuItemID : (NSArray *) displayedMenuInteractions :(NSArray *)displayedMenuImages  : (NSArray *) menuRelationships : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//logging user word presses
-(void) logUserPressWord : (NSString *) selectedWordID : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue  : (NSString *) sentenceValue : (NSString *) stepValue;

//logging experimenter emergency next swipe
-(void) logUserEmergencyNext :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//logging navigation
//add logging should be called in NextButtonPressed
-(void) logUserNextButtonPressed: (NSString *) buttonPressedValue :(NSString *) computerActionValue :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//add logging should be called in load first page
-(void) logStoryButtonPressed: (NSString *) buttonPressedValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;

//log computerNavigation
//add logging should be called in nextButtonPressed, loadNextPage
- (void) logNextStepNavigation : (NSString *) buttonPressedValue :(NSString *)curStepValue :(NSString *)nextStepValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;
- (void) logNextSentenceNavigation : (NSString *) buttonPressedValue :(NSString *) curSentenceValue :(NSString *)nextSentenceValue :(NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;
- (void) logNextPageNavigation : (NSString *) buttonPressedValue :(NSString *) curPageValue : (NSString *) nextPageValue :(NSString *) computerActionValue :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;
- (void) logNextChapterNavigation : (NSString *) buttonPressedValue :(NSString *) curChapterValue :(NSString *) nextChapterValue :(NSString *) computerActionValue :(NSString *) storyValue : (NSString *) chapterValue : (NSString *) pageValue : (NSString *) sentenceValue : (NSString *) stepValue;


//log assessment activities

//log loading next assessment activity step
-(void) logComputerAssessmentLoadNextActivityStep : (NSString*) buttonPressedValue : (NSString *) computerActionValue : (NSString*) currAssesmentActivityStepValue : (NSString*) nextAssessmentActivityStepValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString*) currentAssessmentStep;

//log user pressed next button
-(void) logUserAssessmentPressedNext : (NSString*) buttonPressedVaue : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString*) currentAssessmentStep;

//log user pressed answer option
-(void) logUserAssessmentPressedAnswerOption : (NSString*) questionText :  (NSInteger) answerOptionSelected : (NSArray*) answerOptions : (NSString*) buttonPressedVaue : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString*) currentAssesssmentStep;

//log if answer selection was correct or incorrect and what they selected
-(void) logComputerAssessmentAnswerVerification : (BOOL) verificationValue : (NSString*) questionText :  (NSInteger) answerOptionSelected : (NSArray*) answerOptions : (NSString*) buttonPressedVaue : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString*) currentAssessmentStep;

//log start of next assessment activity
-(void) logComputerAssessmentDisplayStep : (NSString*) questionText : (NSArray*) answerOptions : (NSString*) buttonPressedVaue : (NSString *) computerActionValue : (NSString *) storyValue : (NSString *) chapterValue : (NSString*) currentAssesmentStep;


//write xml file locally
- (BOOL) writeToFile: (NSString *)fileName ofType:(NSString *)type;

@end





