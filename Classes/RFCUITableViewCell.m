//
//  RFCUITableViewCell.m
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/11/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import "RFCUITableViewCell.h"

@implementation RFCUITableViewCell

@synthesize nameLabel;
@synthesize leftImage;
@synthesize recordButton;
@synthesize playButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		
		// Create label views to contain the various pieces of text that make up the cell.
		// Add these as subviews.
		nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 0, 150, 40)] retain];
		nameLabel.backgroundColor = [UIColor whiteColor];
		nameLabel.opaque = YES;
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.highlightedTextColor = [UIColor blackColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:18];
		[self.contentView addSubview:nameLabel];
		
		//added to mark where the thumbnail image should go 
		//leftImage = [[[UIView alloc] initWithFrame:CGRectMake(4, 5, 30, 30)] retain];
		//[self.contentView addSubview:leftImage];
		
		UIImage *image = [UIImage imageNamed:@"record.png"];
		recordButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		
		recordButton.frame = CGRectMake(0.0, 0.0, 28.0, 28.0);
		[recordButton setBackgroundImage:image forState:UIControlStateNormal];
		recordButton.backgroundColor = [UIColor clearColor];
		self.accessoryView = recordButton;
	}
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) enablePlayButtonTarget:(id)target action:(SEL)action
{
	if (nil == playButton) {
		UIImage *image = [UIImage imageNamed:@"playButton.png"];
		playButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		playButton.frame = CGRectMake(4.0, 5.0, 28.0, 28.0);
		playButton.backgroundColor = [UIColor clearColor];
		[playButton setBackgroundImage:image forState:UIControlStateNormal];
		[playButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		
		[self.contentView addSubview:playButton];
	}
}

- (void) disablePlayButton
{
	if (nil != playButton) {
		[playButton removeFromSuperview];
		[playButton release];
		playButton = nil;
	}
}

- (void) setRecordButtonTarget:(id)target action:(SEL)action
{
	[recordButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
	[nameLabel release];
	[leftImage release];
	[recordButton release];
	[playButton release];
    [super dealloc];
}


@end
