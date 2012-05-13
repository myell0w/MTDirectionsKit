//
//  MTDXMLElement.h
//
//  Created by Matthias Tretter on 21.01.12.
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


@interface MTDXMLElement : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSMutableDictionary *attributes;
@property (nonatomic, strong, readonly) NSMutableArray *content;

@property (nonatomic, readonly) NSArray *childNodes;
@property (nonatomic, readonly) NSString *contentString;
@property (nonatomic, readonly) NSString *contentStringByUnifyingSubnodes;

+ (NSArray *)nodesForXPathQuery:(NSString *)query onHTML:(NSData *)htmlData;
+ (NSArray *)nodesForXPathQuery:(NSString *)query onXML:(NSData *)xmlData;

- (MTDXMLElement *)firstChildNodeWithName:(NSString *)name;

@end
