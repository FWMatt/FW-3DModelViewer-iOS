//
//  GLUtils.m
//
//  GLView Project
//  Version 1.4
//
//  Created by Nick Lockwood on 04/06/2012.
//  Copyright 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/GLView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "GLUtils.h"
#import <objc/message.h>


#pragma mark-
#pragma mark Public utils

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
               GLfloat centerx, GLfloat centery, GLfloat centerz)
{
    GLfloat upx = 0.0f, upy = 1.0f, upz = 0.0f;
    GLfloat m[16];
    GLfloat x[3], y[3], z[3];
    GLfloat mag;
    
    /* Make rotation matrix */
    
    /* Z vector */
    z[0] = eyex - centerx;
    z[1] = eyey - centery;
    z[2] = eyez - centerz;
    mag = sqrt(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
    if (mag) {          /* mpichler, 19950515 */
        z[0] /= mag;
        z[1] /= mag;
        z[2] /= mag;
    }
    
    /* Y vector */
    y[0] = upx;
    y[1] = upy;
    y[2] = upz;
    
    /* X vector = Y cross Z */
    x[0] = y[1] * z[2] - y[2] * z[1];
    x[1] = -y[0] * z[2] + y[2] * z[0];
    x[2] = y[0] * z[1] - y[1] * z[0];
    
    /* Recompute Y = Z cross X */
    y[0] = z[1] * x[2] - z[2] * x[1];
    y[1] = -z[0] * x[2] + z[2] * x[0];
    y[2] = z[0] * x[1] - z[1] * x[0];
    
    /* mpichler, 19950515 */
    /* cross product gives area of parallelogram, which is < 1.0 for
     * non-perpendicular unit-length vectors; so normalize x, y here
     */
    
    mag = sqrt(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
    if (mag) {
        x[0] /= mag;
        x[1] /= mag;
        x[2] /= mag;
    }
    
    mag = sqrt(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
    if (mag) {
        y[0] /= mag;
        y[1] /= mag;
        y[2] /= mag;
    }
    
#define M(row,col)  m[col*4+row]
    M(0, 0) = x[0];
    M(0, 1) = x[1];
    M(0, 2) = x[2];
    M(0, 3) = 0.0;
    M(1, 0) = y[0];
    M(1, 1) = y[1];
    M(1, 2) = y[2];
    M(1, 3) = 0.0;
    M(2, 0) = z[0];
    M(2, 1) = z[1];
    M(2, 2) = z[2];
    M(2, 3) = 0.0;
    M(3, 0) = 0.0;
    M(3, 1) = 0.0;
    M(3, 2) = 0.0;
    M(3, 3) = 1.0;
#undef M
    glMultMatrixf(m);
    
    /* Translate Eye to Origin */
    glTranslatef(-eyex, -eyey, -eyez);
    
}


void CGRectGetGLCoords(CGRect rect, GLfloat *coords)
{
    coords[0] = rect.origin.x;
    coords[1] = rect.origin.y;
    coords[2] = rect.origin.x + rect.size.width;
    coords[3] = rect.origin.y;
    coords[4] = rect.origin.x + rect.size.width;
    coords[5] = rect.origin.y + rect.size.height;
    coords[6] = rect.origin.x;
    coords[7] = rect.origin.y + rect.size.height;
}


@implementation UIColor (GL)

- (void)getGLComponents:(GLfloat *)rgba
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = components[0];
            rgba[1] = components[0];
            rgba[2] = components[0];
            rgba[3] = components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = components[0];
            rgba[1] = components[1];
            rgba[2] = components[2];
            rgba[3] = components[3];
            break;
        }
        default:
        {
            
#ifdef DEBUG
            
            //unsupported format
            NSLog(@"Unsupported color model: %i", model);
#endif
            rgba[0] = 0.0f;
            rgba[1] = 0.0f;
            rgba[2] = 0.0f;
            rgba[3] = 1.0f;
            break;
        }
    }
}

- (void)bindGLClearColor
{
    GLfloat rgba[4];
    [self getGLComponents:rgba];
    glClearColor(rgba[0] * rgba[3], rgba[1] * rgba[3], rgba[2] * rgba[3], rgba[3]);
}

- (void)bindGLBlendColor
{    
    GLfloat rgba[4];
    [self getGLComponents:rgba];
    glBlendColor(rgba[0], rgba[1], rgba[2], rgba[3]);
}

- (void)bindGLColor
{    
    GLfloat rgba[4];
    [self getGLComponents:rgba];
    glColor4f(rgba[0], rgba[1], rgba[2], rgba[3]);
}

@end


#pragma mark -
#pragma mark Private utils


@implementation NSData (GL)

- (BOOL)GL_isGzippedData
{
    UInt8 *bytes = (UInt8 *)[self bytes];
    return ([self length] >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

- (NSData *)GL_unzippedData
{
    if ([self GL_isGzippedData])
    {
        //attempt to unzip using GZIP library
        if ([self respondsToSelector:NSSelectorFromString(@"gunzippedData")])
        {
            return [self valueForKey:@"gunzippedData"];
        }
        else
        {
            NSLog(@"The GZIP library is require to load gzipped files");
            return nil;
        }
    }
    return self;
}

@end


@implementation NSString (GL)

- (NSString *)GL_pathExtension
{
    NSString *extension = [self pathExtension];
    if ([extension isEqualToString:@"gz"])
    {
        extension = [[self stringByDeletingPathExtension] pathExtension];
        if ([extension length]) return [extension stringByAppendingPathExtension:@"gz"];
        return @"gz";
    }
    return extension;
}


- (NSString *)GL_stringByDeletingPathExtension
{
    NSString *extension = [self pathExtension];
    NSString *path = [self stringByDeletingPathExtension];
    if ([extension isEqualToString:@"gz"])
    {
        path = [path stringByDeletingPathExtension];
    }
    return path;
}

- (BOOL)GL_hasRetinaFileSuffix
{
    SEL pathScaleSelector = NSSelectorFromString(@"scaleFromSuffix");
    if ([self respondsToSelector:pathScaleSelector])
    {
        return [[self valueForKey:@"scaleFromSuffix"] floatValue] == 2.0f;
    }
    else
    {
        NSString *name = [self GL_stringByDeletingPathExtension];
        if ([name hasSuffix:@"~ipad"]) name = [name substringToIndex:[name length] - 5];
        if ([name hasSuffix:@"~iphone"]) name = [name substringToIndex:[name length] - 7];
        if ([name hasSuffix:@"@2x"]) return YES;
    }
    return NO;
}

- (NSString *)GL_normalizedPathWithDefaultExtension:(NSString *)extension
{
    //extension
    NSString *path = self;
    if (![[self pathExtension] length])
    {
        path = [path stringByAppendingPathExtension:extension];
    }
    else
    {
        extension = [path GL_pathExtension];
    }
    
    //use StandardPaths if available
    SEL normalizedPathSelector = NSSelectorFromString(@"normalizedPathForFile:");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager respondsToSelector:normalizedPathSelector])
    {
        return objc_msgSend(fileManager, normalizedPathSelector, path);
    }
    
    //convert to absolute path
    if (![self isAbsolutePath])
    {
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }
    
    //check for @2x version
    if ([UIScreen mainScreen].scale == 2.0f)
    {
        NSString *retinaPath = [[[path GL_stringByDeletingPathExtension] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:extension];
        if ([fileManager fileExistsAtPath:retinaPath])
        {
            path = retinaPath;
        }
    }
    
    //check for ~ipad or ~iphone version
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSString *iPadPath = [[[path GL_stringByDeletingPathExtension] stringByAppendingString:@"~ipad"] stringByAppendingPathExtension:extension];
        if ([fileManager fileExistsAtPath:iPadPath])
        {
            path = iPadPath;
        }
    }
    else
    {
        NSString *iPhonePath = [[[path GL_stringByDeletingPathExtension] stringByAppendingString:@"~iphone"] stringByAppendingPathExtension:extension];
        if ([fileManager fileExistsAtPath:iPhonePath])
        {
            path = iPhonePath;
        }
    }
    
    //default path
    return [fileManager fileExistsAtPath:path]? path: nil;
}

@end
