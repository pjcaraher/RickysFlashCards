//
//  RFCVoiceListUITableViewCell.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/24/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "RFCVoiceListUITableViewCell.h"


@implementation RFCVoiceListUITableViewCell

@synthesize editVoicesButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// Create a button for editing the voices.
		editVoicesButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		
		editVoicesButton.frame = CGRectMake(0.0, 0.0, 28.0, 28.0);
		editVoicesButton.titleLabel.text = @">";
		self.accessoryView = editVoicesButton;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setEditButtonTarget:(id)target action:(SEL)action
{
	[editVoicesButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
	[editVoicesButton release];
	
    [super dealloc];
}


@end
