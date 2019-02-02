//
//  GDLoadingCircleLayer.m
//  GDLoadingIndicator
//
//  Created by Daniil on 22/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#import "GDLoadingCircleLayer.h"

@interface GDLoadingCircleLayer ()

@property (nonatomic) GDCircleType circleType;
@property (nonatomic) GDCircleAnimationType circleAnimationType;

@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAGradientLayer *gradientBorderLayer;

@property (nonatomic, strong) NSArray *circleColors;

@end

static NSString* const gdCircleTypeAnimationRotation =      @"gdCircleTypeAnimationRotation";
static NSString* const gdCircleTypeAnimationJoggingGroup =  @"gdCircleTypeAnimationJoggingGroup";
static NSString* const gdCircleTypeAnimationRotationGroup = @"gdCircleTypeAnimationRotationGroup";
static NSString* const gdCircleTypeAnimationColoring =      @"gdCircleTypeAnimationColoring";

@implementation GDLoadingCircleLayer

#pragma mark - Init Methods & Superclass Overriders

+ (instancetype)layer {
    return [[GDLoadingCircleLayer alloc] init];
}

- (instancetype)init {
    return [self initWithCircleType:defaultCircleType animationType:defaultCircleAnimationType];
}

- (instancetype)initWithCircleType:(GDCircleType)circleType animationType:(GDCircleAnimationType)animationType {
    self = [super init];
    if (self) {
        self.circleType = circleType;
        self.circleAnimationType = animationType;
        
        [self defaultSetups];
        [self drawCircle];
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    
    [self.borderLayer setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.gradientLayer setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
}

#pragma mark - Public Methods

- (void)animate {
    switch (self.circleAnimationType) {
        case GDCircleAnimationTypeNone: {
            [self removeAllAnimations];
        }
            break;
        case GDCircleAnimationTypeJogging: {
            [self removeAllAnimations];
            if ([self isProgressAnimation]) {
                [self addRunningAnimation];
            } else {
                [self addJoggingAnimation];
            }
        }
            break;
        case GDCircleAnimationTypeRunning: {
            [self removeAllAnimations];
            [self addRunningAnimation];
        }
            break;
    }
}

- (void)redraw {
    [self drawCircle];
}

- (void)setCircleColoringAnimationWithColors:(NSArray *)circleColors {
    self.circleColors = circleColors;
    
    [self removeColoring];
    [self addColoringAnimationWithColor:circleColors];
}

#pragma mark - Private Methods

- (void)defaultSetups {
    self.lineCap = kCALineCapRound;
    self.lineJoin = kCALineJoinRound;
}

- (void)drawCircle {
    switch (self.circleType) {
        case GDCircleTypeNone: {
            [self removeBorderLayerIfNeeded];
            self.path = nil;
        }
            break;
        case GDCircleTypeInfine: {
            [self removeBorderLayerIfNeeded];
            self.path = [self circlePathWithLineWidth:self.lineWidth];
        }
            break;
        case GDCircleTypeInfineWithBorder: {
            [self addBorderLayerIfNeeded];
            self.borderLayer.path = [self borderPathWithLineWidth:self.borderLayer.lineWidth];
            self.path = [self circlePathWithBorderAndWithLineWidth:self.lineWidth];
        }
            break;
        case GDCircleTypeProgress: {
            [self removeBorderLayerIfNeeded];
            self.path = [self circlePathWithLineWidth:self.lineWidth];
        }
            break;
        case GDCircleTypeProgressWithBorder: {
            [self addBorderLayerIfNeeded];
            self.borderLayer.path = [self borderPathWithLineWidth:self.borderLayer.lineWidth];
            self.path = [self circlePathWithBorderAndWithLineWidth:self.lineWidth];
        }
            break;
        case GDCircleTypeBorder: {
            [self addBorderLayerIfNeeded];
            self.borderLayer.path = [self borderPathWithLineWidth:self.borderLayer.lineWidth];
            self.path = nil;
        }
            break;
        default:
            break;
    }
}

- (void)removeBorderLayerIfNeeded {
    if (!self.borderLayer) {
        return;
    }
    
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
}

- (void)addBorderLayerIfNeeded {
    if (!self.borderLayer) {
        self.borderLayer = [[CAShapeLayer alloc] init];
    }
    
    self.borderLayer.fillColor = self.fillColor;
    self.borderLayer.strokeColor = self.strokeColor;
    self.borderLayer.lineWidth = self.lineWidth;
    self.borderLayer.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    [self addSublayer:self.borderLayer];
}

- (void)applyLineWidth {
    if (![self isProgressAnimation]) {
        self.lineWidth = self.circleLineWidth;
        
        if (self.borderLayer) {
            self.borderLayer.lineWidth = self.circleLineWidth;
        }
    } else {
        self.lineWidth = self.circleLineWidth / 2.0f;
        
        if (self.borderLayer) {
            self.borderLayer.lineWidth = self.circleLineWidth / 2.0f;
        }
    }
}

- (BOOL)isProgressAnimation {
    return (self.circleType == GDCircleTypeProgress || self.circleType == GDCircleTypeProgressWithBorder);
}

- (void)removeColoring {
    if ([self animationForKey:gdCircleTypeAnimationColoring]) {
        [self removeAnimationForKey:gdCircleTypeAnimationColoring];
    }
    
    if ([self.borderLayer animationForKey:gdCircleTypeAnimationColoring]) {
        [self.borderLayer removeAnimationForKey:gdCircleTypeAnimationColoring];
    }
    
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
    
    if (self.gradientBorderLayer) {
        [self.gradientBorderLayer removeFromSuperlayer];
        self.gradientBorderLayer = nil;
    }
}

- (CAKeyframeAnimation *)coloringAnimationWithValues:(NSArray *)values {
    CAKeyframeAnimation *coloringAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    coloringAnimation.values = values;
    coloringAnimation.duration = self.circleColorsAnimationDuration;
    coloringAnimation.calculationMode = kCAAnimationLinear;
    coloringAnimation.repeatCount = HUGE_VAL;
    return coloringAnimation;
}

#pragma mark - Create Path

- (CGPathRef)circlePathWithLineWidth:(CGFloat)lineWidth {
    CGFloat radius = ceil(self.circleRadius - lineWidth / 2.0f);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f) radius:radius startAngle:(0.0f - M_PI_2) endAngle:(M_PI_2 * 3) clockwise:YES];
    circlePath.lineWidth = lineWidth;
    return circlePath.CGPath;
}

- (CGPathRef)circlePathWithBorderAndWithLineWidth:(CGFloat)lineWidth {
    CGFloat radius = ceil(self.circleRadius - lineWidth * 1.4f);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f) radius:radius startAngle:(0.0f - M_PI_2) endAngle:(M_PI_2 * 3) clockwise:YES];
    circlePath.lineWidth = lineWidth;
    return circlePath.CGPath;
}

- (CGPathRef)borderPathWithLineWidth:(CGFloat)lineWidth {
    CGFloat radius = ceil(self.circleRadius - lineWidth / 2.0f);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f) radius:radius startAngle:(0.0f - M_PI_2) endAngle:(M_PI_2 * 3) clockwise:YES];
    borderPath.lineWidth = lineWidth;
    return borderPath.CGPath;
}

#pragma mark - Animations

- (void)addRunningAnimation {
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 2.0f];
    rotationAnimation.duration = self.circleAnimationDuration;
    rotationAnimation.repeatCount = HUGE_VAL;
    [self addAnimation:rotationAnimation forKey:gdCircleTypeAnimationRotation];
}

- (void)addJoggingAnimation {
    CGFloat strokeEnd = 1.0f - self.circleGap;
    
    CABasicAnimation *strokeEndToStart;
    strokeEndToStart = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndToStart.fromValue = @(strokeEnd);
    strokeEndToStart.toValue = @(self.circleGap);
    strokeEndToStart.duration = self.circleAnimationDuration;
    strokeEndToStart.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *strokeEndToEnd;
    strokeEndToEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndToEnd.beginTime = self.circleAnimationDuration;
    strokeEndToEnd.fromValue = @(self.circleGap);
    strokeEndToEnd.toValue = @(strokeEnd);
    strokeEndToEnd.duration = self.circleAnimationDuration;
    strokeEndToEnd.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *slowRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    slowRotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI * 2.0f * 3.0f)];
    slowRotationAnimation.duration = self.circleAnimationDuration;
    
    CABasicAnimation *fastRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fastRotationAnimation.beginTime = self.circleAnimationDuration;
    fastRotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI * 2.0f * 2.0f)];
    fastRotationAnimation.duration = self.circleAnimationDuration;
    
    CAAnimationGroup *joggingAnimationGroup = [[CAAnimationGroup alloc] init];
    joggingAnimationGroup.animations = @[strokeEndToStart, strokeEndToEnd];
    joggingAnimationGroup.duration = self.circleAnimationDuration * 2;
    joggingAnimationGroup.repeatCount = HUGE_VAL;
    [self addAnimation:joggingAnimationGroup forKey:gdCircleTypeAnimationJoggingGroup];
    
    CAAnimationGroup *rotationAnimationGroup = [[CAAnimationGroup alloc] init];
    rotationAnimationGroup.animations = @[slowRotationAnimation, fastRotationAnimation];
    rotationAnimationGroup.duration = self.circleAnimationDuration * 2;
    rotationAnimationGroup.repeatCount = HUGE_VAL;
    [self addAnimation:rotationAnimationGroup forKey:gdCircleTypeAnimationRotationGroup];
}

- (void)addColoringAnimationWithColor:(NSArray *)colors {
    NSMutableArray *values = [NSMutableArray new];
    for (id object in colors) {
        if ([object isKindOfClass:[UIColor class]]) {
            [values addObject:(id)[(UIColor *)object CGColor]];
        }
    }
    
    CAKeyframeAnimation *coloringAnimation = [self coloringAnimationWithValues:values];
    [self addAnimation:coloringAnimation forKey:gdCircleTypeAnimationColoring];
    
    if (self.borderLayer) {
        CAKeyframeAnimation *coloringBorderAnimation = [self coloringAnimationWithValues:values];
        [self.borderLayer addAnimation:coloringBorderAnimation forKey:gdCircleTypeAnimationColoring];
    }
}

#pragma mark - Setters & Getters

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    if ([self isProgressAnimation]) {
        self.strokeEnd = progress;
    }
}

- (void)setCircleAnimationDuration:(CGFloat)circleAnimationDuration {
    _circleAnimationDuration = circleAnimationDuration;
    
    if (self.circleColorsAnimationDuration == 0) {
        self.circleColorsAnimationDuration = circleAnimationDuration;
    }
    
    [self drawCircle];
}

- (void)setCircleRadius:(CGFloat)circleRadius {
    _circleRadius = circleRadius;
    
    [self drawCircle];
}

- (void)setCircleGap:(CGFloat)circleGap {
    _circleGap = circleGap;
    
    if (![self isProgressAnimation]) {
        self.strokeEnd = 1.0f - circleGap;
    }
}

- (void)setCircleLineWidth:(CGFloat)circleLineWidth {
    _circleLineWidth = circleLineWidth;
    
    [self applyLineWidth];
    [self drawCircle];
}

- (void)setCircleColor:(UIColor *)circleColor {
    [self removeColoring];
    
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = circleColor.CGColor;
    
    if (self.borderLayer) {
        self.borderLayer.fillColor = self.fillColor;
        self.borderLayer.strokeColor = self.strokeColor;
    }
}

- (void)setCircleColorsAnimationDuration:(CGFloat)circleColorsAnimationDuration {
    _circleColorsAnimationDuration = circleColorsAnimationDuration;
    
    [self removeColoring];
    [self addColoringAnimationWithColor:self.circleColors];
}

@end
