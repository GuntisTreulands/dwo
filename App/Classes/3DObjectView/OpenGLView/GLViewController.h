//
//  GLViewController.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "OpenGLWaveFrontObject.h"

@class GLView;

@interface GLViewController : UIViewController <UIGestureRecognizerDelegate>
{
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) NSMutableArray *allPartsMutArray;

@property (nonatomic, weak) id<NSObject> delegate;

@property (nonatomic, weak) id<NSObject> glViewDelegate;

- (id)initWithObjectIndex:(NSInteger)mIndex;

- (void)drawView:(GLView*)view;

- (void)setupView:(GLView*)view;

- (void)setOffsetX:(double)mX andY:(double)mY;

- (void)setGLObjectOffsetScale:(NSNumber *)mScale;

- (void)setGLObjectOPannX:(NSNumber *)mX andPannY:(NSNumber *)mY;

- (void)setGLObjectRotation:(NSNumber *)mRotVal;

@end
