//
//  GDLoadingCircleLayer.h
//  GDLoadingIndicator
//
//  Created by Daniil on 22/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GDLoadingCircleProtocol.h"

@interface GDLoadingCircleLayer : CAShapeLayer <GDLoadingCircleProtocol>

- (instancetype)initWithCircleType:(GDCircleType)circleType animationType:(GDCircleAnimationType)animationType NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayer:(id)layer __attribute__((unavailable("Must use initWithCircleType:animationType: instead.")));

- (void)animate;
- (void)redraw;

@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat circleAnimationDuration;
@property (nonatomic) CGFloat circleColorsAnimationDuration;

@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGFloat circleGap;
@property (nonatomic) CGFloat circleLineWidth;
@property (nonatomic, strong) UIColor *circleColor;

@end
