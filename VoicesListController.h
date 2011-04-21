//
//  VoicesListController.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/5/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VoicesListController : UITableViewController {
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (IBAction) editVoicesButtonPressed:(id)sender event:(id)event;

@end
