//
//  Chapter.h
//  EMBRACE_Client
//
//  Created by Andreea Danielescu on 6/5/13.
//  Copyright (c) 2013 Andreea Danielescu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhysicalManipulationActivity.h"
#import "ImagineManipulationActivity.h"

@interface Chapter : NSObject {
    NSString *title; //Title of this chapter.
    NSString* chapterTitlePage; //Any page associated with the chapter title. 
    NSString *chapterImagePath; //Any image path that may be associated with a cover page for this chapter.
    NSString* chapterId;
    NSInteger pageNum; //page number the chapter starts on. 
    NSMutableArray* content; //NOTE: This is being stored but not currently being used anywhere. It may be worthwhile to collapse the activities in the content array and contain all content in one place.
    NSMutableArray* activities; //List of activities corresponding to this chapter.
}

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* chapterTitlePage;
@property (nonatomic, strong) NSString* chapterImagePath;
@property (nonatomic, strong) NSString* chapterId;
@property (nonatomic, strong) NSMutableArray* content;
@property (nonatomic, strong) NSMutableArray* activities;
@property (nonatomic, assign) NSInteger pageNum;

-(void) addActivity:(Activity*)activity; //Add an activity to the chapter.

-(Activity*) getActivityOfType:(Mode) mode;

-(NSString*) getNextPageForMode:(Mode) mode :(NSString*)currentPage;  //Get the next page in this chapter.
@end
