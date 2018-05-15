//
//  LLPlace.h
//  LocusLabsSDK
//
//  Created by Christopher Griffith on 12/8/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
	LLPlaceBehaviorSearch,
	LLPlaceBehaviorPOI,
	LLPlaceBehaviorShowPlaces,
} LLPlaceBehavior;

@interface LLPlaceUI: NSObject

@property (nonatomic) NSString *icon;
@property (nonatomic) NSString *selectedIcon;
@property (nonatomic) NSString *marker;
@property (nonatomic) UIColor *normalColor;
@property (nonatomic) UIColor *normalIconColor;
@property (nonatomic) UIColor *selectedColor;
@property (nonatomic) UIColor *selectedIconColor;
@property (nonatomic) CGFloat cornerRadiusPercent;

+ (instancetype)defaultUI;
- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end

@interface LLPlace : NSObject

@property (nonatomic) LLPlaceBehavior behavior;
@property (nonatomic) NSArray<NSString*> *values;
@property (nonatomic) NSString *displayName;
@property (nonatomic) LLPlaceUI *ui;

- (instancetype)initWithBehavior:(LLPlaceBehavior)behavior values:(NSArray<NSString*>*)values displayName:(NSString*)displayName andUI:(LLPlaceUI*)ui;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
+ (instancetype)placeForShowMorePlaces;

@end

@interface LLPlaceConfiguration : NSObject

@property (nonatomic) NSString *morePlacesNormalIcon;
@property (nonatomic) UIColor *morePlacesNormalColor;
@property (nonatomic) UIColor *morePlacesNormalIconColor;
@property (nonatomic) UIColor *morePlacesSelectedColor;
@property (nonatomic) UIColor *morePlacesSelectedIconColor;
@property (nonatomic) NSString *morePlacesCloseButtonIcon;
@property (nonatomic) UIColor *morePlacesCloseButtonColor;
@property (nonatomic) UIColor *morePlacesCloseButtonIconColor;
@property (nonatomic) CGFloat morePlacesCornerRadiusPercent;
@property (nonatomic) NSArray *places;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end
