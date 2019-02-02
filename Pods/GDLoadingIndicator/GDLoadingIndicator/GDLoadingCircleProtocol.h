//
//  GDLoadingCircleProtocol.h
//  GDLoadingIndicator
//
//  Created by Daniil on 22/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#ifndef GDLoadingCircleProtocol_h
#define GDLoadingCircleProtocol_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GDCircleType) {
    GDCircleTypeNone = 1,
    GDCircleTypeProgress,
    GDCircleTypeProgressWithBorder,
    GDCircleTypeInfine,
    GDCircleTypeInfineWithBorder,
    GDCircleTypeBorder
};
static GDCircleType const defaultCircleType = GDCircleTypeInfine;

typedef NS_ENUM(NSUInteger, GDCircleAnimationType) {
    GDCircleAnimationTypeNone = 1,
    GDCircleAnimationTypeJogging,
    GDCircleAnimationTypeRunning
};
static GDCircleAnimationType const defaultCircleAnimationType = GDCircleAnimationTypeJogging;

@protocol GDLoadingCircleProtocol <NSObject>

- (void)setProgress:(CGFloat)progress;
- (void)setCircleAnimationDuration:(CGFloat)circleAnimationDuration;
- (void)setCircleColorsAnimationDuration:(CGFloat)circleColorsAnimationDuration;

- (void)setCircleGap:(CGFloat)circleGap;
- (void)setCircleLineWidth:(CGFloat)circleLineWidth;
- (void)setCircleColor:(UIColor *)circleColor;
- (void)setCircleColoringAnimationWithColors:(NSArray *)circleColors;

@end

#endif /* GDLoadingCircleProtocol_h */
