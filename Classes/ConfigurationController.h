//
//  ConfigurationController.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/15/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ConfigurationController : UIViewController {
	IBOutlet UILabel	*minLabel;
	IBOutlet UILabel	*maxLabel;
	IBOutlet UISlider	*minSlider;
	IBOutlet UISlider	*maxSlider;
	IBOutlet UISegmentedControl	*operatorControl;
}

@property (nonatomic, retain) UILabel	*minLabel;
@property (nonatomic, retain) UILabel	*maxLabel;
@property (nonatomic, retain) UISlider	*minSlider;
@property (nonatomic, retain) UISlider	*maxSlider;
@property (nonatomic, retain) UISegmentedControl	*operatorControl;

- (IBAction) setMinValue:(id)sender;
- (IBAction) setMaxValue:(id)sender;
- (IBAction) setOperand:(id)sender;

@end
