//
//  GDLoadingIndicator.h
//  GDLoadingIndicator
//
//  Created by Daniil on 20/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GDLoadingCircleProtocol.h"
#import "GDLoadingFillerProtocol.h"

IB_DESIGNABLE

@interface GDLoadingIndicator : UIView <GDLoadingCircleProtocol, GDLoadingFillerProtocol>

- (instancetype)initWithFrame:(CGRect)frame circleType:(GDCircleType)circleType circleAnimationType:(GDCircleAnimationType)circleAnimationType fillerAnimationType:(GDFillerAnimationType)fillerAnimationType NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (void)setAnimationDuration:(CGFloat)animationDuration;
- (void)setColoringAnimationWithColors:(NSArray *)circleColors;

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSUInteger circleType;
@property (nonatomic) IBInspectable NSUInteger circleAnimationType;
@property (nonatomic) IBInspectable NSUInteger fillerAnimationType;
#endif

@end
