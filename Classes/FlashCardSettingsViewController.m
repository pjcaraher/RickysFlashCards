//
//  FlashCardsSettingsViewController.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/5/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "FlashCardSettingsViewController.h"
#import "AboutViewController.h"
#import "VoicesListController.h"
#import "ConfigurationController.h"
#import "FlashCardViewController.h"

#define TOP_SECTION 0
#define SECOND_SECTION 1

#define TAG_ABOUT 0
#define TAG_VOICES 0
#define TAG_CONFIGURE 1


@implementation FlashCardSettingsViewController

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
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

- (IBAction) done:(id)sender
{
	FlashCardViewController	*controller = [[[UIApplication sharedApplication] keyWindow] delegate];
	
	// When the done button is clicked, remove the Settings Navigation Controller.
	[[[self navigationController] view] removeFromSuperview];
	// Send the chalkboard to the background.
	[controller moveChalkboardToBack];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
	NSInteger	numSections = 2;
	
	return numSections;
}

- (NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section {
	// Let's skip the section titles
	return nil;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numRows = 0;
	
	switch (section) {
		case TOP_SECTION:
			numRows = 1;
			break;
		case SECOND_SECTION:
			numRows = 2;
		default:
			break;
	}
	
    return numRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	int	row = indexPath.row;
	int section = indexPath.section;
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
    // Configure the cell...
	switch (section) {
		case TOP_SECTION:
			if (TAG_ABOUT == row) {
				[[cell textLabel] setText:@"About"];
			}
			break;
		case SECOND_SECTION:
			if (TAG_VOICES == row) {
				[[cell textLabel] setText:@"Voices"];
			} else if (TAG_CONFIGURE == row) {
				[[cell textLabel] setText:@"Configuration"];
			}			
		default:
			break;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int	row = indexPath.row;
	int section = indexPath.section;
	
	switch (section) {
		case TOP_SECTION:
			if (TAG_ABOUT == row) {
				AboutViewController	*aboutViewController = [[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil] autorelease];
				aboutViewController.title = @"About";
				
				[self.navigationController pushViewController:aboutViewController
													 animated:YES];
			}
			break;
		case SECOND_SECTION:
			if (TAG_VOICES == row) {
				VoicesListController	*voicesListController = [[[VoicesListController alloc] initWithNibName:@"VoicesListController" bundle:nil] autorelease];
				voicesListController.title = @"Voices";
				
				[self.navigationController pushViewController:voicesListController
													 animated:YES];
			} else if (TAG_CONFIGURE == row) {
				ConfigurationController	*configurationController = [[[ConfigurationController alloc] initWithNibName:@"ConfigurationController" bundle:nil] autorelease];
				configurationController.title = @"Configuration";
				
				[self.navigationController pushViewController:configurationController
													 animated:YES];
			}			
		default:
			break;
	}
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
    [super dealloc];
}


@end

