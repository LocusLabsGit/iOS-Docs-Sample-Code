//
//  LanguageViewController.m
//  LocalizationExample
//
//  Copyright © 2016 LocusLabs. All rights reserved.
//

#import "LanguageViewController.h"
#import "NSBundle+Localization.h"
#import <LocusLabsSDK/LocusLabsSDK.h>

@interface LanguageViewController ()

@end

@implementation LanguageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)languageSelected:(UIButton*)sender
{
	NSString *language = [sender titleForState:UIControlStateNormal];
	[[NSBundle mainBundle] setLanguage:language];
	[self performSegueWithIdentifier:@"MapViewController" sender:sender];
}

@end