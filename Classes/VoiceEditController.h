//
//  VoiceEditController.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/8/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface VoiceEditController : UITableViewController <UITextFieldDelegate,UIAlertViewDelegate,AVAudioRecorderDelegate,NSFetchedResultsControllerDelegate> {
	NSManagedObject	*voice;
	IBOutlet UIView	*editNameView;
	IBOutlet UILabel *errorMessage;
	IBOutlet UITextField	*voiceNameText;
	IBOutlet UIButton	*recordButton;
	IBOutlet UIBarButtonItem	*rightBarButton;
	NSFetchedResultsController *fetchedTemplatesResultsController;
	AVAudioRecorder *recorder;
	NSNumber	*duration;
}

@property (nonatomic, assign) NSManagedObject	*voice;
@property (nonatomic, assign) UIView	*editNameView;
@property (nonatomic, assign) UILabel	*errorMessage;
@property (nonatomic, assign) UITextField	*voiceNameText;
@property (nonatomic, assign) UIButton	*recordButton;
@property (nonatomic, assign) UIBarButtonItem	*rightBarButton;
@property (nonatomic, readonly) AVAudioRecorder	*recorder;
@property (nonatomic, assign) NSNumber	*duration;

@property (nonatomic, retain) NSFetchedResultsController *fetchedTemplatesResultsController;

- (IBAction) editNameButtonPressed:(id)sender;
- (IBAction) playButtonPressed:(id)sender event:(id)event;
- (IBAction) recordButtonPressed:(id)sender event:(id)event;
- (IBAction) saveNameUpdate:(id)sender;

@end
