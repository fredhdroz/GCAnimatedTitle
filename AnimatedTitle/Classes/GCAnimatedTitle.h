//
//  GCAnimatedTitle.h
//  GCAnimatedTitle
//
//  Created by Guillaume CASTELLANA on 19/6/14.
//  Copyright (c) 2014 Guillaume CASTELLANA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCAnimatedTitle : UIView

@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIColor *defaultTextColor;
@property (nonatomic, assign) BOOL adjustsFontSizeToFitWidth;

- (void) createLabelsFromTitles:(NSArray*)titles;

- (void) showTitleAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void) scrollTo:(float)progress;

@end
