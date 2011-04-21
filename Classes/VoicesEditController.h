//
//  VoicesEditController.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VoicesEditController : UITableViewController <UITextFieldDelegate> {
	NSManagedObject	*voice;
	IBOutlet UIView	*editNameView;
	IBOutlet UILabel *errorMessage;
	IBOutlet UITextField	*voiceNameText;
	NSFetchedResultsController *fetchedTemplatesResultsController;
}

@property (nonatomic, assign) NSManagedObject	*voice;
@property (nonatomic, assign) UIView	*editNameView;
@property (nonatomic, assign) UILabel	*errorMessage;
@property (nonatomic, assign) UITextField	*voiceNameText;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedTemplatesResultsController;

- (IBAction) saveNameUpdate:(id)sender;

@end
