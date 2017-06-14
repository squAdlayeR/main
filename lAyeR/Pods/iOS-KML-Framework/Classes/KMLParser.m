//
//  KMLParser.m
//  KML Framework
//
//  Created by NextBusinessSystem on 12/04/06.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "KMLParser.h"
#import "KMLConst.h"
#import "KMLElementSubclass.h"
#import "KMLRoot.h"
#import "KMLAbstractContainer.h"
#import "KMLPlacemark.h"

@implementation KMLParser


#pragma mark - Instance

+ (KMLRoot *)parseKMLAtURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    return [KMLParser parseKMLWithData:data];
}

+ (KMLRoot *)parseKMLAtPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    return [KMLParser parseKMLAtURL:url];
}

+ (KMLRoot *)parseKMLWithString:(NSString*)string
{
    TBXML *xml = [TBXML tbxmlWithXMLString:string error:nil];
    if (xml.rootXMLElement) {
        return [[KMLRoot alloc] initWithXMLElement:xml.rootXMLElement parent:nil];
    }
    
    return nil;
}

+ (KMLRoot *)parseKMLWithData:(NSData*)data
{
    TBXML *xml = [TBXML tbxmlWithXMLData:data error:nil];
    if (xml.rootXMLElement) {
        return [[KMLRoot alloc] initWithXMLElement:xml.rootXMLElement parent:nil];
    }
    
    return nil;
}

@end
