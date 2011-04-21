//
//  ConfigurationController.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/15/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "ConfigurationController.h"
#import "RickysFlashCardsAppDelegate.h"

@implementation ConfigurationController

@synthesize minLabel;
@synthesize maxLabel;
@synthesize minSlider;
@synthesize maxSlider;
@synthesize operatorControl;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
 */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	NSUInteger index = 0;
	[self.minLabel setText:[[NSString alloc] initWithFormat:@"%i", [delegate currentMin]]];
	[self.maxLabel setText:[[NSString alloc] initWithFormat:@"%i", [delegate currentMax]]];
	
	self.minSlider.value = [delegate currentMin];
	self.maxSlider.value = [delegate currentMax];
	
	// Set the operator
	while (index < [operatorControl numberOfSegments]) {
		if ([[delegate currentOperator] compare:[operatorControl titleForSegmentAtIndex:index]] == NSOrderedSame) {
			[operatorControl setSelectedSegmentIndex:index];
			break;
		}
		index++;
	}
	
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

- (IBAction) setMinValue:(id)sender
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	float value = [(UISlider*)sender value];
	int roundedValue = round(value);
	
	// Set the value in the delegate
	[delegate setCurrentMin:(NSInteger)roundedValue];
	
	// Display the minValue in the delegate - this may be different, due to constraints	
	[minLabel setText:[NSString stringWithFormat:@"%i", [delegate currentMin]]];
	
	if (roundedValue != [delegate currentMin]) {
		self.minSlider.value = [delegate currentMin];
	}
}

- (IBAction) setMaxValue:(id)sender
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	float value = [(UISlider*)sender value];
	int roundedValue = round(value);
	
	// Set the value in the delegate
	[delegate setCurrentMax:(NSInteger)roundedValue];
	
	// Display the maxValue in the delegate - this may be different, due to constraints	
	[maxLabel setText:[NSString stringWithFormat:@"%i", [delegate currentMax]]];
	
	if (roundedValue != [delegate currentMax]) {
		self.maxSlider.value = [delegate currentMax];
	}
}

- (IBAction) setOperand:(id)sender
{
	RickysFlashCardsAppDelegate	*delegate = [[UIApplication sharedApplication] delegate];
	
	[delegate setCurrentOperator:[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]];
}

- (void)dealloc {
	[minLabel release];
	[maxLabel release];
	[minSlider release];
	[maxSlider release];
	[operatorControl release];
	
    [super dealloc];
}


@end
