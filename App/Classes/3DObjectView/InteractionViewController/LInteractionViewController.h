//
//  LInteractionViewController.h
//  vatp3d
//
//  Created by Guntis Treulands on 6/11/13.
//  Copyright (c) 2013 Guntis Treulands. All rights reserved.
//

#import "GLViewController.h"

#import "GLView.h"


@interface LInteractionViewController : UIViewController <UIScrollViewDelegate,
    UIGestureRecognizerDelegate, UIGestureRecognizerDelegate>
{
    NSTimer *_objectAutoRotateTimer;
    
    float _lastScale;
    
    float _totalScale;
    
    float _totalRotation;
    
    float _lastRotation;
    
	CGFloat _firstPanPointX;
    
	CGFloat _firstPanPointY;
    
    UIView *_scalableView;
    
    UIView *_rotatableView;
    
    UIScrollView *_scrollView;
    
    UITapGestureRecognizer *_tapRecognizer;
    
    UIPinchGestureRecognizer *_pinchRecognizer;
    
    UIPanGestureRecognizer *_panRecognizer;
    
    UIRotationGestureRecognizer *_rotateRecognizer;
    
    UIButton *_backButton;
    
    UIButton *_rotateButton;
    
    GLViewController *_glViewController;
    
    GLView *_glView;
    
    BOOL _scrollViewIsNotScrolling;
    
    UIView *_touchRecognizeView;
    
    NSInteger _selectedObjectIndex;
}


- (id)initWithObjectIndex:(NSInteger)mIndex;

- (void)navigateBack;

@end
