//
//  RickysFlashCardsAppDelegate.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/3/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>

#define VOICE_NAME_KEY @"name"
#define VOICE_TEMPLATE_NAME_KEY @"name"
#define VOICE_DURATION_KEY @"duration"
#define VOICE_TEMPLATE_FILENAME_KEY @"filename"

@interface RickysFlashCardsAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	BOOL	soundOn;
	NSString	*currentVoiceName;
	NSInteger	currentMax;
	NSInteger	currentMin;
	NSString	*currentOperator;
	NSMutableArray		*operandPairs;
	NSDictionary	*voiceTemplateDictionary;
	NSSet		*nonEditVoiceNames;
@private
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic) BOOL soundOn;
@property (nonatomic, retain) NSString	*currentVoiceName;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite) NSInteger	currentMax;
@property (nonatomic, readwrite) NSInteger currentMin;
@property (nonatomic, retain) NSString	*currentOperator;
@property (nonatomic, retain) NSMutableArray	*operandPairs;
@property (nonatomic, readonly) NSDictionary	*voiceTemplateDictionary;

- (NSString *)applicationDocumentsDirectory;
- (NSTimeInterval) soundDurationForValue:(NSString*)value;
- (void) playSoundForValue:(NSString*)value;
- (void) playSoundForTemplateName:(NSString*)templateName;
- (void) playSoundForFileURL:(NSURL*)soundFileURL; 
- (NSURL *) recordingFileURLForVoice:(NSManagedObject*)voiceObj template:(NSManagedObject*)templateObj;
- (NSURL *) recordingFileURLForVoiceName:(NSString*)name templateName:(NSString*)template;
- (BOOL) voiceNameIsEditable:(NSString*)name;
- (NSArray *) popEquation;
- (NSManagedObject*) voiceTemplateForName:(NSString*)name;
- (BOOL) saveContext:(NSError**)error;
@end

