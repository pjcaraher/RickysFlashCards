//
//  VoiceEditController.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/8/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "VoiceEditController.h"
#import "MATCDatabaseController.h"
#import "RickysFlashCardsAppDelegate.h"
#import "RFCUITableViewCell.h"

#define EDIT_VIEW_DISPLAY_TIME 1.0

@interface VoiceEditController (Private)
- (void) _displayEditNameView;
- (void) _hideEditNameView;
- (void) _initializeDefaults;
- (void) _playSoundForIndexPath:(NSIndexPath*)indexPath;
- (void) _recordForVoice:(NSManagedObject*)voiceObj template:(NSManagedObject*)templateObj;
- (NSURL *) _recordingURLForVoiceTemplate:(NSManagedObject*)voiceTemplate;
@end

@implementation VoiceEditController

@synthesize voice;
@synthesize editNameView;
@synthesize errorMessage;
@synthesize voiceNameText;
@synthesize recordButton;
@synthesize rightBarButton;
@synthesize duration;
@dynamic fetchedTemplatesResultsController;
@dynamic recorder;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	NSString	*name = [self.voice valueForKey:VOICE_NAME_KEY];
    [super viewDidLoad];
	
	[self _initializeDefaults];
	
	// If the name has not yet been defined, prompt.
	if ((nil == name) || ([name length] <= 0)) {
		[self _displayEditNameView];
	}

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
	// Skip the editing of the name for now.  Having problems with
	// displayEditNameView when button is pressed.
	// [self.navigationItem setRightBarButtonItem:rightBarButton animated:YES];
	
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	// If we have not saved yet, clear out any inserted objects
	// from the editingContext.
	NSManagedObjectContext *managedObjectContext = [[MATCDatabaseController sharedDatabaseController] managedObjectContext];
	
	[managedObjectContext reset];
	
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedTemplatesResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedTemplatesResultsController sections] objectAtIndex:section];
	NSLog(@"Number of rows is %d\n", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	NSManagedObject *managedObject = [self.fetchedTemplatesResultsController objectAtIndexPath:indexPath];
	RFCUITableViewCell *cell = (RFCUITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	NSURL	*recordingFileURL = [self _recordingURLForVoiceTemplate:managedObject];
	
    if (cell == nil) {
        cell = [[[RFCUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setRecordButtonTarget:self action:@selector(recordButtonPressed:event:)];
    }
    
	// Configure the cell.
	cell.nameLabel.text = [managedObject valueForKey:VOICE_TEMPLATE_NAME_KEY];

	// If we have a recording, show the play button
	if (nil != recordingFileURL) {
		[cell enablePlayButtonTarget:self action:@selector(playButtonPressed:event:)];
	} else {
		[cell disablePlayButton];
	}
	
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedTemplatesResultsController 
{
    NSFetchedResultsController	*retVal = fetchedTemplatesResultsController;
	
	if (retVal == nil) {
		/*
		 Set up the fetched results controller.
		 */
		// Create the fetch request for the entity.
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext *managedObjectContext = [[MATCDatabaseController sharedDatabaseController] managedObjectContext];
		// Edit the entity name as appropriate.
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"VoiceTemplate" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		
		// Set the batch size to a suitable number.
		[fetchRequest setFetchBatchSize:20];
		
		// Edit the sort key as appropriate.
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		
		[fetchRequest setSortDescriptors:sortDescriptors];
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
		aFetchedResultsController.delegate = self;
		fetchedTemplatesResultsController = [aFetchedResultsController retain];
		
		NSLog(@"fetchedTemplatesResultsController retainCount is %d", [fetchedTemplatesResultsController retainCount]);
		
		[aFetchedResultsController release];
		[fetchRequest release];
		[sortDescriptor release];
		[sortDescriptors release];
		
		NSLog(@"fetchedTemplatesResultsController retainCount is %d", [fetchedTemplatesResultsController retainCount]);
		retVal = fetchedTemplatesResultsController;
		
		NSError *error = nil;
		if (![retVal performFetch:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately. 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
	}
	
	return retVal;
}    

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = [self.fetchedTemplatesResultsController objectAtIndexPath:indexPath];
	NSURL	*recordingFileURL = [self _recordingURLForVoiceTemplate:managedObject];
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];

	NSError	*error = nil;
	// Re-configure the AVAudioSession object to be Playback only
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	// Switch it to playback after recording has completed.
	[audioSession setCategory:AVAudioSessionCategoryAmbient error: &error];
	
	if (nil != recordingFileURL) {
		[delegate playSoundForFileURL:recordingFileURL];
	}
	
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *voiceTemplate = [self.fetchedTemplatesResultsController objectAtIndexPath:indexPath];
	[self _recordForVoice:[self voice] template:voiceTemplate];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[voice release];
	[editNameView release];
	[errorMessage release];
	[voiceNameText release];
	[recordButton release];
	[rightBarButton release];
	[fetchedTemplatesResultsController release];
	[recorder release];
	[duration release];
	
    [super dealloc];
}

#pragma mark TextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	if(theTextField == voiceNameText) {
		[self saveNameUpdate:theTextField];
	}
	return YES;
}

- (IBAction) saveNameUpdate:(id)sender
{
	RickysFlashCardsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	BOOL	okToSave = TRUE;
	NSString	*errorString = @"Unable to create new Voice.";
	NSError	*error = nil;
	
	// Make certain that we have a name
	if ((nil == voiceNameText.text) 
		|| (voiceNameText.text.length <= 0) 
		|| ([[voiceNameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] <= 0)
		) {
		okToSave = FALSE;
		errorString = [NSString stringWithFormat:@"%@  A non-empty name must be provided.", errorString];
	}
	
	// Make certain that this name is not yet taken.
	/*
	if (okToSave) {
		okToSave = FALSE;
		errorString = [NSString stringWithFormat:@"%@  A voice already exists with the name '%@'.", errorString, voiceNameText.text];
	}
	*/
	
	if (okToSave) {
		[[self voice] setValue:voiceNameText.text forKey:VOICE_NAME_KEY];
		
		if (FALSE == [delegate saveContext:&error]) {
			// Post an error message
			if (([VALIDATION_ERROR_DOMAIN compare:[error domain]] == NSOrderedSame)
				&& (VALIDATION_ERROR_DUPLICATE_NAME == [error code])) {
					errorString = [NSString stringWithFormat:@"%@  A voice named '%@' already exists.", errorString, voiceNameText.text];
			} else {
				errorString = [NSString stringWithFormat:@"%@  Unable to save voice '%@'.", errorString, voiceNameText.text];
			}

			errorMessage.text = errorString;
			[self.view setNeedsDisplay];
		} else {
			self.title = [self.voice valueForKey:@"name"];
			[(UITableView *)self.view reloadData];
			[self _hideEditNameView];
		}
	} else {
		// Post an error message
		errorMessage.text = errorString;
		[self.view setNeedsDisplay];
	}
}

- (IBAction) editNameButtonPressed:(id)sender
{
	NSLog(@"edit name button pressed.");
	// Not working now.  Probably because we are in an action.
	// [self _displayEditNameView];
}

- (IBAction) playButtonPressed:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self _playSoundForIndexPath:indexPath];
	}
}

- (IBAction) recordButtonPressed:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	// Re-configure the AVAudioSession object to be Playback only
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	NSError	*error;
	// Switch it to playback after recording has completed.
	[audioSession setCategory:AVAudioSessionCategoryAmbient error: &error];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (0 == buttonIndex) {
		if (nil != recorder) {
			[recorder recordForDuration:(NSTimeInterval)[self.duration doubleValue]];
		}
		[[self tableView] reloadData];
	}
}

@end


@implementation VoiceEditController (Private)

- (void) _displayEditNameView
{
	CGRect	editNameViewRect = [self.editNameView frame];
	
	voiceNameText.text = [[self voice] valueForKey:VOICE_NAME_KEY];
	errorMessage.text = @"";
	
	// Start the animation
    [UIView beginAnimations:@"Show Name Edit" context:nil];
    [UIView setAnimationDuration:EDIT_VIEW_DISPLAY_TIME];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:[self view] cache:YES];
	self.editNameView.frame = CGRectMake(editNameViewRect.origin.x, 0.0, editNameViewRect.size.width, editNameViewRect.size.height);
	
	[[self view] addSubview:self.editNameView];
	
    [UIView commitAnimations];
}

- (void) _hideEditNameView
{
	CGRect	editNameViewRect = [self.editNameView frame];
	
	// Start the animation
    [UIView beginAnimations:@"Show Name Edit" context:nil];
    [UIView setAnimationDuration:EDIT_VIEW_DISPLAY_TIME];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[UIView setAnimationTransition:UIViewAnimationCurveEaseInOut forView:[self view] cache:YES];
	self.editNameView.frame = CGRectMake(editNameViewRect.origin.x, 360.0, editNameViewRect.size.width, editNameViewRect.size.height);
	
    [UIView commitAnimations];
	[self.editNameView removeFromSuperview];	
}


- (void) _initializeDefaults
{
	// For some reason, Interface Builder won't let me edit the x,y coordinates
	// of the editNameView.  So, we have to set them here.
	CGRect	editNameViewRect = [self.editNameView frame];
	self.editNameView.frame = CGRectMake(0, 360.0, editNameViewRect.size.width, editNameViewRect.size.height);
}
		 
- (void) _playSoundForIndexPath:(NSIndexPath*)indexPath
{
	NSManagedObject *managedObject = [self.fetchedTemplatesResultsController objectAtIndexPath:indexPath];
	NSURL	*recordingFileURL = [self _recordingURLForVoiceTemplate:managedObject];
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	
	if (nil != recordingFileURL) {
		[delegate playSoundForFileURL:recordingFileURL];
	}
	
}
		 
- (void) _recordForVoice:(NSManagedObject*)voiceObj template:(NSManagedObject*)templateObj {
	RickysFlashCardsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSNumber *templateDuration = [templateObj valueForKey:VOICE_DURATION_KEY];
	NSURL	*recordingFileURL = [delegate recordingFileURLForVoice:voiceObj template:templateObj];
	NSError * error = nil;
	UIAlertView	*alert = nil;
	NSString	*alertMessage = [NSString stringWithFormat:@"Click Record when you are ready to record \"%@\"", 
								 [templateObj valueForKey:VOICE_TEMPLATE_NAME_KEY]];
	
	[self setDuration:templateDuration];
	

	// Configure the AVAudioSession object.
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	// Setup the audioSession for record. 
	// Switch it to playback after recording has completed.
	[audioSession setCategory:AVAudioSessionCategoryRecord error: &error];
	
	//Activate the session
//	[audioSession setActive:YES error: &error];
	
	if (error)
		NSLog(@"Error setting category! %d", error);

	
	// Setup the dictionary object with all the recording settings for this Recording session
	// This is a good resource: http://www.totodotnet.net/tag/avaudiorecorder/
	NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
	//[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
	[recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey]; 
	[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	
	if (nil != recorder) {
		[recorder release];
	}
	recorder = [[AVAudioRecorder alloc] initWithURL:recordingFileURL 
										   settings:recordSetting 
											  error:&error];
	
	[recorder setDelegate:self];
	//We call this to start the recording process and initialize 
	//the subsstems so that when we actually say "record" it starts right away.
	[recorder prepareToRecord];
	//Start the actual Recording
	alert = [[UIAlertView alloc] initWithTitle:@"Record Voice" 
									   message:alertMessage 
									  delegate:self 
							 cancelButtonTitle:@"Record" 
							 otherButtonTitles:@"Cancel",nil];
	[alert show];
}

/**
 Returns NSURL of recording for indexPath or nil if none yet exists.
 **/
- (NSURL *) _recordingURLForVoiceTemplate:(NSManagedObject*)voiceTemplate
{
	RickysFlashCardsAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSURL *recordingFileURL = [delegate recordingFileURLForVoice:self.voice template:voiceTemplate];
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSURL *retVal = nil;
	
	if ([fileManager fileExistsAtPath:[recordingFileURL path]]) {
		NSLog(@"recording file exists at [%@]", [recordingFileURL path]);
		retVal = recordingFileURL;
	}
	
	return retVal;
}

@end

