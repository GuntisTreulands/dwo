//
//  GLView.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGLDrawable.h>

#import "GLView.h"

#import "GLViewController.h"


@implementation GLView

#pragma mark - layer,  layout subviews

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}


- (void)layoutSubviews
{
	[EAGLContext setCurrentContext:_context];
    
    const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0;
    
	GLfloat size;
    
	size = zNear *tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    
	CGRect rect;
    
    float mMaxHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    
    float mRatio = mMaxHeight/320;
    
    if(mMaxHeight > 500)
    {
        rect = CGRectMake(0, -700, mMaxHeight, (mMaxHeight-20)*mRatio);
    }
    else
    {
        if([[UIScreen mainScreen] scale] == 2)
        {
            rect = CGRectMake(0, -400, mMaxHeight, (mMaxHeight-20)*mRatio);
        }
        else
        {
            rect = CGRectMake(0, -200, mMaxHeight, (mMaxHeight-20)*mRatio);
        }
    }
    

    rect.size.width *= [[UIScreen mainScreen] scale];
    
    rect.size.height *= [[UIScreen mainScreen] scale];
  
	glFrustumf(-size, size, -size / (self.bounds.size.width / self.bounds.size.height), size / 
			   (self.bounds.size.width / self.bounds.size.height), zNear, zFar); 
	
    glViewport(0, rect.origin.y, rect.size.width, rect.size.height);
    
    
    
	[self destroyFramebuffer];

	[self createFramebuffer];
	
    
    
    [self drawView];
}

#pragma mark - init 

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
    if(self != nil)
	{
		self = [self initGLES];
	}
    
	return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder]))
	{
		self = [self initGLES];
	}
    
    
	return self;
}


- (id)initGLES
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	
    [eaglLayer setContentsScale:[[UIScreen mainScreen] scale]];
    
    
	// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
	[eaglLayer setOpaque:YES];
    
	[eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil]];
	
	// Create our EAGLContext, and if successful make it current and create our framebuffer.
	_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	
    if(!_context || ![EAGLContext setCurrentContext:_context] || ![self createFramebuffer])
	{
		return nil;
	}
	
    
	// Default the animation interval to 1/60th of a second.
	_animationInterval = 1.0 / 60;
    
	return self;
}


- (GLViewController *)controller
{
	return _controller;
}


- (void)setController:(GLViewController *)d
{
	_controller = d;
    
	_controllerSetup = ![_controller respondsToSelector:@selector(setupView:)];
}

#pragma mark create/destroy frame buffer

- (BOOL)createFramebuffer
{
    // Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(2, &_invisibleFramebuffer);
	glGenRenderbuffersOES(2, &_invisibleRenderbuffer);
	
    
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen whereever the layer is (which corresponds with our view).
	[_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _invisibleRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
	
    
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &_viewFramebuffer);
	glGenRenderbuffersOES(1, &_viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
    
	// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
	// allowing us to draw into a buffer that will later be rendered to screen whereever the layer is (which corresponds with our view).
	[_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
	
    
	// For this sample, we also need a depth buffer, so we'll create and attach one via another renderbuffer.
	glGenRenderbuffersOES(1, &_depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, _backingWidth, _backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthRenderbuffer);

	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &_invisibleFramebuffer);
	_invisibleFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &_invisibleRenderbuffer);
	_invisibleRenderbuffer = 0;
    
    
	glDeleteFramebuffersOES(1, &_viewFramebuffer);
	_viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &_viewRenderbuffer);
	_viewRenderbuffer = 0;
	
	if(_depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
		
        _depthRenderbuffer = 0;
	}
}

#pragma mark - functions

- (void)startAnimation
{
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationInterval
        target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation
{
	[_animationTimer invalidate], _animationTimer = nil;
}


- (void)setAnimationInterval:(NSTimeInterval)interval
{
	_animationInterval = interval;
	
	if(_animationTimer)
	{
		[self stopAnimation];
        
		[self startAnimation];
	}
}

// Updates the OpenGL view when the timer fires
- (void)drawView
{
    if(!_animationTimer)
    {
        return;
    }
    
    // Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:_context];
	
	// If our drawing delegate needs to have the view setup, then call -setupView: and flag that it won't need to be called again.
	
    if(!_controllerSetup)
	{
		[_controller setupView:self];
        
		_controllerSetup = YES;
	}
  
  
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);

	[_controller drawView:self];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
	
    
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


// Stop animating and release resources when they are no longer needed.
- (void)dealloc
{
    DLog();

	[self stopAnimation];
	
	if([EAGLContext currentContext] == _context)
	{
		[EAGLContext setCurrentContext:nil];
	}
}


@end
