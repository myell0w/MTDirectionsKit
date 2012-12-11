//
//  MTDXMLElement.h
//
//  Updated by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//
//  Based on Matt Gallagher's XPathResultNode from cocoawithlove.com, modified for MTDirectionsKit.
//  Original LICENSE:
//
//  CocoaWithLove
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//


/**
 An instance of MTDXMLElement represents one XML node of a whole XML tree.
 It is used to parse XML documents and uses libxml under the hood, which allows
 for convenient use of XPath.
 */
@interface MTDXMLElement : NSObject

/******************************************
 @name XML Element
 ******************************************/

/** the tag name of the xml node */
@property (nonatomic, strong, readonly) NSString *name;
/** all attributes of the node */
@property (nonatomic, strong, readonly) NSDictionary *attributes;
/** all content sections of the node */
@property (nonatomic, strong, readonly) NSArray *content;

/** all child nodes of the current node in the xml-tree */
@property (nonatomic, readonly) NSArray *childNodes;
/** the content of this node represented as string */
@property (nonatomic, readonly) NSString *contentString;
/** the content of this node and all childnodes (recursive) as concatenated string */
@property (nonatomic, readonly) NSString *contentStringByUnifyingSubnodes;

/******************************************
 @name Lifecycle
 ******************************************/

/**
 Returns an array of all xml nodes matching the given query on the given xml data.
 
 @param query the xpath query
 @param xmlData data representing a xml document
 @return array of MTDXMLElements
 @see nodeForXPathQuery:onXML:
 */
+ (NSArray *)nodesForXPathQuery:(NSString *)query onXML:(NSData *)xmlData;

/**
 Returns an array of all xml nodes matching the given query on the given xml data in the given namespace.

 @param query the xpath query
 @param xmlData data representing a xml document
 @param namespacePrefix the XML namespace prefix used
 @param namespaceURI the URI of the namesapce
 @return array of MTDXMLElements
 @see nodeForXPathQuery:onXML:
 */
+ (NSArray *)nodesForXPathQuery:(NSString *)query onXML:(NSData *)xmlData namespacePrefix:(NSString *)namespacePrefix namespaceURI:(NSString *)namespaceURI;

/**
 Returns the first xml node matching the given query on the given xml data.
 
 @param query the xpath query
 @param xmlData data representing a xml document
 @return MTDXMLElement representing the first node matching
 */
+ (instancetype)nodeForXPathQuery:(NSString *)query onXML:(NSData *)xmlData;

/**
 Returns the first xml node matching the given query on the given xml data in the given namespace.

 @param query the xpath query
 @param xmlData data representing a xml document
 @param namespacePrefix the XML namespace prefix used
 @param namespaceURI the URI of the namesapce
 @return MTDXMLElement representing the first node matching
 */
+ (instancetype)nodeForXPathQuery:(NSString *)query onXML:(NSData *)xmlData namespacePrefix:(NSString *)namespacePrefix namespaceURI:(NSString *)namespaceURI;


/******************************************
 @name Queries
 ******************************************/

/**
 Returns the first child node with the given tagname.
 
 @param name the tag name of the child we want
 @return an instance of MTDXMLElement representing the first found child node, or nil if there was none found
 */
- (MTDXMLElement *)firstChildNodeWithName:(NSString *)name;

/**
 Returns an array of child nodes with the given tagname.
 
 @param name the tag name of the children we want
 @return an array of MTDXMLElements
 */
- (NSArray *)childNodesWithName:(NSString *)name;

/**
 Returns an array of child nodes with the given dot-separated path, e.g. shape.shapePoints.latLng
 For all path components except the last one only the first child is traversed, if there are several.
 
 @param path a dot-separated path of tag names
 @return an array of MTDXMLElements
 */
- (NSArray *)childNodesTraversingFirstChildWithPath:(NSString *)path;

/**
 Returns an array of child nodes with the given dot-separated path, e.g. shape.shapePoints.latLng
 For all path components all children are traversed.

 @param path a dot-separated path of tag names
 @return an array of MTDXMLElements
 */
- (NSArray *)childNodesTraversingAllChildrenWithPath:(NSString *)path;

/**
 Returns the attribute value of attribute with the given name.
 
 @param attributeName the name of the attribute
 @return the value of the attribute
 */
- (id)attributeWithName:(NSString *)attributeName;

@end
