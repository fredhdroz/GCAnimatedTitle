//
//  GCAnimatedTitle.m
//  GCAnimatedTitle
//
//  Created by Guillaume CASTELLANA on 19/6/14.
//  Copyright (c) 2014 Guillaume CASTELLANA. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GCAnimatedTitle.h"

@interface GCAnimatedTitle () <UIScrollViewDelegate>

@property (nonatomic, retain) NSArray* titles;
@property (nonatomic, retain) NSArray* labels;
@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, retain) CAGradientLayer* maskLayer;

@end

@implementation GCAnimatedTitle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Initialization

- (void) setup
{
    UIScrollView* aScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    aScrollView.delegate = self;
	
    self.labels = [self addLabelsToScrollView:aScrollView];
	
    self.scrollView = aScrollView;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    [self addSubview:aScrollView];
    
	self.defaultFont = [UIFont boldSystemFontOfSize:18];
	self.defaultTextColor = [UIColor whiteColor];
	
    [self createOpacityLayer];
}

- (void) createOpacityLayer
{
    self.maskLayer = [CAGradientLayer new];
    
    CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
    CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    
    self.maskLayer.colors = [NSArray arrayWithObjects:(__bridge id)outerColor,
                             (__bridge id)outerColor,
                             (__bridge id)innerColor,
                             (__bridge id)innerColor,
                             (__bridge id)outerColor, nil];
    self.maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.05],
                                [NSNumber numberWithFloat:0.1],
                                [NSNumber numberWithFloat:0.9],
                                [NSNumber numberWithFloat:1.0], nil];
    
    [self.maskLayer setStartPoint:CGPointMake(0, 0.5)];
    [self.maskLayer setEndPoint:CGPointMake(1, 0.5)];
    
    self.maskLayer.bounds = self.bounds;
    self.maskLayer.anchorPoint = CGPointZero;
    
    self.layer.mask = self.maskLayer;
}

- (NSArray*) addLabelsToScrollView:(UIScrollView*)aScrollView
{
    NSMutableArray* labels = [NSMutableArray new];
	
    if (self.titles.count == 0)
	{
        aScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
	else
	{
        float frameWidth = CGRectGetWidth(self.frame);
        float frameHeight = CGRectGetHeight(self.frame);
        
        for (int i = 0; i < self.titles.count; ++i)
		{
			id title = self.titles[i];
			
            UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];
            [label setTextAlignment:NSTextAlignmentCenter];
			label.font = self.defaultFont;
            label.textColor = self.defaultTextColor;
			
			if ([title isKindOfClass:[NSAttributedString class]]) {
				label.attributedText = title;
			}else{
				label.text = [title description];
			}
			
			if (self.adjustsFontSizeToFitWidth) {
				label.minimumFontSize = self.defaultFont.pointSize - 5.0f;
				label.adjustsFontSizeToFitWidth = YES;
			}else{
				[label sizeToFit];
			}
			
            // If it's the first label
            if (i == 0) {
                label.frame = CGRectMake((frameWidth - CGRectGetWidth(label.frame)) / 2, (frameHeight - CGRectGetHeight(label.frame)) / 2, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
            }
            else
			{
                UILabel* previousLabel = labels[i - 1];
				
                float labelXPos = (frameWidth + CGRectGetWidth(previousLabel.frame)) / 2 + CGRectGetMinX(previousLabel.frame);
                label.frame = CGRectMake(labelXPos, (frameHeight - CGRectGetHeight(label.frame)) / 2, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
            }
			
            [labels addObject:label];
			
            [aScrollView addSubview:label];
        }
		
        UILabel* lastLabel = [labels lastObject];
        aScrollView.contentSize = CGSizeMake(lastLabel.frame.origin.x + (CGRectGetWidth(lastLabel.frame) + frameWidth) / 2, CGRectGetHeight(self.frame));
    }
    
    return labels;
}

- (void) removeLabelsFromScrollView:(UIScrollView*)aScrollView
{
    for (UILabel* label in self.labels)
	{
        [label removeFromSuperview];
    }
    self.labels = Nil;
}

- (void) updateLabelsOpacityForOffset:(float)xOffset
{
    float frameSize = self.frame.size.width;
    
    // Change label opacity according to scroll
    for (int i = 0; i < self.labels.count; ++i)
	{
        UILabel* label = self.labels[i];
        
        // Compute label opacity range
        CGFloat opacity = 0.f;
        float minOffset = -label.frame.size.width;
        float maxOffset = frameSize;
        
        CGPoint relativePos = [self convertPoint:label.bounds.origin fromView:label];
        float progress = (relativePos.x - minOffset) / fabsf(maxOffset - minOffset);
        
        if (relativePos.x > minOffset && relativePos.x < maxOffset) {
            opacity = cosf((progress + .5f) * 2 * M_PI) / 1.2f + 0.5f;
        } else {
            opacity = 0.f;
        }
        
        [label setAlpha:opacity];
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateLabelsOpacityForOffset:scrollView.contentOffset.x];
}


#pragma mark - Public Interfaces

- (void) createLabelsFromTitles:(NSArray *)titles
{
    self.titles = titles;
    if (self.labels.count) {
        [self removeLabelsFromScrollView:self.scrollView];
    }
    self.labels = [self addLabelsToScrollView:self.scrollView];
}

- (void) showTitleAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	CGFloat progress = 0.0;
	if (self.labels.count > 0)
		progress = (CGFloat)index / (CGFloat)self.labels.count;
	
	CGFloat newScrollPos = progress * self.scrollView.contentSize.width;
	[self.scrollView setContentOffset:CGPointMake(newScrollPos, 0) animated:animated];
}

- (void) scrollTo:(float)progress
{
    CGFloat newScrollPos = [self scrollPositionForProgress:progress];
    self.scrollView.contentOffset = CGPointMake(newScrollPos, 0);
}

- (CGFloat) scrollPositionForProgress : (CGFloat)progress
{
	if (self.labels.count == 0 || self.labels.count == 1)
        return 0.0f;
    
    float step = 1 / ((float)self.labels.count - 1);
    int n = floor(progress / step);
    if (n < 0) {
        n = 0;
    } else if (n >= self.labels.count) {
        n = (int)self.labels.count - 1;
    }
    
    float start = 0.0f;
    float end = 0.0f;
    
    UILabel* firstLabel = self.labels[n];
    start = firstLabel.frame.origin.x + (firstLabel.frame.size.width / 2) - self.frame.size.width / 2;
    
    if (n == self.labels.count - 1) {
        end = start + self.frame.size.width / 2;
    } else {
        UILabel* secondLabel = self.labels[n + 1];
        end = secondLabel.frame.origin.x + (secondLabel.frame.size.width / 2) - self.frame.size.width / 2;
    }
    
    float nStart = n * step;
    float nEnd = (n + 1) * step;
    float newProgress = (progress - nStart) / (nEnd - nStart);
    float newScrollPos = interpolate(start, end, newProgress);
	
	return newScrollPos;
}

#pragma mark - C Helper

float interpolate(float min, float max, float t)
{
    return min + (max - min) * t;
}

@end
