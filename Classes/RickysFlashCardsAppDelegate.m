//
//  RickysFlashCardsAppDelegate.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/3/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "RickysFlashCardsAppDelegate.h"
#import "FlashCardViewController.h"
#import "MATCDatabaseController.h"

#include <stdlib.h>

#define NUMBER_OF_PAIRS_TO_GENERATE 50

#define NON_EDIT_VOICE_RICKY @"Ricky"
#define NON_EDIT_VOICE_MARK @"Mark"

#define DEFAULT_VOICE_NAME NON_EDIT_VOICE_RICKY
#define DEFAULT_CURRENT_MAX 12
#define DEFAULT_CURRENT_MIN 0
#define DEFAULT_CURRENT_OPERATOR @"+"

#define KEY_CURRENT_VOICE_NAME @"CurrentVoiceName"
#define KEY_SOUND_ON @"SoundOn"
#define KEY_CURRENT_MAX @"CurrentMax"
#define KEY_CURRENT_MIN @"CurrentMin"
#define KEY_CURRENT_OPERATOR @"CurrentOperator"


#define TEMPLATE_NAME_HUNDRED @"Hundred"
#define TEMPLATE_NAME_AND @"And"
#define TEMPLATE_NAME_PLUS @"Plus"
#define TEMPLATE_NAME_MINUS @"Minus"
#define TEMPLATE_NAME_DIVIDED_BY @"DividedBy"
#define TEMPLATE_NAME_TIMES @"Times"
#define TEMPLATE_NAME_EQUALS @"Equals"

#define OPERATOR_PLUS @"+"
#define OPERATOR_MINUS @"-"
#define OPERATOR_DIVIDE @"/"
#define OPERATOR_MULTIPLY @"x"

@interface RickysFlashCardsAppDelegate (Private)
- (NSMutableArray *) _generateOperandPairs:(NSUInteger)size;
- (NSArray *) _generateResultFor:(NSUInteger)operand1 :(NSUInteger)operand2 :(NSString*)operator;
- (void) _initializeDefaults;
- (NSArray *) _voiceTemplateNamesForValue:(NSString*)value;
- (NSString *) translateOperatorToName:(NSString*)value;
@end

@implementation RickysFlashCardsAppDelegate

@synthesize window;
@dynamic soundOn;
@synthesize managedObjectContext;
@dynamic currentVoiceName;
@dynamic currentMax;
@dynamic currentMin;
@dynamic currentOperator;
@synthesize operandPairs;
@dynamic voiceTemplateDictionary;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
	NSError	*error = nil;
	
    [self _initializeDefaults];
	
	// Configure the AVAudioSession object to be Playback only
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	// Switch it to playback after recording has completed.
	[audioSession setCategory:AVAudioSessionCategoryAmbient error: &error];
//	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
	// Activate the session
	[audioSession setActive:YES error: &error];
	
	if (error) {
		NSLog(@"Error setting up the AVAudioSession [%@]", error);
	}
	
	// Load up the database.
	managedObjectContext_ = [[MATCDatabaseController sharedDatabaseController] managedObjectContext];
	
    // Override point for customization after application launch.
	FlashCardViewController	*flashCardViewController = [[FlashCardViewController alloc] initWithNibName:@"FlashCardViewController" bundle:nil];
	[window addSubview:flashCardViewController.view];
    [window makeKeyAndVisible];
    
//	[flashCardViewController release];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSError	*error = nil;
    [self saveContext:&error];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	NSUserDefaults	*prefs = [NSUserDefaults standardUserDefaults];
	
	// Save out defaults when we exit.
	[prefs synchronize];
}

/**
 Returns the URL for the recording file matching the given voice and template.
 **/
- (NSURL *) recordingFileURLForVoice:(NSManagedObject*)voiceObj template:(NSManagedObject*)templateObj {
	NSString *name = [voiceObj valueForKey:VOICE_NAME_KEY];
	NSString *template = [templateObj valueForKey:VOICE_TEMPLATE_FILENAME_KEY];
	
	return [self recordingFileURLForVoiceName:name templateName:template];
}

- (NSURL *) recordingFileURLForVoiceName:(NSString*)name templateName:(NSString*)template {
	NSString *documentsDirectory = [self applicationDocumentsDirectory];
	NSString *soundFilePath = nil;
	
	if (TRUE == [self voiceNameIsEditable:name]) {
		soundFilePath = [documentsDirectory 
						 stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@.%@", name, template, @"caf"]];
	} else {
		soundFilePath = [[NSBundle mainBundle] 
						 pathForResource:[NSString stringWithFormat: @"%@.%@", name, template] 
							ofType:@"caf"];
	}
	
	NSURL* recordingFile = [NSURL fileURLWithPath:soundFilePath];
	
	return recordingFile;
}

- (BOOL)saveContext:(NSError**)error {
    BOOL	saveOk = TRUE;
	NSError	*saveError = nil;
	
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&saveError]) {
			*error = saveError;
			saveOk = FALSE;
        } 
    }
	
	return saveOk;
}

- (NSTimeInterval) soundDurationForValue:(NSString*)value
{
	NSArray	*templateNames = [self _voiceTemplateNamesForValue:value];
	NSTimeInterval	totalInterval = 0.0;
	NSEnumerator	*enumerator = [templateNames objectEnumerator];
	NSString	*name = nil;
	NSNumber	*interval;
	
	while (name = [enumerator nextObject]) {
		interval = [[self voiceTemplateDictionary] objectForKey:name];
		if (nil != interval) {
			// totalInterval += [(NSNumber *)[template valueForKey:@"duration"] floatValue];
			totalInterval += [interval doubleValue];
		}
	}
	
	return totalInterval;
}

- (void) playSoundForValue:(NSString*)value
{
	NSArray	*templateNames = [self _voiceTemplateNamesForValue:value];
	NSEnumerator	*enumerator = [templateNames objectEnumerator];
	NSString	*name = nil;
	NSTimeInterval	delay = 0.0;
	NSTimeInterval now = 0.0;
	NSError	*error;	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	while (name = [enumerator nextObject]) {
		NSURL *soundFileURL = [self recordingFileURLForVoiceName:[self currentVoiceName] templateName:name];
		AVAudioPlayer * avPlayer = nil;
		
		if (![fileManager fileExistsAtPath:[soundFileURL path]]) {
			soundFileURL = [self recordingFileURLForVoiceName:DEFAULT_VOICE_NAME templateName:name];
		}
		
		if ([fileManager fileExistsAtPath:[soundFileURL path]]) {
			avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
				
			if (nil != error) {
				NSLog(@"error is %@", error);
				[error release];
				error = nil;
				break;
			} else {			
				if (now == 0.0) {
					now = avPlayer.deviceCurrentTime;
				}
				
				[avPlayer prepareToPlay];
				[avPlayer playAtTime:now + delay];
				
				delay += 1.0;
			}
		}
	}
}

- (void) playSoundForTemplateName:(NSString*)templateName
{
	NSURL *soundUrl = [self recordingFileURLForVoiceName:[self currentVoiceName] templateName:templateName];
	
	if (nil != soundUrl) {
		[self playSoundForFileURL:soundUrl];
	}
}

- (void) playSoundForFileURL:(NSURL*)soundFileURL 
{
	NSError	*error;	
	
	if (nil != soundFileURL) {
		AVAudioPlayer * avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
		[avPlayer prepareToPlay];
		[avPlayer play];
	}
	
}

- (NSString*) currentVoiceName
{
	NSString	*retVal = currentVoiceName;
	
	if (nil == currentVoiceName) {
		retVal = DEFAULT_VOICE_NAME;
	}
	
	return retVal;
}

- (void) setCurrentVoiceName:(NSString *)value
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:value forKey:KEY_CURRENT_VOICE_NAME];
	
	currentVoiceName = value;
	[currentVoiceName retain];
}

- (BOOL) soundOn
{
	return soundOn;
}

- (void) setSoundOn:(BOOL)torf
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:torf forKey:KEY_SOUND_ON];
	[prefs synchronize];
	
	soundOn = torf;
}

- (NSInteger) currentMax 
{
	return currentMax;
}

- (void) setCurrentMax:(NSInteger)val
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// Ensure that new max is >= currentMin
	if (val >= [self currentMin]) {
		currentMax = val;
		[prefs setInteger:currentMax forKey:KEY_CURRENT_MAX];
		[prefs synchronize];
		// Clear out the operand pairs when we re-se the min
		[self setOperandPairs:[NSMutableArray array]];
	}
}

- (NSInteger) currentMin 
{
	return currentMin;
}

- (void) setCurrentMin:(NSInteger)val
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// Ensure that new min is <= currentMax
	if (val <= [self currentMax]) {
		currentMin = val;
		[prefs setInteger:currentMin forKey:KEY_CURRENT_MIN];
		[prefs synchronize];
		// Clear out the operand pairs when we re-se the min
		[self setOperandPairs:[NSMutableArray array]];
	}
}

- (BOOL) voiceNameIsEditable:(NSString*)name
{
	BOOL	canEditVoice = TRUE;
	
	if ([nonEditVoiceNames containsObject:name]) {
		canEditVoice = FALSE;
	}
	
	return canEditVoice;
}

/**
 Pop and return the next set of operands and result.
 **/
- (NSArray *) popEquation
{
	NSArray *retVal = (NSArray*)[[self operandPairs] lastObject];
	
	// Create more operand pairs if we have emptied the current set.
	if (nil == retVal) {
		[self setOperandPairs:[self _generateOperandPairs:NUMBER_OF_PAIRS_TO_GENERATE]];
		retVal = (NSArray*)[[self operandPairs] lastObject];
	}
	
	if (nil != retVal) {
		[retVal retain];
	}
	
	// Make certain that the lastObject is removed
	[[self operandPairs] removeLastObject];
	
	return retVal;
}

- (NSString*) currentOperator
{
	return currentOperator;
}

- (void) setCurrentOperator:(NSString *)val
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[val retain];
	[currentOperator release];
	currentOperator = val;
	
	[prefs setObject:val forKey:KEY_CURRENT_OPERATOR];
	[prefs synchronize];
	
	// Clear out the operand pairs when we re-set the operator
	[self setOperandPairs:[NSMutableArray array]];
}

// Fetch and return the template for the given name.
- (NSManagedObject*) voiceTemplateForName:(NSString*)name
{
	return [[self voiceTemplateDictionary] objectForKey:[self translateOperatorToName:name]];
}

- (NSDictionary *)voiceTemplateDictionary 
{
	if (nil == voiceTemplateDictionary) {
		/*
		 Set up the fetched results controller.
		 */
		NSFetchedResultsController	*resultsController = nil;		
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext *managedObjectContext = [[MATCDatabaseController sharedDatabaseController] managedObjectContext];
		// Edit the entity name as appropriate.
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"VoiceTemplate" inManagedObjectContext:managedObjectContext];
		NSError *error = nil;
		NSEnumerator	*enumerator;
		NSManagedObject	*template;

		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:[NSArray array]];
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Templates"];
		
		if (![resultsController performFetch:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately. 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
		voiceTemplateDictionary = [[[NSMutableDictionary alloc] initWithCapacity:[[resultsController fetchedObjects] count]] retain];
		enumerator = [[resultsController fetchedObjects] objectEnumerator];
		while (template = (NSManagedObject*)[enumerator nextObject]) {
			NSLog(@"filename for template is %@", [template valueForKey:@"filename"]);
			[(NSMutableDictionary*)voiceTemplateDictionary setObject:[NSNumber numberWithDouble:[[template valueForKey:@"duration"] doubleValue]] forKey:[template valueForKey:@"filename"]];
		}

		 NSLog(@"voiceTemplateDictionary is %@", voiceTemplateDictionary);
	}
	
	return voiceTemplateDictionary;
}    

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
	
    [window release];
	[currentVoiceName release];
	[currentOperator release];
	[operandPairs release];
	[voiceTemplateDictionary release];
	[nonEditVoiceNames release];
	
    [super dealloc];
}


@end

@implementation RickysFlashCardsAppDelegate (Private)

- (NSMutableArray *) _generateOperandPairs:(NSUInteger)size
{
	NSMutableArray	*pairs = [[NSMutableArray alloc] initWithCapacity:size];
	int index = 0;
	NSInteger	min = [self currentMin];
	NSInteger	max = [self currentMax];
	NSInteger	operand1;
	NSInteger	operand2;
	int modulus = max - min + 1;
	
	// Sanity check.
	if (modulus <= 0) {
		NSLog(@"Mismatched min [%i] and max [%i]!", min, max);
		modulus += 1;
	}
	
	for (; index < size; index++) {
		operand1 = (arc4random() % modulus) + min;
		operand2 = arc4random() % modulus + min;
		[pairs addObject:[self _generateResultFor:operand1 :operand2 :[self currentOperator]]];
	}
	
	return pairs;
}

- (NSArray *) _generateResultFor:(NSUInteger)operand1 :(NSUInteger)operand2 :(NSString*)operator
{
	NSInteger	result = 0;
		
	if ([OPERATOR_PLUS compare:operator] == NSOrderedSame) {
		result = operand1 + operand2;
	} else if ([OPERATOR_MINUS compare:operator] == NSOrderedSame) {
		if (operand2 > operand1) {
			NSUInteger tmpValue = operand1;
			operand1 = operand2;
			operand2 = tmpValue;
		}
		result = operand1 - operand2;
	} else if ([OPERATOR_DIVIDE compare:operator] == NSOrderedSame) {
		// For division, the result is operand1.  We then multiply
		// the two operands to get our numerator.  This way, there 
		// are no fractional divides.
		
		// First, no divide by 0
		if (0 >= operand2) {
			operand2 = 1;
		}
		result = operand1;
		operand1 = operand1 * operand2;
	} else if ([OPERATOR_MULTIPLY compare:operator] == NSOrderedSame) {
		result = operand1 * operand2;
	}
	
	return [NSArray arrayWithObjects:[NSNumber numberWithInteger:operand1], [NSNumber numberWithInteger:operand2], [NSNumber numberWithInteger:result], nil];
}

- (void)_initializeDefaults
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *_currentVoiceName = (NSString *)[prefs objectForKey:KEY_CURRENT_VOICE_NAME];
	BOOL _soundOn = (BOOL)[prefs boolForKey:KEY_SOUND_ON];
	NSInteger _currentMax = [prefs integerForKey:KEY_CURRENT_MAX];
	NSInteger _currentMin = [prefs integerForKey:KEY_CURRENT_MIN];
	NSString *_currentOperator = [prefs stringForKey:KEY_CURRENT_OPERATOR];
	
	nonEditVoiceNames = [[NSSet setWithObjects:NON_EDIT_VOICE_RICKY,NON_EDIT_VOICE_MARK,nil] retain];
	
	if (nil == _currentOperator) {
		currentOperator = [DEFAULT_CURRENT_OPERATOR retain];
	} else {
		currentOperator = [_currentOperator retain];
	}
	
	if (nil == _currentVoiceName) {
		currentVoiceName = [DEFAULT_VOICE_NAME retain];
	} else {
		currentVoiceName = [_currentVoiceName retain];
	}
	
	[self setSoundOn:_soundOn];
	
	if (0 == _currentMax) {
		currentMax = DEFAULT_CURRENT_MAX;
		[prefs setInteger:currentMax forKey:KEY_CURRENT_MAX];
	} else {
		currentMax = _currentMax;
	}
	
	if (0 == _currentMin) {
		currentMin = DEFAULT_CURRENT_MIN;
		[prefs setInteger:currentMin forKey:KEY_CURRENT_MIN];
	} else {
		currentMin = _currentMin;
	}

	[self setOperandPairs:[self _generateOperandPairs:NUMBER_OF_PAIRS_TO_GENERATE]];
}

- (NSArray *) _voiceTemplateNamesForValue:(NSString*)value
{
	NSInteger	number = [value integerValue];
	int			quotient = 0;
	NSMutableArray	*retVal = [[NSMutableArray alloc] init];
	BOOL		andRequired = FALSE;
	
	if (number != 0) {
		// Parse out the hundreths place
		quotient = (number / 100);
		if (quotient > 0) {
			[retVal addObject:[NSString stringWithFormat:@"%i", quotient]];
			[retVal addObject:TEMPLATE_NAME_HUNDRED];
			// Ricky does not like And.
			// andRequired = TRUE;
			number = number - (quotient * 100);
		}
		
		// Parse out the tens place
		// We have a unique value for 1-19
		quotient = (number / 10);
		if (quotient > 1) {
			if (TRUE == andRequired) {
				[retVal addObject:TEMPLATE_NAME_AND];
				// Ricky does not like And.
				// andRequired = FALSE;
			}
			[retVal addObject:[NSString stringWithFormat:@"%i0",quotient]];
			number = number - (quotient * 10);
		}
		
		if (number > 0) {
			if (TRUE == andRequired) {
				[retVal addObject:TEMPLATE_NAME_AND];
				// Ricky does not like And.
				// andRequired = FALSE;
			}
			[retVal addObject:[NSString stringWithFormat:@"%i", number]];
		}
		
	} else {
		// We are either 0 or one of the operator templates.
		[retVal addObject:[self translateOperatorToName:value]];
	}
	
	return retVal;
}

// Check the value to see if it is one of the operators.
// If so, convert to it's filename.  Else, return the
// given value as is.
- (NSString *) translateOperatorToName:(NSString*)value
{
	if ([@"+" compare:value] == NSOrderedSame) {
		value = TEMPLATE_NAME_PLUS;
	} else if ([@"-" compare:value] == NSOrderedSame) {
		value = TEMPLATE_NAME_MINUS;
	} else if ([@"/" compare:value] == NSOrderedSame) {
		value = TEMPLATE_NAME_DIVIDED_BY;
	} else if ([@"x" compare:value] == NSOrderedSame) {
		value = TEMPLATE_NAME_TIMES;
	} else if ([@"=" compare:value] == NSOrderedSame) {
		value = TEMPLATE_NAME_EQUALS;
	}
	
	return value;
}

@end