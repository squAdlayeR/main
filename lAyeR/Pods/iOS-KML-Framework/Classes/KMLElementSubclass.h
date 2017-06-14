//
//  KMLElementSubclass.h
//  KML Framework
//
//  Created by NextBusinessSystem on 12/04/06.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "KMLElement.h"
#import "TBXML.h"

@interface KMLElement ()


// Tag

+ (NSString *)tagName;
+ (NSArray *)implementClasses;


// Initializing a Element

- (id)initWithXMLElement:(TBXMLElement *)element parent:(KMLElement *)parent;


// Parsing

- (NSString *)textForSingleChildElementNamed:(NSString *)name xmlElement:(TBXMLElement *)element;
- (NSString *)textForSingleChildElementNamed:(NSString *)name xmlElement:(TBXMLElement *)element required:(BOOL)required;
- (KMLElement *)childElementOfClass:(Class)class xmlElement:(TBXMLElement *)element;
- (KMLElement *)childElementOfClass:(Class)class xmlElement:(TBXMLElement *)element required:(BOOL)required;
- (KMLElement *)childElementNamed:(NSString *)name class:(Class)class xmlElement:(TBXMLElement *)element;
- (KMLElement *)childElementNamed:(NSString *)name class:(Class)class xmlElement:(TBXMLElement *)element required:(BOOL)required;
- (void)childElementsOfClass:(Class)class xmlElement:(TBXMLElement *)element eachBlock:(void (^)(KMLElement *element))eachBlock;


// Generating

- (void)kml:(NSMutableString *)kml indentationLevel:(NSInteger)indentationLevel;
- (void)addOpenTagToKml:(NSMutableString *)kml indentationLevel:(NSInteger)indentationLevel;
- (void)addChildTagToKml:(NSMutableString *)kml indentationLevel:(NSInteger)indentationLevel;
- (void)addCloseTagToKml:(NSMutableString *)kml indentationLevel:(NSInteger)indentationLevel;

- (void)kml:(NSMutableString *)kml addPropertyForValue:(NSString *)value tagName:(NSString *)tagName indentationLevel:(NSInteger)indentationLevel;
- (void)kml:(NSMutableString *)kml addPropertyForValue:(NSString *)value tagName:(NSString *)tagName attribute:(NSString *)attribute indentationLevel:(NSInteger)indentationLevel;
- (void)kml:(NSMutableString *)kml addPropertyForValue:(NSString *)value defaultValue:(NSString *)defaultValue tagName:(NSString *)tagName indentationLevel:(NSInteger)indentationLevel;
- (void)kml:(NSMutableString *)kml addPropertyForValue:(NSString *)value defaultValue:(NSString *)defaultValue tagName:(NSString *)tagName attribute:(NSString *)attribute indentationLevel:(NSInteger)indentationLevel;
- (NSString *)indentForIndentationLevel:(NSInteger)indentationLevel;

@end
