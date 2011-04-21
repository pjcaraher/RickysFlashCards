//
//  RFCVoiceListUITableViewCell.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/24/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RFCVoiceListUITableViewCell : UITableViewCell {
	IBOutlet	UIButton	*editVoicesButton;
}

@property (nonatomic, retain) UIButton	*editVoicesButton;

- (void) setEditButtonTarget:(id)target action:(SEL)action;

@end
