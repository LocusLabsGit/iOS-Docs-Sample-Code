//
//  LLPOICheckinViewController.h
//  LocusLabsSDK
//
//  Created by Christopher Griffith on 7/19/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLPOICheckinViewController;
@class LLTheme;
@class LLPOI;

@protocol LLPOICheckinViewControllerDelegate <NSObject>

-(void)poiCheckinView:(LLPOICheckinViewController *)poi;
-(void)poiCheckinViewCanceled:(LLPOICheckinViewController *)poi;

@end

@interface LLPOICheckinViewController : UIViewController

@property (weak, nonatomic) id<LLPOICheckinViewControllerDelegate> delegate;
@property (strong, nonatomic) LLTheme *theme;

+ (UINavigationController*)checkinViewControllerWithTheme:(LLTheme *)theme andPOI:(LLPOI *)poi;

@end

@interface LLPOICheckinLoadingView: UIView

@property (nonatomic) IBOutlet UILabel *loadingLabel;
@property (nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) IBOutlet UIView *innerRoundedView;
@property (weak, nonatomic) IBOutlet LLPOICheckinViewController *controller;

@end
