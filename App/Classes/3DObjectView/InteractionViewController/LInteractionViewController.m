//
//  LInteractionViewController.m
//  vatp3d
//
//  Created by Guntis Treulands on 6/11/13.
//  Copyright (c) 2013 Guntis Treulands. All rights reserved.
//

#import "LInteractionViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"


@implementation LInteractionViewController

#pragma mark - init

- (id)initWithObjectIndex:(NSInteger)mIndex
{
    self = [super init];
    
    if (self)
    {
        _selectedObjectIndex = mIndex;
    }
    
    return self;
}

#pragma mark - dealloc

- (void)dealloc
{
    [_glView stopAnimation];
    
    DLog();
}

#pragma mark - view appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // OpenGL view
    [self setUpGLView];
    
    
    // Scroll view with gesture recognizers (also pinch and pan recognizers)
    [self setUpScrollViewAndItsGestureRecognizers];
    

    // Rotatable view - for pinch zooming object
    [self setUpRotatableView];
    
    // Scalable view - for pinch zooming object
    [self setUpScalableView];
    
     // Touch recognize view - for touch recognition
    [self setUpTouchRecognizeView];
    
    
    // Back button
    [self setUpBackButton];
    
    
    // Rotate button
    [self setUpRotateButton];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    DLog();
    
    [UIViewController attemptRotationToDeviceOrientation];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
}

#pragma mark - init elements

- (void)setUpGLView
{
    //--- gl view controller
    _glViewController = [[GLViewController alloc] initWithObjectIndex:_selectedObjectIndex];
    
    [[_glViewController view] setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];

    [_glViewController setDelegate:self];
    //===

    
    //--- gl view
    _glView = [[GLView alloc] initWithFrame:self.view.bounds];
	
    [_glView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    
	[_glView setController:_glViewController];
	
    [_glView setAnimationInterval:(1.0 / 60)];
    
	[_glView startAnimation];
    
    [_glViewController setGlViewDelegate:_glView];
    
    [[self view] addSubview:_glView];
    //===
}


- (void)setUpScrollViewAndItsGestureRecognizers
{
    //--- scroll view
    _scrollView = [UIScrollView new];
    
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    
    [_scrollView setAlpha:0.5];
    
    [_scrollView setDelegate:self];
    
    [_scrollView setContentSize:CGSizeMake(10000,10000)];
    
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    
    [_scrollView setContentOffset:CGPointMake(5000-950,5000-1400)];
    
    [_scrollView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    [_scrollView setFrame:self.view.bounds];
    //===
    
    
    //--- gesture recognizers
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    
	[_pinchRecognizer setDelegate:self];
    
	[_scrollView addGestureRecognizer:_pinchRecognizer];
    
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    
	[_panRecognizer setMinimumNumberOfTouches:2];
    
	[_panRecognizer setMaximumNumberOfTouches:2];
    
	[_panRecognizer setDelegate:self];
    
	[_scrollView addGestureRecognizer:_panRecognizer];
    
    
    _rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotated:)];
    
    [_rotateRecognizer setDelegate:self];
    
    [_scrollView addGestureRecognizer:_rotateRecognizer];
    //===
}


- (void)setUpRotatableView
{
    // Although gesture recongisers are added to scrollview - this view will be used for rotating.
    _rotatableView = [UIView new];
    
    [_rotatableView setFrame:CGRectMake(-1000,-1000,2000,2000)];
    
    [[self view] addSubview:_rotatableView];
}


- (void)setUpScalableView
{
    // Although gesture recongisers are added to scrollview - this view will be used for panning and pinching.
    _scalableView = [UIView new];
    
    [_scalableView setFrame:CGRectMake(-1000,-1000,2000,2000)];
    
    [[self view] addSubview:_scalableView];
    
    _totalScale = 1;
}


- (void)setUpBackButton
{
    // Back button
    _backButton = [UIButton new];
    
    [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_backButton setFrame:CGRectMake(5, 5, 50, 35)];
    
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    
    [_backButton addTarget:self action:@selector(navigateBack) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:_backButton];
}


- (void)setUpRotateButton
{
    _rotateButton = [UIButton new];
    
    [_rotateButton setFrame:CGRectMake(5, self.view.frame.size.height-40, 35, 35)];
    
    [_rotateButton setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    [_rotateButton setAdjustsImageWhenHighlighted:NO];
    
    [_rotateButton setImage:[UIImage imageNamed:@"auto_rotate1"] forState:UIControlStateNormal];
    
    [_rotateButton setImage:[UIImage imageNamed:@"auto_rotate1_s"] forState:UIControlStateSelected];
    
    [_rotateButton setImage:[UIImage imageNamed:@"auto_rotate1_h"] forState:UIControlStateHighlighted];
    
    [_rotateButton addTarget:self action:@selector(toggleAutoRotate) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:_rotateButton];
}


- (void)setUpTouchRecognizeView
{
    // Touch recognize view
    _touchRecognizeView = [UIView new];
    
    [_touchRecognizeView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    
    [_touchRecognizeView setBackgroundColor:[UIColor clearColor]];
    
    [_touchRecognizeView setFrame:self.view.bounds];
    
    [[self view] addSubview:_touchRecognizeView];
    
    
    // Finally add scrollview as subview to touch recognize view. This is necessary
    [_touchRecognizeView addSubview:_scrollView];
}

#pragma mark - functions

- (void)turnOffAutorotateIfNecessary
{
    if(_objectAutoRotateTimer)
    {
        [self toggleAutoRotate];
    }
}


- (void)toggleAutoRotate
{
    [_rotateButton setSelected:!_rotateButton.selected];

    [_objectAutoRotateTimer invalidate], _objectAutoRotateTimer = nil;

    if(_rotateButton.selected)
    {
        _objectAutoRotateTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self
            selector:@selector(autorotateTimerJustTicked) userInfo:nil repeats:YES];
    }
    else
    {
        [_objectAutoRotateTimer invalidate], _objectAutoRotateTimer = nil;
    }
}


- (void)autorotateTimerJustTicked
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x+3,_scrollView.contentOffset.y)];
}


- (void)navigateBack
{
    [_objectAutoRotateTimer invalidate], _objectAutoRotateTimer = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - scroll view gesture stuff

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Stop autoscrolling
    [self turnOffAutorotateIfNecessary];
}


- (void)scrollViewDidEndScrolling
{
    _scrollViewIsNotScrolling = YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    DLog();
    
    //--- we set after delay as not scrolling, to be sure it really variable holds correct value. necessary for assemble/dissasemble anims.
    _scrollViewIsNotScrolling = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidEndScrolling) object:nil];
    
    [self performSelector:@selector(scrollViewDidEndScrolling) withObject:nil afterDelay:0.5];
    //===
    
  
    //--- reset back scrollview to default pos - so that it would look like infinite.
    if(scrollView.contentOffset.x >=5000+359*5)
    {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x-359*5, scrollView.contentOffset.y)];
    }
    
    if(scrollView.contentOffset.y >=5000+359*5)
    {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y-359*5)];
    }
    
    if(scrollView.contentOffset.x <= 5000-359*5)
    {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x+359*5, scrollView.contentOffset.y)];
    }
    
    if(scrollView.contentOffset.y <= 5000-359*5)
    {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y+359*5)];
    }
    //===
    
    [_glViewController setOffsetX:scrollView.contentOffset.x/5 andY:scrollView.contentOffset.y/5];
    
    [_glView drawView];
}


#pragma mark - pinch gestures 

- (void)rotated:(id)sender
{
    // Stop autoscrolling
    [self turnOffAutorotateIfNecessary];
    
    
    // Remove - so that delegate methods would not be called
    [_scrollView setDelegate:nil];
    
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        [_scrollView setDelegate:self];
        
        _lastRotation = 0.0;
      
        return;
    }

    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);

    CGAffineTransform currentTransform = _rotatableView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, rotation);

    [_rotatableView setTransform:newTransform];

    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    
    [_glViewController setGLObjectRotation:[NSNumber numberWithFloat:rotation]];
}


- (void)scale:(id)sender
{
    // Stop autoscrolling
    [self turnOffAutorotateIfNecessary];
    
    
    // Remove - so that delegate methods would not be called
    [_scrollView setDelegate:nil];
    
    
	if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        _totalScale += (1 - _lastScale);
        
        _lastScale = 1;
       
        [_scrollView setDelegate:self];
		
        return;
	}
    
    
	CGFloat mScale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);

	CGAffineTransform currentTransform = _scalableView.transform;
    
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, mScale, mScale);

	[_scalableView setTransform:newTransform];

	_lastScale = [(UIPinchGestureRecognizer*)sender scale];
    
    [_glViewController setGLObjectOffsetScale:[NSNumber numberWithFloat:MIN(2, _totalScale - _lastScale)]];
    
    
    // To be sure it doesn't get too small.
    if((_totalScale - _lastScale) > 2)
    {
        _totalScale -= (_totalScale - _lastScale)-2;
    }
}


- (void)move:(id)sender
{
    // Stop autoscrolling
    [self turnOffAutorotateIfNecessary];
    
    
    // Remove - so that delegate methods would not be called
    [_scrollView setDelegate:nil];
    
    
	CGPoint mTranslatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    mTranslatedPoint = CGPointMake(_firstPanPointX+mTranslatedPoint.x, _firstPanPointY+mTranslatedPoint.y);
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
		_firstPanPointX = mTranslatedPoint.x;
        
		_firstPanPointY = mTranslatedPoint.y;
        
        [_scrollView setDelegate:self];
    
        return;
	}

	
	[_scalableView setCenter:mTranslatedPoint];

	CGFloat mFinalX = mTranslatedPoint.x;
		
    CGFloat mFinalY = mTranslatedPoint.y;
        
    
    [_glViewController setGLObjectOPannX:[NSNumber numberWithFloat:mFinalX/1000*3] andPannY:[NSNumber numberWithFloat:-mFinalY/1000*3]];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // So that pinch and pan could be used together
    
    if(!_scrollViewIsNotScrolling)
    {
        return NO;
    }
    
    if (gestureRecognizer == _rotateRecognizer || otherGestureRecognizer == _rotateRecognizer)
    {
        return YES;
    }
    
    if (gestureRecognizer == _panRecognizer && otherGestureRecognizer == _pinchRecognizer)
    {
        return YES;
    }
    
    if (gestureRecognizer == _pinchRecognizer && otherGestureRecognizer == _panRecognizer)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - autorotate

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft
        || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
