//
//  GLView.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>

#import <OpenGLES/ES1/glext.h>


@class GLViewController;

@interface GLView : UIView
{
    //--- The pixel dimensions of the backbuffer
	GLint _backingWidth;
	
    GLint _backingHeight;
	//===
    
	EAGLContext *_context;
	
    GLuint _viewRenderbuffer, _viewFramebuffer;
    
    GLuint _invisibleRenderbuffer, _invisibleFramebuffer;
	
    GLuint _depthRenderbuffer;
	
    NSTimer *_animationTimer;
	
    NSTimeInterval _animationInterval;

	GLViewController *_controller;
    
	BOOL _controllerSetup;
}

@property(nonatomic, assign) GLViewController *controller;


- (void)setAnimationInterval:(NSTimeInterval)interval;

- (void)startAnimation;

- (void)stopAnimation;

- (void)drawView;

@end
