//
//  OpenGLTexture3D.m
//  NeHe Lesson 06
//
//  Created by Jeff LaMarche on 12/24/08.
//  Copyright 2008 Jeff LaMarche Consulting. All rights reserved.
//

#import "OpenGLTexture3D.h"


@implementation OpenGLTexture3D

#pragma mark - init function

- (id)initWithFilename:(NSString *)inFilename;
{
	if ((self = [super init]))
	{
		glEnable(GL_TEXTURE_2D);
		
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
		
        glGenTextures(1, &_texture);
		
        glBindTexture(GL_TEXTURE_2D, _texture);
		
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
		
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		
        glEnable(GL_BLEND);
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:inFilename ofType:@"png"]]];
        
        if (!image)
        {
            return nil;
        }
        
        float width = CGImageGetWidth(image.CGImage);
        
        float height = CGImageGetHeight(image.CGImage);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        void *imageData = malloc( height * width * 4 );
        
        CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
            kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        
        CGColorSpaceRelease( colorSpace );
        
        CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
        
        CGContextTranslateCTM( context, 0, height - height );
        
        CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );

     

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        CGContextRelease(context);
        
        free(imageData);

		glEnable(GL_BLEND);
	}
    
	return self;
}

#pragma mark - functions

- (void)bind
{
	glBindTexture(GL_TEXTURE_2D, _texture);
}

#pragma mark - dealloc

- (void)dealloc
{
    DLog();
    
	glDeleteTextures(1, &_texture);
}
@end
