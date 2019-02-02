//
//  GDLoadingFillerLayer.h
//  GDLoadingIndicator
//
//  Created by Daniil on 22/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GDLoadingFillerProtocol.h"

@interface GDLoadingFillerLayer : CAShapeLayer <GDLoadingFillerProtocol>

- (instancetype)initWithAnimationType:(GDFillerAnimationType)animationType NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayer:(id)layer __attribute__((unavailable("Must use initWithAnimationType: instead.")));

- (void)animate;
- (void)redraw;

@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat fillerAnimationDuration;
@property (nonatomic) CGFloat fillerColorsAnimationDuration;

@property (nonatomic, strong) UIColor *fillerColor;

@end
