//
//  GDLoadingIndicator.m
//  GDLoadingIndicator
//
//  Created by Daniil on 20/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#import "GDLoadingIndicator.h"

#import "GDLoadingCircleLayer.h"
#import "GDLoadingFillerLayer.h"

@interface GDLoadingIndicator ()

@property (nonatomic, strong) CAShapeLayer *cropLayer;
@property (nonatomic, strong) GDLoadingFillerLayer *fillerLayer;
@property (nonatomic, strong) GDLoadingCircleLayer *circleLayer;

@property (nonatomic) IBInspectable NSUInteger circleType;
@property (nonatomic) IBInspectable NSUInteger circleAnimationType;
@property (nonatomic) IBInspectable NSUInteger fillerAnimationType;

@end

@implementation GDLoadingIndicator

#pragma mark - Init Methods & Superclass Overriders

- (instancetype)initWithFrame:(CGRect)frame circleType:(GDCircleType)circleType circleAnimationType:(GDCircleAnimationType)circleAnimationType fillerAnimationType:(GDFillerAnimationType)fillerAnimationType {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayersWithCircleType:circleType circleAnimationType:circleAnimationType fillerAnimationType:fillerAnimationType];
        [self defaultSetups];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame circleType:defaultCircleType circleAnimationType:defaultCircleAnimationType fillerAnimationType:defaultFillerAnimationType];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    
    [self setupLayersWithCircleType:self.circleType circleAnimationType:self.circleAnimationType fillerAnimationType:self.fillerAnimationType];
    [self defaultSetups];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupLayersWithCircleType:self.circleType circleAnimationType:self.circleAnimationType fillerAnimationType:self.fillerAnimationType];
    [self defaultSetups];
    [self animate];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero circleType:defaultCircleType circleAnimationType:defaultCircleAnimationType fillerAnimationType:defaultFillerAnimationType];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self redrawLayers];
}

- (void)didMoveToSuperview {
    [self animate];
}

#pragma mark - Public Methods

- (void)setAnimationDuration:(CGFloat)animationDuration {
    if (animationDuration < 0.0f) {
        animationDuration = 0.0f;
    }
    
    if (self.fillerLayer) {
        [self.fillerLayer setFillerAnimationDuration:animationDuration];
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleAnimationDuration:animationDuration];
    }
}

- (void)setColoringAnimationWithColors:(NSArray *)circleColors {
    if (self.fillerLayer) {
        [self.fillerLayer setFillerColoringAnimationWithColors:circleColors];
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleColoringAnimationWithColors:circleColors];
    }
}

#pragma mark - Private Methods

- (void)defaultSetups {
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setProgress:0.0f];
    [self.fillerLayer setFillerAnimationDuration:2.5f];
    [self.circleLayer setCircleAnimationDuration:4.0f];
    
    [self setCircleGap:0.15f];
    [self setCircleLineWidth:[self circleLineWidth]];
    
    [self setFillerColor:[UIColor colorWithRed:(71.0f/255.0f) green:(175.0f/255.0f) blue:(209.0f/255.0f) alpha:1.0f]];
    [self setCircleColor:[UIColor colorWithRed:(208.0f/255.0f) green:(255.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0f]];
}

- (void)setupLayersWithCircleType:(GDCircleType)circleType circleAnimationType:(GDCircleAnimationType)circleAnimationType fillerAnimationType:(GDFillerAnimationType)fillerAnimationType {
    self.cropLayer = [self cropLayer];
    self.layer.mask = self.cropLayer;
    
    self.fillerLayer = [[GDLoadingFillerLayer alloc] initWithAnimationType:fillerAnimationType];
    [self.layer addSublayer:self.fillerLayer];
    
    self.circleLayer = [[GDLoadingCircleLayer alloc] initWithCircleType:circleType animationType:circleAnimationType];
    [self.circleLayer setCircleRadius:[self circleRadius]];
    [self.layer addSublayer:self.circleLayer];
}

- (void)redrawLayers {
    self.cropLayer = [self cropLayer];
    self.layer.mask = self.cropLayer;
    
    [self.fillerLayer setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [self.circleLayer setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.circleLayer setCircleRadius:[self circleRadius]];
    [self setCircleLineWidth:[self circleLineWidth]];
    
    [self.fillerLayer redraw];
    [self.circleLayer redraw];
}

- (CAShapeLayer *)cropLayer {
    CAShapeLayer *cropLayer = [[CAShapeLayer alloc] init];
    cropLayer.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetHeight(self.frame) / 2.0f) radius:[self circleRadius] startAngle:0.0f endAngle:(M_PI * 2) clockwise:YES].CGPath;
    return cropLayer;
}

- (void)animate {
    [self.fillerLayer animate];
    [self.circleLayer animate];
}

#pragma mark - GDLoadingCircleProtocol & GDLoadingFillerProtocol

- (void)setProgress:(CGFloat)progress {
    if (progress < 0.0f) {
        progress = 0.0f;
    } else if (progress > 1.0f) {
        progress = 1.0f;
    }
    
    if (self.fillerLayer) {
        [self.fillerLayer setProgress:progress];
    }
    
    if (self.circleLayer) {
        [self.circleLayer setProgress:progress];
    }
}

#pragma mark - GDLoadingCircleProtocol

- (void)setCircleGap:(CGFloat)circleGap {
    if (circleGap < 0.0f) {
        circleGap = 0.0f;
    } else if (circleGap > 1.0f) {
        circleGap = 1.0f;
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleGap:circleGap];
    }
}

- (void)setCircleLineWidth:(CGFloat)circleLineWidth {
    if (circleLineWidth <= 0.0f) {
        circleLineWidth = ceil([self circleRadius] / 10.0f);
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleLineWidth:circleLineWidth];
    }
}

- (void)setCircleColor:(UIColor *)circleColor {
    if (!circleColor) {
        return;
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleColor:circleColor];
    }
}

- (void)setCircleAnimationDuration:(CGFloat)circleAnimationDuration {
    if (circleAnimationDuration < 0.0f) {
        circleAnimationDuration = 0.0f;
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleAnimationDuration:circleAnimationDuration];
    }
}

- (void)setCircleColoringAnimationWithColors:(NSArray *)circleColors {
    if (self.circleLayer) {
        [self.circleLayer setCircleColoringAnimationWithColors:circleColors];
    }
}

- (void)setCircleColorsAnimationDuration:(CGFloat)circleColorsAnimationDuration {
    if (circleColorsAnimationDuration < 0.0f) {
        circleColorsAnimationDuration = 0.0f;
    }
    
    if (self.circleLayer) {
        [self.circleLayer setCircleColorsAnimationDuration:circleColorsAnimationDuration];
    }
}

#pragma mark - GDLoadingFillerProtocol

- (void)setFillerColor:(UIColor *)fillerColor {
    if (!fillerColor) {
        return;
    }
    
    if (self.fillerLayer) {
        [self.fillerLayer setFillerColor:fillerColor];
    }
}

- (CGFloat)circleRadius {
    return ceil(MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame)) / 2.0f);
}

- (CGFloat)circleLineWidth {
    if (self.circleLayer.circleLineWidth <= 0.0f) {
        return ceil([self circleRadius] / 6.0f);
    } else {
        return self.circleLayer.circleLineWidth;
    }
}

- (void)setFillerAnimationDuration:(CGFloat)fillerAnimationDuration {
    if (fillerAnimationDuration < 0.0f) {
        fillerAnimationDuration = 0.0f;
    }
    
    if (self.fillerLayer) {
        [self.fillerLayer setFillerAnimationDuration:fillerAnimationDuration];
    }
}

- (void)setFillerColoringAnimationWithColors:(NSArray *)fillerColors {
    if (self.fillerLayer) {
        [self.fillerLayer setFillerColoringAnimationWithColors:fillerColors];
    }
}

- (void)setFillerColorsAnimationDuration:(CGFloat)circleFillerAnimationDuration {
    if (circleFillerAnimationDuration < 0.0f) {
        circleFillerAnimationDuration = 0.0f;
    }
    
    if (self.fillerLayer) {
        [self.fillerLayer setFillerColorsAnimationDuration:circleFillerAnimationDuration];
    }
}

#pragma mark - Setters & Getters

- (NSUInteger)circleType {
    if (_circleType < GDCircleTypeNone || _circleType > GDCircleTypeBorder) {
        _circleType = defaultCircleType;
    }
    return _circleType;
}

- (NSUInteger)circleAnimationType {
    if (_circleAnimationType < GDCircleAnimationTypeNone || _circleAnimationType > GDCircleAnimationTypeRunning) {
        _circleAnimationType = defaultCircleAnimationType;
    }
    return _circleAnimationType;
}

- (NSUInteger)fillerAnimationType {
    if (_fillerAnimationType < GDFillerAnimationTypeNone || _fillerAnimationType > GDFillerAnimationTypeWavesForwardAmplitude) {
        _fillerAnimationType = defaultFillerAnimationType;
    }
    return _fillerAnimationType;
}

@end
