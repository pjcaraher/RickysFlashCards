//
//  FlashCardViewController.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/3/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "FlashCardViewController.h"
#import "FlashCardLandscapeViewController.h"
#import "FlashCardSettingsViewController.h"
#import "RickysFlashCardsAppDelegate.h"

@interface FlashCardViewController (Private)
- (void) _animateEquals;
- (void) _animateEquation;
- (void) _animateOperand2;
- (void) _animateOperator;
- (void) _animateResult;
- (void) _newEquation;
- (void) _playSoundForLabel:(UILabel*)label;
@end

@implementation FlashCardViewController

@synthesize operand1;
@synthesize operand2;
@synthesize theOperator;
@synthesize result;
@synthesize equalsButton;
@synthesize nextEquationButton;
@synthesize replayButton;
@synthesize backgroundImage;
@synthesize bar;
@synthesize flashCardSettingsNavigationController;
@synthesize landscapeViewController;
@synthesize playEqual;
@synthesize isShowingLandscapeView;
@synthesize startAnimationTime;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// [self _additionalInit];
	}
	
	return self;
	
}

// Put in this method to differentiate from the FlashCardLanscapeViewController,
// which is a subclass.  The subclass will override this method to do nothing.
- (void) _additionalInit 
{
	isShowingLandscapeView = NO;		
	self.landscapeViewController = [[[FlashCardLandscapeViewController alloc]										 
									 initWithNibName:@"FlashCardLandscapeViewController" bundle:nil] autorelease];


	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(orientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[self _newEquation];
    [super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
	/*
	We have to work out some kinks with regards to the landscape orientation.
	We have to handle when the settings button is hit (we should revert to portrait)
	We also need to mind the backgroundImage when the user changes orientation while
	looking at the settings.  (This may be able to be managed via trapping the change
	in orientation - for example, if we hit settings from landscape and then rotate
	to portrait, we should be able to trap an event.)
		
	The cleanest method of getting this done is to keep everything within the
	 single controller and then rotate the view and re-arrange all of the Outlets.
	 */
    // return ((interfaceOrientation == UIInterfaceOrientationPortrait)
	//		|| (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}
*/
	
#pragma mark -
#pragma mark OrientationChanged
	
- (void)old_orientationChanged:(NSNotification *)notification
{
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	
	if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView)
	{
		[self presentModalViewController:self.landscapeViewController animated:YES];
		isShowingLandscapeView = YES;
	}
	
	else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView)
	{
		[self dismissModalViewControllerAnimated:YES];
		isShowingLandscapeView = NO;
	}
}


#pragma mark -
#pragma mark Button actions
- (IBAction) equalClicked:(id)sender
{
	[equalsButton removeFromSuperview];
//	[self.view addSubview:nextEquationButton];
	[self setPlayEqual:TRUE];
//	[self _animateEquation];
    [self _animateEquals];
}

- (IBAction) newEquationClicked:(id)sender
{
//	[nextEquationButton removeFromSuperview];
	[self.view addSubview:equalsButton];
	[self _newEquation];
	[self setPlayEqual:FALSE];
	[self _animateEquation];
}

- (IBAction) replayEquation:(id)sender
{
	[self _animateEquation];
}

- (IBAction) showSettings:(id)sender
{
	id mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	UINavigationController	*navigationController = self.flashCardSettingsNavigationController;
	
	if (nil == navigationController) {
		UINavigationItem *navigationItem = nil;
		FlashCardSettingsViewController	*settingsRootViewController = [[[FlashCardSettingsViewController alloc] 
									initWithNibName:@"FlashCardSettingsViewController" 
									bundle:nil] autorelease];
		UIBarButtonItem	*rightButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:settingsRootViewController action:@selector(done:)] autorelease];

		navigationController = [[[UINavigationController alloc] 
									initWithRootViewController:settingsRootViewController] autorelease];
		
		settingsRootViewController.title = @"Settings";
		navigationItem = [settingsRootViewController navigationItem];
		 [navigationItem setRightBarButtonItem:rightButton];
		self.flashCardSettingsNavigationController = navigationController;
	}
	
	// Move the chalkboard background up front
	[self.view bringSubviewToFront:backgroundImage];
	
	[mainWindow addSubview:navigationController.view];
}

// This is a bit of a hack, but it is a counter to when
// the backgroundimage is moved to the front when we showSettings.
// The reason for all of this is it allows a consistent background
// when navigating through the Navigation tableView screens.
- (void) moveChalkboardToBack
{
	[self.view sendSubviewToBack:backgroundImage];
	if (nil != self.landscapeViewController) {
		[self.landscapeViewController moveChalkboardToBack];
	}
}

- (void)dealloc {
	[operand1 release];
    [operand2 release];
    [theOperator release];
    [result release];
	[equalsButton release];
	[nextEquationButton release];
	[replayButton release];
	[backgroundImage release];
	[flashCardSettingsNavigationController release];
	[landscapeViewController release];
	[startAnimationTime release];
	[bar release];
	
    [super dealloc];
}

@end

@implementation FlashCardViewController (Private)

- (void) _animateEquals
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSTimeInterval	duration = [delegate soundDurationForValue:@"Equals"];
	
	[UIView animateWithDuration:duration
					 animations:^{ 
						 [delegate playSoundForValue:@"="];
						 result.alpha = 1.0; 
					 }
					 completion:^(BOOL finished){ if (TRUE == finished) {[self _animateResult];} }];
}

- (void) _animateEquation
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSTimeInterval	duration = [delegate soundDurationForValue:operand1.text];

	operand1.alpha = 0.0;
	operand2.alpha = 0.0;
	theOperator.alpha = 0.0;
	result.alpha = 0.0;
	
	[self setStartAnimationTime:[NSDate date]];
	[UIView animateWithDuration:duration
					 animations:^{ 
						 [delegate playSoundForValue:operand1.text];
						 operand1.alpha = 1.0; 
					 }
					 completion:^(BOOL finished){ if (TRUE == finished) {[self _animateOperator];} }];
}

- (void) _animateOperand2
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSTimeInterval	duration = [delegate soundDurationForValue:operand2.text];
	
	[UIView animateWithDuration:duration
					 animations:^{ 
						 [delegate playSoundForValue:operand2.text];
						 operand2.alpha = 1.0; 
						 equalsButton.enabled = TRUE;
					 }
					 completion:^(BOOL finished){ 
										if (TRUE == finished) {
											if(TRUE == self.playEqual) {
												[self _animateEquals];
											}
										} 
								}];
}

- (void) _animateOperator
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSTimeInterval	duration = [delegate soundDurationForValue:operand2.text];
	
	[UIView animateWithDuration:duration
					 animations:^{ 
						 [delegate playSoundForValue:theOperator.text];
						 theOperator.alpha = 1.0; 
					 }
					completion:^(BOOL finished){ if (TRUE == finished) {[self _animateOperand2];} }];
}


- (void) _animateResult
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSTimeInterval	duration = [delegate soundDurationForValue:result.text];
	
	[UIView animateWithDuration:duration
					 animations:^{ 
						 [delegate playSoundForValue:result.text];
					 }
					 completion:NULL];
}

- (void) _newEquation
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSArray	*equation = [[delegate popEquation] autorelease];
	
	operand1.text = [NSString stringWithFormat:@"%@", [equation objectAtIndex:0]];
	operand2.text = [NSString stringWithFormat:@"%@", [equation objectAtIndex:1]];
	result.text = [NSString stringWithFormat:@"%@", [equation objectAtIndex:2]];
	
	theOperator.text = [delegate currentOperator];
}

- (void) _playSoundForLabel:(UILabel*)label
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	[delegate playSoundForValue:label.text];	
}

@end

