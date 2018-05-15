//
//  LLNavigation.h
//  LocusLabsSDK
//
//  Created by Ana Grande on 10/18/17.
//  Copyright © 2017 LocusLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPosition.h"

@protocol LLNavigationDelegate <NSObject>

-(void)navigationStarted:(LLPosition*)startPoint endPoint:(LLPosition*)endPoint;

@end

@interface LLNavigation : NSObject
{
}
@property (nonatomic, assign) id  <LLNavigationDelegate>delegate;

+ (id)initTracking;

@end
