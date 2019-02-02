//
//  GDLoadingFillerLayer.m
//  GDLoadingIndicator
//
//  Created by Daniil on 22/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#import "GDLoadingFillerLayer.h"

@interface GDLoadingFillerLayer ()

@property (nonatomic) GDFillerAnimationType fillerAnimationType;

@property (nonatomic) CGPoint startPoint;

@property (nonatomic, strong) CAKeyframeAnimation *waveCrestAnimation;
@property (nonatomic, strong) CAShapeLayer *colorFillLayer;

@property (nonatomic, strong) NSArray *fillerColors;

@end

static NSString* const gdFillerTypeAnimationWave =              @"gdFillerTypeAnimationWave";
static NSString* const gdFillerTypeAnimationStrokeColoring =    @"gdFillerTypeAnimationStrokeColoring";
static NSString* const gdFillerTypeAnimationFillColoring =      @"gdFillerTypeAnimationFillColoring";

@implementation GDLoadingFillerLayer

#pragma mark - Init Methods & Superclass Overriders

+ (instancetype)layer {
    return [[GDLoadingFillerLayer alloc] init];
}

- (instancetype)init {
    return [self initWithAnimationType:defaultFillerAnimationType];
}

- (instancetype)initWithAnimationType:(GDFillerAnimationType)animationType {
    self = [super init];
    if (self) {
        self.fillerAnimationType = animationType;
        
        [self defaultSetups];
    }
    return self;
}

- (void)layoutSublayers {
    [super layoutSublayers];
    
    [self.colorFillLayer setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.position = CGPointMake(self.position.x, (CGRectGetHeight(self.frame) - (self.progress * CGRectGetHeight(self.frame))));
}

#pragma mark - Public Methods

- (void)animate {
    [self removeAllAnimations];
    self.path = nil;
    
    if (self.fillerAnimationType != GDFillerAnimationTypeNone) {
        [self addWavesAnimation];
    }
}

- (void)redraw {
    [self animate];
}

- (void)setFillerColoringAnimationWithColors:(NSArray *)fillerColors {
    self.fillerColors = fillerColors;
    
    [self removeColoring];
    [self addColoringAnimationWithColor:fillerColors];
}

#pragma mark - Private Methods

- (void)defaultSetups {
    self.colorFillLayer = [[CAShapeLayer alloc] init];
    self.colorFillLayer.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [self addSublayer:self.colorFillLayer];
    
    self.position = CGPointMake(self.position.x, (CGRectGetHeight(self.frame) - (self.progress * CGRectGetHeight(self.frame))));
}

- (CGPathRef)wavePathWithPoints:(NSArray<NSValue *> *)points amplitude:(CGFloat)amplitude {
    UIBezierPath *line = [UIBezierPath bezierPath];
    
    NSValue *value = [points objectAtIndex:0];
    CGPoint firstPoint = [value CGPointValue];
    CGPoint previousPoint = [value CGPointValue];
    [line moveToPoint:previousPoint];
    
    for (NSInteger i = 1; i < [points count]; i++) {
        NSValue *value = [points objectAtIndex:i];
        CGPoint currentPoint = [value CGPointValue];
        CGPoint controlPoint = CGPointMake(currentPoint.x - (currentPoint.x - previousPoint.x) / 2.0f, currentPoint.y + amplitude);
        
        [line addQuadCurveToPoint:currentPoint controlPoint:controlPoint];
        previousPoint = currentPoint;
        amplitude = -amplitude;
    }
    
    [line addLineToPoint:CGPointMake(CGRectGetWidth(self.frame) + fabs(firstPoint.x), CGRectGetHeight(self.frame) + firstPoint.y)];
    [line addLineToPoint:CGPointMake(-fabs(firstPoint.x), CGRectGetHeight(self.frame) + firstPoint.y)];
    [line closePath];
    
    return line.CGPath;
}

- (CAKeyframeAnimation *)strokeColoringAnimationWithValues:(NSArray *)values {
    CAKeyframeAnimation *coloringAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    coloringAnimation.values = values;
    coloringAnimation.duration = self.fillerColorsAnimationDuration;
    coloringAnimation.calculationMode = kCAAnimationLinear;
    coloringAnimation.repeatCount = HUGE_VAL;
    return coloringAnimation;
}

- (CAKeyframeAnimation *)fillColoringAnimationWithValues:(NSArray *)values {
    CAKeyframeAnimation *coloringAnimation = [CAKeyframeAnimation animationWithKeyPath:@"fillColor"];
    coloringAnimation.values = values;
    coloringAnimation.duration = self.fillerColorsAnimationDuration;
    coloringAnimation.calculationMode = kCAAnimationLinear;
    coloringAnimation.repeatCount = HUGE_VAL;
    return coloringAnimation;
}

- (void)removeColoring {
    if ([self.colorFillLayer animationForKey:gdFillerTypeAnimationStrokeColoring]) {
        [self.colorFillLayer removeAnimationForKey:gdFillerTypeAnimationStrokeColoring];
    }
    
    if ([self.colorFillLayer animationForKey:gdFillerTypeAnimationFillColoring]) {
        [self.colorFillLayer removeAnimationForKey:gdFillerTypeAnimationFillColoring];
    }
}

#pragma mark - Get Bezier Path Values

- (NSArray *)getBezierPathValues {
    NSInteger numberOfWaves = 2;
    CGFloat waveLength = CGRectGetWidth(self.frame) / numberOfWaves;
    CGFloat amplitude = CGRectGetHeight(self.frame) / 20.0f;
    
    NSArray *values = [NSArray new];
    
    if (self.progress == 1.0f) {
        values = [self valuesForStaticAnimation];
    } else {
        switch (self.fillerAnimationType) {
            case GDFillerAnimationTypeStatic: {
                values = [self valuesForStaticAnimation];
            }
                break;
            case GDFillerAnimationTypeWavesAmplitude: {
                values = [self valuesForWavesAplitudeAnimationWithAmplitude:amplitude waveLength:waveLength];
            }
                break;
            case GDFillerAnimationTypeWavesForward: {
                values = [self valuesForWavesFowardAnimationWithAmplitude:amplitude waveLength:waveLength];
            }
                break;
            case GDFillerAnimationTypeWavesForwardAmplitude: {
                values = [self valuesForWavesForwardAplitudeAnimationWithAmplitude:amplitude waveLength:waveLength];
            }
                break;
            default:
                break;
        }
    }
    
    return [NSArray arrayWithArray:values];
}

- (NSArray *)valuesForStaticAnimation {
    UIBezierPath *line = [UIBezierPath bezierPath];
    
    [line moveToPoint:self.startPoint];
    [line addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), self.startPoint.y)];
    [line addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + self.startPoint.y)];
    [line addLineToPoint:CGPointMake(0.0f, CGRectGetHeight(self.frame) + self.startPoint.y)];
    [line closePath];
    
    return @[(id)line.CGPath];
}

- (NSArray *)valuesForWavesAplitudeAnimationWithAmplitude:(CGFloat)amplitude waveLength:(CGFloat)waveLength {
    NSMutableArray *values = [NSMutableArray new];
    NSArray *points;
    points = @[[NSValue valueWithCGPoint:CGPointMake(self.startPoint.x, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength/2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    points = @[[NSValue valueWithCGPoint:CGPointMake(self.startPoint.x, self.startPoint.y + amplitude)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength/2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:-amplitude]];
    
    points = @[[NSValue valueWithCGPoint:CGPointMake(self.startPoint.x, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength/2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    return values;
}

- (NSArray *)valuesForWavesFowardAnimationWithAmplitude:(CGFloat)amplitude waveLength:(CGFloat)waveLength {
    NSMutableArray *values = [NSMutableArray new];
    NSArray *points;
    points = @[[NSValue valueWithCGPoint:CGPointMake(0.0f - waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(0.0f - (waveLength / 2.0f), self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(0.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength / 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    points = @[[NSValue valueWithCGPoint:CGPointMake(0.0f - (waveLength / 2.0f), self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(0.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength / 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.5f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    points = @[[NSValue valueWithCGPoint:CGPointMake(0.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength / 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 4.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    return values;
}

- (NSArray *)valuesForWavesForwardAplitudeAnimationWithAmplitude:(CGFloat)amplitude waveLength:(CGFloat)waveLength {
    NSMutableArray *values = [NSMutableArray new];
    NSArray *points;
    points = @[[NSValue valueWithCGPoint:CGPointMake(0.0f - waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(0.0f - (waveLength / 2.0f), self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(0.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength / 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    points = @[[NSValue valueWithCGPoint:CGPointMake(0.0f - (waveLength / 2.0f), self.startPoint.y + amplitude)],
               [NSValue valueWithCGPoint:CGPointMake(0.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength / 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.5f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:-amplitude]];
    
    points = @[[NSValue valueWithCGPoint:CGPointMake(0.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength / 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 1.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 2.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.0f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 3.5f, self.startPoint.y)],
               [NSValue valueWithCGPoint:CGPointMake(waveLength * 4.0f, self.startPoint.y)]];
    [values addObject:(id)[self wavePathWithPoints:points amplitude:amplitude]];
    
    return values;
}

#pragma mark - Animations

- (void)addWavesAnimation {
    self.startPoint = CGPointMake(0.0f, CGRectGetHeight(self.frame) / 2.0f);
    BOOL isAnimationExist = (self.waveCrestAnimation != nil);
    if (!isAnimationExist) {
        self.waveCrestAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        self.waveCrestAnimation.values = [self getBezierPathValues];
        self.waveCrestAnimation.duration = self.fillerAnimationDuration;
        self.waveCrestAnimation.removedOnCompletion = NO;
        self.waveCrestAnimation.fillMode = kCAFillModeForwards;
    }
    
    if (!isAnimationExist) {
        [self beginAnimationUpdates];
    }
    
    [self updateWavesAnimation];
}

- (void)beginAnimationUpdates {
    __weak GDLoadingFillerLayer *wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.fillerAnimationDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        __strong GDLoadingFillerLayer *sSelf = wSelf;
        if (sSelf && [sSelf progress] < 1.0f) {
            [sSelf updateWavesAnimation];
            [sSelf beginAnimationUpdates];
        }
    });
}

- (void)updateWavesAnimation {
    [self.colorFillLayer removeAnimationForKey:gdFillerTypeAnimationWave];
    self.waveCrestAnimation.values = [self getBezierPathValues];
    [self.colorFillLayer addAnimation:self.waveCrestAnimation forKey:gdFillerTypeAnimationWave];
}

- (void)addColoringAnimationWithColor:(NSArray *)colors {
    NSMutableArray *values = [NSMutableArray new];
    for (id object in colors) {
        if ([object isKindOfClass:[UIColor class]]) {
            [values addObject:(id)[(UIColor *)object CGColor]];
        }
    }
    
    if (self.colorFillLayer) {
        CAKeyframeAnimation *strokeColoringBorderAnimation = [self strokeColoringAnimationWithValues:values];
        [self.colorFillLayer addAnimation:strokeColoringBorderAnimation forKey:gdFillerTypeAnimationStrokeColoring];
        
        CAKeyframeAnimation *fillColoringBorderAnimation = [self fillColoringAnimationWithValues:values];
        [self.colorFillLayer addAnimation:fillColoringBorderAnimation forKey:gdFillerTypeAnimationFillColoring];
    }
}

#pragma mark - Setters & Getters

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    self.position = CGPointMake(self.position.x, (CGRectGetHeight(self.frame) - (progress * CGRectGetHeight(self.frame))));
    
    if (self.progress == 1.0f) {
        [self updateWavesAnimation];
    }
}

- (void)setFillerAnimationDuration:(CGFloat)fillerAnimationDuration {
    _fillerAnimationDuration = fillerAnimationDuration;
    
    if (self.fillerColorsAnimationDuration == 0) {
        self.fillerColorsAnimationDuration = fillerAnimationDuration;
    }
}

- (void)setFillerColor:(UIColor *)fillerColor {
    [self removeColoring];
    
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor clearColor].CGColor;
    
    self.colorFillLayer.fillColor = fillerColor.CGColor;
    self.colorFillLayer.strokeColor = fillerColor.CGColor;
}

- (void)setFillerColorsAnimationDuration:(CGFloat)fillerColorsAnimationDuration {
    _fillerColorsAnimationDuration = fillerColorsAnimationDuration;
    
    [self removeColoring];
    [self addColoringAnimationWithColor:self.fillerColors];
}

@end
