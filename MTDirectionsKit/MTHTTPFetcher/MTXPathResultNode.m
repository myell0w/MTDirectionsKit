#import "MTXPathResultNode.h"

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

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

- (MTXPathResultNode *)firstChildNodeWithName:(NSString *)aName {
    NSArray *foundNodes = [self.childNodes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [[evaluatedObject name] isEqualToString:aName];
    }]];
    
    if (foundNodes.count > 0) {
        return [foundNodes objectAtIndex:0];
    }
    
    return nil;
                           
}

@end

