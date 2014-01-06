//
//  GLViewController.h
//  Wavefront OBJ Loader
//
//  Created by Jeff LaMarche on 12/14/08.
//  Copyright Jeff LaMarche 2008. All rights reserved.
//

#import "GLViewController.h"

#import "GLView.h"

#import <math.h>

#import "LInteractionViewController.h"

#import "AppDelegate.h"


#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

@implementation GLViewController

#pragma mark - init 

- (id)initWithObjectIndex:(NSInteger)mIndex
{
    self = [super init];
    
    if (self)
    {
        _selectedIndex = mIndex;
    }
    
    return self;
}

#pragma mark - dealloc

- (void)dealloc
{
    DLog();
}

#pragma mark - set up stuff

- (void)setupView:(GLView*)view
{
    [self firstSetUp:view];
    
	glGetError(); // Clear error codes
	
    // We do it after a delay so that pushviewcontroller animation would not be paused.
    [self performSelector:@selector(setUpObject) withObject:nil afterDelay:0.4];
}


- (void)firstSetUp:(GLView*)view
{
    const GLfloat lightAmbient[] = {0.2, 0.2, 0.2, 1.0};
    
	const GLfloat lightDiffuse[] = {0.4, 0.4, 0.4, 1.0};
	
	const GLfloat lightPosition[] = {5.0, 5.0, 15.0, 0.0};
	
    const GLfloat light2Position[] = {-5.0, -5.0, 15.0, 0.0};
    
	
    const GLfloat lightShininess = 0.0;
	
    const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0;
	
    
    GLfloat size;
	
    
    glDepthFunc(GL_LEQUAL);

    glEnable(GL_BLEND);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_DEPTH_TEST);
	
    glMatrixMode(GL_PROJECTION);
	
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	
    CGRect rect = view.bounds;
    
    
    rect.size.width *= [[UIScreen mainScreen] scale];
    
    rect.size.height *= [[UIScreen mainScreen] scale];
  
  
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
        (rect.size.width / rect.size.height), zNear, zFar);
  
    
	glViewport(0, 0, rect.size.width, rect.size.height);
    
    
	glMatrixMode(GL_MODELVIEW);

	glShadeModel(GL_SMOOTH);

	glEnable(GL_LIGHTING);

	glEnable(GL_LIGHT0);

	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);

	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);

	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);

	glLightfv(GL_LIGHT0, GL_SHININESS, &lightShininess);

	
	glEnable(GL_LIGHT1);

	glLightfv(GL_LIGHT1, GL_AMBIENT, lightAmbient);

	glLightfv(GL_LIGHT1, GL_DIFFUSE, lightDiffuse);

	glLightfv(GL_LIGHT1, GL_POSITION, light2Position);

	glLightfv(GL_LIGHT1, GL_SHININESS, &lightShininess);
	

	glLoadIdentity();

	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
}


- (void)setUpObject
{
    _allPartsMutArray = [NSMutableArray new];
    
    Rotation3D rot;
    
    
    //--- set up necessary variables
    OpenGLWaveFrontObject *theObject = nil;
    
    Vertex3D position = Vertex3DMake(0.0, 0.0, 0.0);
    
    Vertex3D centerOfMassPosition = Vertex3DMake(0.0, 0.0, 0.0);
    
    OpenGLTexture3D *tempNormalTexture = nil;
    
    NSArray *centerOfMassPositionsArray = nil;
    //===
    
    
    
    //--- normal texture        ...  We get prefix variable from selected array (for example 'a'  - so we access a.png)
    tempNormalTexture = [[OpenGLTexture3D alloc] initWithFilename:[NSString stringWithFormat:@"%@",
        [[[_AppDelegate objectArray] objectAtIndex:_selectedIndex] objectAtIndex:1]]];
    //===
    

    
        //---
        /*
            We load up content of files:
                aHeader.b        (for vertices count and center coordinates array)
                aPartVerts.b
                aPartNormals.b
                aPartTextureCoords.b
                
                and forwart it to openglWavefrontObject class
        */
    
        NSString *mPartsObjDataPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Header",
            [[[_AppDelegate objectArray] objectAtIndex:_selectedIndex] objectAtIndex:1]] ofType:@"b"];

        NSString *mPartsObjDataPathData = [NSString stringWithContentsOfFile:mPartsObjDataPath encoding:NSUTF8StringEncoding error:NULL];


        NSArray *mDataArray = @[[NSNumber numberWithInt:[[[mPartsObjDataPathData componentsSeparatedByString:@"\n"] objectAtIndex:0] intValue]],
            [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@PartVerts",
                [[[_AppDelegate objectArray] objectAtIndex:_selectedIndex] objectAtIndex:1]] ofType:@"b"]],
            [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@PartNormals",
                [[[_AppDelegate objectArray] objectAtIndex:_selectedIndex] objectAtIndex:1]] ofType:@"b"]],
            [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@PartTextureCoords",
                [[[_AppDelegate objectArray] objectAtIndex:_selectedIndex] objectAtIndex:1]] ofType:@"b"]]];
        
        theObject = [[OpenGLWaveFrontObject alloc] initInQuickWayUsingDataArrayDataArray:mDataArray];
        //===

        
        
            
        //--- mass center coordinates data (so that it would rotate around its center coordinates)
        centerOfMassPositionsArray = [[[mPartsObjDataPathData componentsSeparatedByString:@"\n"] objectAtIndex:1]
            componentsSeparatedByString:@","];
        //===
        
        
        //--- set up default position and rotation
        position.z = 0.0;
        
        position.y = 0.0;
        
        position.x = 0.0;
        
        
        rot.y = -1000+190;
        
        rot.x = -1000+280;
        
        rot.z = 0;
        //===
        
        
        
        centerOfMassPosition.x = [[centerOfMassPositionsArray objectAtIndex:0] floatValue];
        
        centerOfMassPosition.y = [[centerOfMassPositionsArray objectAtIndex:1] floatValue];
        
        centerOfMassPosition.z = [[centerOfMassPositionsArray objectAtIndex:2] floatValue];
        
        [theObject setCenterOfMassPosition:centerOfMassPosition];
        
    
        // We start at alpha 0, and then when object is loaded - it appears with fade in.
        [theObject setAlphaVisibilityValue:0.0];
        
        
    
        [theObject setNormalTexture:tempNormalTexture];
    
        [theObject setCurrentPosition:position];
    
        [theObject setCurrentRotation:rot];
        
        
    

        [_allPartsMutArray addObject:theObject];
        
        [_glViewDelegate performSelector:@selector(drawView)];
}

#pragma mark - functions

- (void)setGLObjectRotation:(NSNumber *)mRotVal
{
    for(OpenGLWaveFrontObject *mPart in _allPartsMutArray)
    {
        [mPart setCurrentRotation:Rotation3DMake(mPart.currentRotation.x, mPart.currentRotation.y,
            mPart.currentRotation.z - [mRotVal floatValue]*50)];
    }
}


- (void)setGLObjectOPannX:(NSNumber *)mX andPannY:(NSNumber *)mY
{
    for(OpenGLWaveFrontObject *mPart in _allPartsMutArray)
    {
        [mPart setObjectPannX:[mX floatValue]];
        
        [mPart setObjectPannY:[mY floatValue]];
    }
}


- (void)setGLObjectOffsetScale:(NSNumber *)mScale
{
    for(OpenGLWaveFrontObject *mPart in _allPartsMutArray)
    {
        [mPart setObjectScale:[mScale floatValue]];
    }
}


- (void)setOffsetX:(double)mX andY:(double)mY
{
    for(OpenGLWaveFrontObject *mPart in _allPartsMutArray)
    {
        [mPart setCurrentRotation:Rotation3DMake(-mY, -mX, mPart.currentRotation.z)];
    }
}

#pragma mark - draw view

- (void)drawView:(GLView*)view;
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
    glLoadIdentity();
    
    for(OpenGLWaveFrontObject *mPart in _allPartsMutArray)
    {
        [mPart drawSelf];
    }
}

#pragma mark -
#pragma mark rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (BOOL)shouldAutorotate
{
    return YES;
}

@end
