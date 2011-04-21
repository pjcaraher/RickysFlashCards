//
//  RFCUITableViewCell.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/11/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RFCUITableViewCell : UITableViewCell {
	IBOutlet UILabel	*nameLabel;
	IBOutlet UIView		*leftImage;
	IBOutlet UIButton	*recordButton;
	IBOutlet UIButton	*playButton;
}

@property (nonatomic, readonly) UILabel	*nameLabel;
@property (nonatomic, readonly) UIView	*leftImage;
@property (nonatomic, readonly) UIButton	*recordButton;
@property (nonatomic, readonly) UIButton	*playButton;

- (void) enablePlayButtonTarget:(id)target action:(SEL)action;
- (void) disablePlayButton;
- (void) setRecordButtonTarget:(id)target action:(SEL)action;

@end
