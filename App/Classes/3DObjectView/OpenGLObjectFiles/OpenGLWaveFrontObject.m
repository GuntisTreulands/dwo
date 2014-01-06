//
//  OpenGLWaveFrontObject.m
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright 2008 Jeff LaMarche. All rights reserved.
//
// This file will load certain .obj files into memory and display them in OpenGL ES.
// Because of limitations of OpenGL ES, not all .obj files can be loaded - faces larger
// than triangles cannot be handled, so files must be exported with only triangles.


#import "OpenGLWaveFrontObject.h"

#import "OpenGLTexture3D.h"


@implementation OpenGLWaveFrontObject

#pragma mark - inital object launch

- (id)initInQuickWayUsingDataArrayDataArray:(NSArray *)mDataArray
{
    if ((self = [super init]))
	{
        /*  mDataArray Contents:
        
            vertsCount
            centerOfMass
            verteces
            normals
            txtCoords 
        */
    
        
        _numberOfVertices = [[mDataArray objectAtIndex:0] intValue];
    
        
        _vertices = malloc(sizeof(Vertex3D) * _numberOfVertices);
        
        NSData *mVertsBinaryData = [mDataArray objectAtIndex:1];
        
        [mVertsBinaryData getBytes:_vertices length:(sizeof(Vertex3D) * _numberOfVertices)];
        
    
        _vertexNormals = malloc(sizeof(Vertex3D) * _numberOfVertices);
        
        NSData *mNormalsBinaryData = [mDataArray objectAtIndex:2];
        
        [mNormalsBinaryData getBytes:_vertexNormals length:(sizeof(Vertex3D) * _numberOfVertices)];
        
    
        
        _textureCoords = malloc(sizeof(CGFloat) * 2 *  _numberOfVertices);
        
        NSData *mTextureCoordsBinaryData = [mDataArray objectAtIndex:3];
        
        [mTextureCoordsBinaryData getBytes:_textureCoords length:(sizeof(CGFloat) * 2 * _numberOfVertices)];
        
        
        
        for (int i = 0; i < 16; i++)
        {
            _Matrix[i] = (i % 5 == 0);
        }
    }
    
	return self;
}


- (void)multiplyMatrix:(CGFloat[16])M1 withMatrix:(CGFloat[16])M2
{
    CGFloat M3[16] =
    {
        M1[0]*M2[0] + M1[4]*M2[1]+ M1[8]*M2[2]+ M1[12]*M2[3],
        M1[1]*M2[0] + M1[5]*M2[1]+ M1[9]*M2[2]+ M1[13]*M2[3],
        M1[2]*M2[0] + M1[6]*M2[1]+ M1[10]*M2[2]+ M1[14]*M2[3],
        M1[3]*M2[0] + M1[7]*M2[1]+ M1[11]*M2[2]+ M1[15]*M2[3],
        
        M1[0]*M2[4] + M1[4]*M2[5]+ M1[8]*M2[6]+ M1[12]*M2[7],
        M1[1]*M2[4] + M1[5]*M2[5]+ M1[9]*M2[6]+ M1[13]*M2[7],
        M1[2]*M2[4] + M1[6]*M2[5]+ M1[10]*M2[6]+ M1[14]*M2[7],
        M1[3]*M2[4] + M1[7]*M2[5]+ M1[11]*M2[6]+ M1[15]*M2[7],
        
        M1[0]*M2[8] + M1[4]*M2[9]+ M1[8]*M2[10]+ M1[12]*M2[11],
        M1[1]*M2[8] + M1[5]*M2[9]+ M1[9]*M2[10]+ M1[13]*M2[11],
        M1[2]*M2[8] + M1[6]*M2[9]+ M1[10]*M2[10]+ M1[14]*M2[11],
        M1[3]*M2[8] + M1[7]*M2[9]+ M1[11]*M2[10]+ M1[15]*M2[11],
        
        M1[0]*M2[12] + M1[4]*M2[13]+ M1[8]*M2[14]+ M1[12]*M2[15],
        M1[1]*M2[12] + M1[5]*M2[13]+ M1[9]*M2[14]+ M1[13]*M2[15],
        M1[2]*M2[12] + M1[6]*M2[13]+ M1[10]*M2[14]+ M1[14]*M2[15],
        M1[3]*M2[12] + M1[7]*M2[13]+ M1[11]*M2[14]+ M1[15]*M2[15]
    };

    for (int i = 0; i<4*4; i++)
    {
        M1[i] = M3[i];
    }
}


- (void)drawSelf
{
	// Save the current transformation by pushing it on the stack
	glPushMatrix();
   
	// Load the identity matrix to restore to origin
	glLoadIdentity();
    

    // Translate to the panned location
	glTranslatef(_objectPannX, _objectPannY+0.08, -2-_objectScale);

    

    //-- calculate x rotation and create its rotation matrix
    double xRot = -_currentRotation.x * M_PI / 180.0;
    
    xRot -= _prevX;
    
    _prevX = -_currentRotation.x * M_PI / 180.0;
      
    GLfloat M1[16] = {1, 0, 0, 0, 0, cos(xRot), -sin(xRot), 0, 0, sin(xRot), cos(xRot), 0, 0, 0, 0, 1};
    //===
    
    
    //-- calculate y rotation and create its rotation matrix
    double yRot = -_currentRotation.y * M_PI / 180.0;
    
    yRot -= _prevY;
    
    _prevY = -_currentRotation.y * M_PI / 180.0;

    GLfloat M2[16] = {cos(yRot), 0, sin(yRot), 0, 0, 1, 0, 0, -sin(yRot), 0, cos(yRot), 0, 0, 0, 0, 1};
    //===
    
    
    //--- calculate z rotation and create its rotation matrix
    double zRot = -_currentRotation.z * M_PI / 180.0;
    
    zRot -= _prevZ;
    
    _prevZ = -_currentRotation.z * M_PI / 180.0;
    
    GLfloat M3[16]={cos(zRot), -sin(zRot), 0, 0, sin(zRot), cos(zRot), 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    //===
    
    
    //--- multiply matrix with all rotations.
    GLfloat tempM[16] = {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1};
    
    [self multiplyMatrix:tempM withMatrix:M1];
    
    [self multiplyMatrix:tempM withMatrix:M2];
    
    [self multiplyMatrix:tempM withMatrix:M3];
    //===
    
    
    //--- multiply global matrix using previously calculated matrix
    [self multiplyMatrix:tempM withMatrix:_Matrix];
    
    for (int i = 0; i < 4*4; i++)
    {
        _Matrix[i] = tempM[i];
    }
    //===
    
    
    glMultMatrixf(_Matrix);

    
    // Scale it
    glScalef(1-_objectScale/3, 1-_objectScale/3, 1-_objectScale/3);

    
    // Translate to the current position (for keyframes. Default = 0,0,0)
	glTranslatef(_currentPosition.x, _currentPosition.y, _currentPosition.z);


    // Move to parts real center position
    glTranslatef(-_centerOfMassPosition.x, -_centerOfMassPosition.y, -_centerOfMassPosition.z);


    
    // Enable and load the vertex array
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, _vertices);
	glNormalPointer(GL_FLOAT, 0, _vertexNormals);
	

    

    if(self.normalTexture && _textureCoords != NULL)
    {
        glEnable(GL_TEXTURE_2D);
    
        if (_textureCoords != NULL)
        {
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            
            glTexCoordPointer(2, GL_FLOAT, 0, _textureCoords);
        }
    }
    else
    {
        glDisable(GL_TEXTURE_2D);
    }
    
    


    if(self.normalTexture && _textureCoords != NULL && self.normalTexture != nil)
    {
        glColor4f(1.0, 1.0, 1.0, MIN(_alphaVisibilityValue,1.0));
        
        [self.normalTexture bind];
    }
    else
    {
        glColor4f(0.5, 0.5, 0.5, MIN(_alphaVisibilityValue,1.0));
    }

    glEnable(GL_COLOR_MATERIAL);
    
    
    glDrawArrays(GL_TRIANGLES, 0, self.numberOfVertices);
		
    
    if(self.normalTexture && _textureCoords != NULL)
    {
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    
	_alphaVisibilityValue += 0.025;
    
    glDisableClientState(GL_VERTEX_ARRAY);
	
    glDisableClientState(GL_NORMAL_ARRAY);
	
    // Restore the current transformation by popping it off
	glPopMatrix();
}


- (void)dealloc
{
	if (_vertices)
		free(_vertices);

	if (_vertexNormals)
		free(_vertexNormals);
        
	if (_textureCoords)
		free(_textureCoords);
    
    DLog();
}

@end
