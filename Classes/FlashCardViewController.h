//
//  FlashCardViewController.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/3/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlashCardViewController : UIViewController {
    IBOutlet UILabel	*operand1;
	IBOutlet UILabel	*operand2;
	IBOutlet UILabel	*theOperator;
	IBOutlet UILabel	*result;	
	IBOutlet UIButton	*equalsButton;
	IBOutlet UIButton	*nextEquationButton;
	IBOutlet UIButton	*replayButton;
	IBOutlet UIImageView	*backgroundImage;
	IBOutlet UIButton	*bar;
	BOOL	playEqual;
	BOOL	isShowingLandscapeView;
	NSDate	*startAnimationTime;
	
	UINavigationController *flashCardSettingsNavigationController;
	FlashCardViewController	*landscapeViewController;
}

@property (nonatomic, retain) IBOutlet UILabel *operand1;
@property (nonatomic, retain) IBOutlet UILabel *operand2;
@property (nonatomic, retain) IBOutlet UILabel *theOperator;
@property (nonatomic, retain) IBOutlet UILabel *result;
@property (nonatomic, retain) IBOutlet UIButton *equalsButton;
@property (nonatomic, retain) IBOutlet UIButton *nextEquationButton;
@property (nonatomic, retain) IBOutlet UIButton *replayButton;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIButton	*bar;
@property (nonatomic, retain) IBOutlet UINavigationController *flashCardSettingsNavigationController;
@property (nonatomic, retain) FlashCardViewController *landscapeViewController;
@property (nonatomic, readwrite) BOOL	playEqual;
@property (nonatomic, readwrite) BOOL	isShowingLandscapeView;
@property (nonatomic, retain) NSDate	*startAnimationTime;

- (IBAction) equalClicked:(id)sender;
- (IBAction) newEquationClicked:(id)sender;
- (IBAction) showSettings:(id)sender;
- (void) moveChalkboardToBack;
- (IBAction) replayEquation:(id)sender;
@end
