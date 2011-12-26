//
//  XPathQuery.m
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

#import "MTXPathResultNode.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

//
// BUILD NOTES:
//
// To build this file, the current target should have:
//	$(SDK_ROOT)/usr/include/libxml2
// added to the list of "Header Search Paths" and the libxml2.dylib should be
// added to the project.
//

@interface MTXPathResultNode ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSMutableDictionary *attributes;
@property (nonatomic, strong, readwrite) NSMutableArray *content;

@end

@implementation MTXPathResultNode

@synthesize name;
@synthesize attributes;
@synthesize content;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"<%@", name];
	
    for (NSString *attributeName in attributes) {
		NSString *attributeValue = [attributes objectForKey:attributeName];
		[description appendFormat:@" %@=\"%@\"", attributeName, attributeValue];
	}
	
	if ([content count] > 0) {
		[description appendString:@">"];
        
		for (id object in content) {
			[description appendString:[object description]];
		}
        
		[description appendFormat:@"</%@>", name];
	} else {
		[description appendString:@"/>"];
	}
    
	return description;
}

+ (MTXPathResultNode *)nodefromLibXMLNode:(xmlNodePtr)libXMLNode parentNode:(MTXPathResultNode *)parentNode {
	MTXPathResultNode *node = [[MTXPathResultNode alloc] init];
	
	if (libXMLNode->name)
	{
		node.name = [NSString stringWithCString:(const char *)libXMLNode->name encoding:NSUTF8StringEncoding];
	}
	
	if (libXMLNode->content && libXMLNode->type != XML_DOCUMENT_TYPE_NODE)
	{
		NSString *contentString =
			[NSString stringWithCString:(const char *)libXMLNode->content encoding:NSUTF8StringEncoding];
		
		if (parentNode &&
			(libXMLNode->type == XML_CDATA_SECTION_NODE || libXMLNode->type == XML_TEXT_NODE))
		{
			if (libXMLNode->type == XML_TEXT_NODE)
			{
				contentString = [contentString
					stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			}
			
			if (!parentNode.content)
			{
				parentNode.content = [NSMutableArray arrayWithObject:contentString];
			}
			else
			{
				[parentNode.content addObject:contentString];
			}
			return nil;
		}
	}
	
	xmlAttr *attribute = libXMLNode->properties;
	if (attribute)
	{
		while (attribute)
		{
			NSString *attributeName = nil;
			NSString *attributeValue = nil;
			
			if (attribute->name && attribute->children && attribute->children->type == XML_TEXT_NODE && attribute->children->content)
			{
				attributeName =
					[NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
				attributeValue =
					[NSString stringWithCString:(const char *)attribute->children->content encoding:NSUTF8StringEncoding];
				
				if (attributeName && attributeValue)
				{
					if (!node.attributes)
					{
						node.attributes = [NSMutableDictionary dictionaryWithObject:attributeValue forKey:attributeName];
					}
					else
					{
						[node.attributes setObject:attributeValue forKey:attributeName];
					}
				}
			}
			
			attribute = attribute->next;
		}
	}

	xmlNodePtr childLibXMLNode = libXMLNode->children;
	if (childLibXMLNode)
	{
		while (childLibXMLNode)
		{
			MTXPathResultNode *childNode = [MTXPathResultNode nodefromLibXMLNode:childLibXMLNode parentNode:node];
			if (childNode)
			{
				if (!node.content)
				{
					node.content = [NSMutableArray arrayWithObject:childNode];
				}
				else
				{
					[node.content addObject:childNode];
				}
			}
			
			childLibXMLNode = childLibXMLNode->next;
		}
	}
	
	return node;
}

+ (NSArray *)nodesForXPathQuery:(NSString *)query onLibXMLDoc:(xmlDocPtr)doc {
    xmlXPathContextPtr xpathCtx; 
    xmlXPathObjectPtr xpathObj; 

    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL)
	{
		NSLog(@"Unable to create XPath context.");
		return nil;
    }
    
    /* Evaluate xpath expression */
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    if(xpathObj == NULL) {
		NSLog(@"Unable to evaluate XPath.");
		return nil;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	if (!nodes)
	{
		NSLog(@"Nodes was nil.");
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	for (NSInteger i = 0; i < nodes->nodeNr; i++)
	{
		MTXPathResultNode *node = [MTXPathResultNode nodefromLibXMLNode:nodes->nodeTab[i] parentNode:nil];
		if (node)
		{
			[resultNodes addObject:node];
		}
	}

    /* Cleanup */
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx); 
    
    return resultNodes;
}

+ (NSArray *)nodesForXPathQuery:(NSString *)query onHTML:(NSData *)htmlData {
    xmlDocPtr doc;

    /* Load XML document */
	doc = htmlReadMemory([htmlData bytes], [htmlData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = [MTXPathResultNode nodesForXPathQuery:query onLibXMLDoc:doc];
    xmlFreeDoc(doc); 
	
	return result;
}

+ (NSArray *)nodesForXPathQuery:(NSString *)query onXML:(NSData *)xmlData {
    xmlDocPtr doc;
	
    /* Load XML document */
	doc = xmlReadMemory([xmlData bytes], [xmlData length], "", NULL, XML_PARSE_RECOVER);
	
    if (doc == NULL)
	{
		NSLog(@"Unable to parse.");
		return nil;
    }
	
	NSArray *result = [MTXPathResultNode nodesForXPathQuery:query onLibXMLDoc:doc];
    xmlFreeDoc(doc); 
	
	return result;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTXPathResultNode
////////////////////////////////////////////////////////////////////////

- (NSArray *)childNodes {
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSObject *object in content) {
		if ([object isKindOfClass:[MTXPathResultNode class]]) {
			[result addObject:object];
		}
	}
	
	return result;
}

- (NSString *)contentString {
	for (NSObject *object in content) {
		if ([object isKindOfClass:[NSString class]]) {
			return (NSString *)object;
		}
	}
	
	return nil;
}

- (NSString *)contentStringByUnifyingSubnodes {
	NSMutableString *result = nil;
	
	for (NSObject *object in content) {
		if ([object isKindOfClass:[NSString class]]) {
			if (!result) {
				result = [NSMutableString stringWithString:(NSString *)object];
			} else {
				[result appendString:(NSString *)object];
			}
		} else {
			NSString *subnodeResult = [(MTXPathResultNode *)object contentStringByUnifyingSubnodes];
			
			if (subnodeResult) {
				if (!result) {
					result = [NSMutableString stringWithString:subnodeResult];
				} else {
					[result appendString:subnodeResult];
				}
			}
		}
	}
	
	return result;
}

@end

