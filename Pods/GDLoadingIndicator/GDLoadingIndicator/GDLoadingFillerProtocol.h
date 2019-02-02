//
//  GDLoadingFillerProtocol.h
//  GDLoadingIndicator
//
//  Created by Daniil on 22/04/16.
//  Copyright © 2016 Gavrilov Daniil. All rights reserved.
//

#ifndef GDLoadingFillerProtocol_h
#define GDLoadingFillerProtocol_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GDFillerAnimationType) {
    GDFillerAnimationTypeNone = 1,
    GDFillerAnimationTypeStatic,
    GDFillerAnimationTypeWavesAmplitude,
    GDFillerAnimationTypeWavesForward,
    GDFillerAnimationTypeWavesForwardAmplitude
};
static GDFillerAnimationType const defaultFillerAnimationType = GDFillerAnimationTypeNone;

@protocol GDLoadingFillerProtocol <NSObject>

- (void)setProgress:(CGFloat)progress;
- (void)setFillerAnimationDuration:(CGFloat)fillerAnimationDuration;
- (void)setFillerColorsAnimationDuration:(CGFloat)fillerColorsAnimationDuration;

- (void)setFillerColor:(UIColor *)fillerColor;
- (void)setFillerColoringAnimationWithColors:(NSArray *)fillerColors;

@end

#endif /* GDLoadingFillerProtocol_h */
