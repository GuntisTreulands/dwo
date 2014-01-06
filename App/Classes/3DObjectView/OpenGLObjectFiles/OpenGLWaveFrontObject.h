//
//  OpenGLWaveFrontObject.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>

#import <OpenGLES/ES1/glext.h>

#import "OpengLWaveFrontCommon.h"

#import "OpenGLTexture3D.h"

#define USE_FAST_NORMALIZE 


@interface OpenGLWaveFrontObject : NSObject
{
    CGFloat _Matrix[16];
    
    double _prevX;
    
    double _prevY;
    
    double _prevZ;
}

@property (nonatomic) GLfloat *textureCoords;

@property (nonatomic) Vector3D *vertexNormals;

@property (nonatomic) CGFloat objectScale;

@property (nonatomic) CGFloat objectPannX;

@property (nonatomic) CGFloat objectPannY;

@property (nonatomic) GLuint numberOfVertices;

@property (nonatomic, strong) OpenGLTexture3D *normalTexture;

@property (nonatomic) CGFloat alphaVisibilityValue;

@property Vertex3D centerOfMassPosition;

@property Vertex3D centerPosition;

@property Vertex3D currentPosition;

@property Rotation3D currentRotation;

@property (nonatomic) Vertex3D *vertices;


- (id)initInQuickWayUsingDataArrayDataArray:(NSArray *)mDataArray;

- (void)drawSelf;

@end
