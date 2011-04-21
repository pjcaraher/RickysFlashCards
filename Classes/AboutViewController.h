//
//  AboutViewController.h
//  RickysFlashCards
//
//  Created by Patrick Caraher on 11/5/10.
//  Copyright 2010 Mustang Data Management. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
    IBOutlet    UILabel *versionLabel;
}

@property (nonatomic, retain) UILabel   *versionLabel;

@end
