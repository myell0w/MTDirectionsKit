#import "MTDXMLElement.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

@interface MTDXMLElement () {
    NSMutableDictionary *_attributes;
    NSMutableArray *_content;
}

+ (MTDXMLElement *)nodeFromLibXMLNode:(xmlNodePtr)libXMLNode parentNode:(MTDXMLElement *)parentNode;
+ (NSArray *)nodesForXPathQuery:(NSString *)query onLibXMLDoc:(xmlDocPtr)doc;

// re-defined as read/write
@property (nonatomic, strong, readwrite) NSString *name;

@end

@implementation MTDXMLElement

@synthesize name = _name;
@synthesize attributes = _attributes;
@synthesize content = _content;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (NSArray *)nodesForXPathQuery:(NSString *)query onHTML:(NSData *)htmlData {
    xmlDocPtr doc;
    
	doc = htmlReadMemory([htmlData bytes], (int)[htmlData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
    if (doc == NULL) {
		return nil;
    }
	
	NSArray *result = [MTDXMLElement nodesForXPathQuery:query onLibXMLDoc:doc];
    xmlFreeDoc(doc); 
	
	return result;
}

+ (NSArray *)nodesForXPathQuery:(NSString *)query onXML:(NSData *)xmlData {
    xmlDocPtr doc;
	
	doc = xmlReadMemory([xmlData bytes], (int)[xmlData length], "", NULL, XML_PARSE_RECOVER);
	
    if (doc == NULL) {
		return nil;
    }
	
	NSArray *result = [MTDXMLElement nodesForXPathQuery:query onLibXMLDoc:doc];
    xmlFreeDoc(doc); 
	
	return result;
}

+ (MTDXMLElement *)nodeForXPathQuery:(NSString *)query onXML:(NSData *)xmlData {
    NSArray *nodes = [self nodesForXPathQuery:query onXML:xmlData];

    if (nodes.count > 0) {
        return [nodes objectAtIndex:0];
    }

    return nil;
}

+ (MTDXMLElement *)nodeForXPathQuery:(NSString *)query onHTML:(NSData *)htmlData {
    NSArray *nodes = [self nodesForXPathQuery:query onHTML:htmlData];
    
    if (nodes.count > 0) {
        return [nodes objectAtIndex:0];
    }
    
    return nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////////////////////

- (NSString *)description {
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"<%@", self.name];
	
    for (NSString *attributeName in self.attributes) {
		NSString *attributeValue = [self.attributes objectForKey:attributeName];
		[description appendFormat:@" %@=\"%@\"", attributeName, attributeValue];
	}
	
	if (self.content.count > 0) {
		[description appendString:@">"];
        
		for (id object in self.content) {
			[description appendString:[object description]];
		}
        
		[description appendFormat:@"</%@>", self.name];
	} else {
		[description appendString:@"/>"];
	}
    
	return description;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTXPathResultNode
////////////////////////////////////////////////////////////////////////

- (NSArray *)childNodes {
    return [self.content filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, __unused NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[MTDXMLElement class]];
    }]];
}

- (NSString *)contentString {
	for (NSObject *object in self.content) {
		if ([object isKindOfClass:[NSString class]]) {
			return (NSString *)object;
		}
	}
	
	return nil;
}

- (NSString *)contentStringByUnifyingSubnodes {
	NSMutableString *result = nil;
	
	for (NSObject *object in self.content) {
		if ([object isKindOfClass:[NSString class]]) {
			if (!result) {
				result = [NSMutableString stringWithString:(NSString *)object];
			} else {
				[result appendString:(NSString *)object];
			}
		} else {
			NSString *subnodeResult = [(MTDXMLElement *)object contentStringByUnifyingSubnodes];
			
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

- (MTDXMLElement *)firstChildNodeWithName:(NSString *)name {
    __block MTDXMLElement *foundNode = nil;
    
    [self.content enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MTDXMLElement class]] && [[obj name] isEqualToString:name]) {
            foundNode = (MTDXMLElement *)obj;
            *stop = YES;
        }
    }];

    return foundNode;
}

- (NSArray *)childNodesWithName:(NSString *)name {
    return [self.content filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, __unused NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[MTDXMLElement class]] && [[evaluatedObject name] isEqualToString:name];
    }]];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

+ (MTDXMLElement *)nodeFromLibXMLNode:(xmlNodePtr)libXMLNode parentNode:(MTDXMLElement *)parentNode {
	MTDXMLElement *node = [[MTDXMLElement alloc] init];
	
	if (libXMLNode->name) {
		node.name = [NSString stringWithCString:(const char *)libXMLNode->name encoding:NSUTF8StringEncoding];
	}
	
	if (libXMLNode->content && libXMLNode->type != XML_DOCUMENT_TYPE_NODE) {
		NSString *contentString = [NSString stringWithCString:(const char *)libXMLNode->content encoding:NSUTF8StringEncoding];
		
		if (parentNode && (libXMLNode->type == XML_CDATA_SECTION_NODE || libXMLNode->type == XML_TEXT_NODE)) {
			if (libXMLNode->type == XML_TEXT_NODE) {
				contentString = [contentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			}
			
			if (!parentNode.content) {
				parentNode->_content = [NSMutableArray arrayWithObject:contentString];
			} else {
				[parentNode->_content addObject:contentString];
			}
            
			return nil;
		}
	}
	
	xmlAttr *attribute = libXMLNode->properties;
	
    if (attribute) {
		while (attribute) {
			NSString *attributeName = nil;
			NSString *attributeValue = nil;
			
			if (attribute->name && attribute->children && attribute->children->type == XML_TEXT_NODE && attribute->children->content) {
				attributeName = [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
				attributeValue = [NSString stringWithCString:(const char *)attribute->children->content encoding:NSUTF8StringEncoding];
				
				if (attributeName && attributeValue) {
					if (!node.attributes) {
						node->_attributes = [NSMutableDictionary dictionaryWithObject:attributeValue forKey:attributeName];
					} else {
						[node->_attributes setObject:attributeValue forKey:attributeName];
					}
				}
			}
			
			attribute = attribute->next;
		}
	}
    
	xmlNodePtr childLibXMLNode = libXMLNode->children;
	
    if (childLibXMLNode) {
		while (childLibXMLNode) {
			MTDXMLElement *childNode = [MTDXMLElement nodeFromLibXMLNode:childLibXMLNode parentNode:node];
			
            if (childNode) {
				if (!node.content) {
					node->_content = [NSMutableArray arrayWithObject:childNode];
				} else {
					[node->_content addObject:childNode];
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
    
    xpathCtx = xmlXPathNewContext(doc);
    
    if(xpathCtx == NULL) {
		return nil;
    }
    
    xpathObj = xmlXPathEvalExpression((xmlChar *)[query cStringUsingEncoding:NSUTF8StringEncoding], xpathCtx);
    
    if(xpathObj == NULL) {
		return nil;
    }
	
	xmlNodeSetPtr nodes = xpathObj->nodesetval;
	
    if (!nodes) {
		return nil;
	}
	
	NSMutableArray *resultNodes = [NSMutableArray array];
	
    for (NSInteger i = 0; i < nodes->nodeNr; i++) {
		MTDXMLElement *node = [MTDXMLElement nodeFromLibXMLNode:nodes->nodeTab[i] parentNode:nil];
		
        if (node) {
			[resultNodes addObject:node];
		}
	}
    
    xmlXPathFreeObject(xpathObj);
    xmlXPathFreeContext(xpathCtx); 
    
    return resultNodes;
}

@end

