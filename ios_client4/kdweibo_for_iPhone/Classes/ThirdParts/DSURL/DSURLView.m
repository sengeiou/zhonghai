//
//  DSURLView.m
//  urltextview
//
//  Created by duansong on 10-10-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSURLView.h"
#import "DSStyleString.h"

#define LineBreakMode	NSLineBreakByCharWrapping


@implementation DSURLView

@synthesize sourceText			= _sourceText;
@synthesize frameWidth			= _frameWidth;
@synthesize frameOriginX		= _frameOriginX;
@synthesize frameOriginY		= _frameOriginY;
@synthesize delegate			= _delegate;
@synthesize FontSize;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
    }
    return self;
}

#pragma mark -
#pragma mark custom methods
- (NSMutableArray *)splitStringByUrl:(NSString *)source
{
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];// autorelease];
    NSInteger index = 0;
	while (index < source.length) 
    {
		NSRange searchRange = NSMakeRange(index, source.length - index);
		NSRange startRange = [source rangeOfString:@"http://" options:NSCaseInsensitiveSearch range:searchRange];
		if (startRange.location == NSNotFound) 
        {
			DSStyleString *currentElement = [[DSStyleString alloc] init];
			currentElement.isUrl = NO;
			currentElement.string = [source substringWithRange:searchRange];
			[elementsArray addObject:currentElement];
//			[currentElement release];
			break;
		}
        else 
        {
			NSRange beforeRange = NSMakeRange(searchRange.location, startRange.location - searchRange.location);
			if (beforeRange.length)
            {
                DSStyleString *beforeElement = [[DSStyleString alloc] init];//autorelease];
				beforeElement.isUrl = NO;
				beforeElement.string = [source substringWithRange:beforeRange];
				[elementsArray addObject:beforeElement];
			}
			
			NSRange searchRange = NSMakeRange(startRange.location, source.length - startRange.location);
			NSRange endRange = [source rangeOfString:@" " options:NSCaseInsensitiveSearch range:searchRange];
			if (endRange.location == NSNotFound) {
                DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
				urlElement.isUrl = YES;
				urlElement.string = [source substringWithRange:searchRange];
				[elementsArray addObject:urlElement];
				break;
			}
            else
            {
				NSRange urlRange = NSMakeRange(startRange.location, endRange.location - startRange.location);
                DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
				urlElement.isUrl = YES;
				urlElement.string = [source substringWithRange:urlRange];
				[elementsArray addObject:urlElement];
				index = endRange.location;
			}
		}
	}
	
	//[source release];
	return elementsArray;
}


- (NSMutableArray *)splitStringByAll:(NSString *)source
{	
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];// autorelease];
    NSString *string = source;
    
    NSError *error = NULL;
    //        matchesInString:options:range:
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http://([\\w-]+\\.)+[\\w-]+(/[a-z,A-Z,0-9,_./?%]*)?"    
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray *matchs = [regex matchesInString:string
                                                    options:NSMatchingReportCompletion
                                                      range:NSMakeRange(0, [string length])];
    
    //没有url的情况下
    if ([matchs count] == 0||matchs == nil) {
        DSStyleString *currentElement = [[DSStyleString alloc] init];//autorelease];
        currentElement.isUrl = NO;
        currentElement.string = [NSString stringWithString:source];
        
        [elementsArray addObject:currentElement];            
    }
    else 
    {
        //游标
        NSInteger newStartIndex = 0;
        for (int i = 0; i<[matchs count];i++)
        {

            NSTextCheckingResult *match = [matchs objectAtIndex:i];
            NSRange matchRange = [match range];

            NSRange notMatchRange = NSMakeRange(newStartIndex, matchRange.location-newStartIndex);
            //>
            DSStyleString *nomalTextElement = [[DSStyleString alloc] init];//autorelease];
            nomalTextElement.isUrl = NO;
            nomalTextElement.string = [source substringWithRange:notMatchRange];
            
            [elementsArray addObject:nomalTextElement];     
            //<
            //>
            DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
            urlElement.isUrl = YES;
            urlElement.style=URL;
            
            urlElement.string = [source substringWithRange:matchRange];
            urlElement.url=urlElement.string ;
            [elementsArray addObject:urlElement];
            //<
            newStartIndex = matchRange.location + matchRange.length;

        }
        NSRange notMatchRangeEnd = NSMakeRange(newStartIndex, [source length]-newStartIndex);
        DSStyleString *nomalTextEnd = [[DSStyleString alloc] init];//autorelease];
        nomalTextEnd.isUrl = NO;
        nomalTextEnd.string = [source substringWithRange:notMatchRangeEnd];
        
        [elementsArray addObject:nomalTextEnd]; 
        
    }
    return [self splitElementArraybyUser:elementsArray];

}

//
//#if 0
//- (NSMutableArray *)splitStringByAll:(NSString *)source
//{
//	//[source retain];
//	
//	NSMutableArray *elementsArray = [[[NSMutableArray alloc] init] autorelease];
//	NSInteger index = 0;
//	while (index < source.length) 
//    {
//		NSRange searchRange = NSMakeRange(index, source.length - index);
//		NSRange startRange = [source rangeOfString:@"http://" options:NSCaseInsensitiveSearch range:searchRange];
//		if (startRange.location == NSNotFound) 
//        {
//            DSStyleString *currentElement = [[[DSStyleString alloc] init]autorelease];
//            currentElement.isUrl = NO;
//            currentElement.string = [source substringWithRange:searchRange];
//            
//            [elementsArray addObject:currentElement];            
//            break;           
//		}
//        else 
//        {
//            //http：查找
//			NSRange beforeRange = NSMakeRange(searchRange.location, startRange.location - searchRange.location);
//			if (beforeRange.length) 
//            {
//				DSStyleString *beforeElement = [[[DSStyleString alloc] init]autorelease];
//				beforeElement.isUrl = NO;
//				beforeElement.string = [source substringWithRange:beforeRange];
//				[elementsArray addObject:beforeElement];
//			}
//            
//            //>
////            NSRange searchRange = NSMakeRange(startRange.location, source.length - startRange.location);
//            NSString *string = [source substringWithRange:searchRange];
//            
//            NSError *error = NULL;
//            //        matchesInString:options:range:
//            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http://([\\w-]+\\.)+[\\w-]+(/[a-z,A-Z,0-9,_./?%]*)?"    
//                                                                                   options:NSRegularExpressionCaseInsensitive
//                                                                                     error:&error];
//            
//            NSTextCheckingResult *match = [regex firstMatchInString:string
//                                                            options:NSMatchingReportCompletion
//                                                              range:NSMakeRange(0, [string length])];
//            
//            if (match) {
//                NSRange matchRange = [match range];
//                DSStyleString *urlElement = [[[DSStyleString alloc] init]autorelease];
//				urlElement.isUrl = YES;
//                urlElement.style=URL;
//                
//				urlElement.string = [string substringWithRange:searchRange];
//                urlElement.url=urlElement.string ;
//				[elementsArray addObject:urlElement];
//                index = index+matchRange.location +matchRange.length;
//
//            }
////            NSString *subString = [string substringWithRange:range];
////            NSLog(@"subString : %@",subString);
//
//            //<
//#if 0
//			NSRange searchRange = NSMakeRange(startRange.location, source.length - startRange.location);
//			NSRange endRange = [source rangeOfString:@" " options:NSCaseInsensitiveSearch range:searchRange];
//			if (endRange.location == NSNotFound) 
//            {
//				DSStyleString *urlElement = [[[DSStyleString alloc] init]autorelease];
//				urlElement.isUrl = YES;
//                urlElement.style=URL;
//                
//				urlElement.string = [source substringWithRange:searchRange];
//                urlElement.url=urlElement.string ;
//				[elementsArray addObject:urlElement];
//				break;
//			}
//            else
//            {
//				NSRange urlRange = NSMakeRange(startRange.location, endRange.location - startRange.location);
//				DSStyleString *urlElement = [[[DSStyleString alloc] init]autorelease];
//				urlElement.isUrl = YES;
//				urlElement.string = [source substringWithRange:urlRange];
//                urlElement.url=urlElement.string ;
//				[elementsArray addObject:urlElement];
//				index = endRange.location;
//			}
//#endif
//		}
//	}
//	
//	return [self splitElementArraybyUser:elementsArray];
//	
//}
//#endif

//解析第3遍，对话题解析
- (NSMutableArray *)splitElementArraybyTopic:(NSMutableArray *)array
{
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];// autorelease];
    for(DSStyleString *styleString in array)
    {
        if(styleString.isUrl==YES)
        {
            [elementsArray addObject:styleString];
        }
      
       else
       {
       NSString *source=styleString.string;
        
        NSError *error = NULL;
        //        matchesInString:options:range:
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\#([^\\#]+)\\#"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        NSArray *matchs = [regex matchesInString:source
                                         options:NSMatchingReportCompletion
                                           range:NSMakeRange(0, [source length])];
        
  
        if ([matchs count] == 0||matchs == nil) {
            DSStyleString *currentElement = [[DSStyleString alloc] init];//autorelease];
            currentElement.isUrl = NO;
            currentElement.string = [NSString stringWithString:source];
            
            [elementsArray addObject:currentElement];
        }
        else
        {
            //游标
            NSInteger newStartIndex = 0;
            for (int i = 0; i<[matchs count];i++)
            {
                
                NSTextCheckingResult *match = [matchs objectAtIndex:i];
                NSRange matchRange = [match range];
                if (matchRange.location >0) {
                    NSRange notMatchRange = NSMakeRange(newStartIndex, matchRange.location-newStartIndex);
                    //>
                    DSStyleString *nomalTextElement = [[DSStyleString alloc] init];//autorelease];
                    nomalTextElement.isUrl = NO;
                    nomalTextElement.string = [source substringWithRange:notMatchRange];
                    
                    [elementsArray addObject:nomalTextElement];
                }
               
                //<
                //>
                DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
                urlElement.isUrl = YES;
                urlElement.style=TOPIC;
               // NSRange urlRang = NSMakeRange(matchRange.location+1, matchRange.length - 2);
                urlElement.string = [source substringWithRange:matchRange];
                urlElement.url=urlElement.string ;
                [elementsArray addObject:urlElement];
                //<
                newStartIndex = matchRange.location + matchRange.length;
                
            }
            NSRange notMatchRangeEnd = NSMakeRange(newStartIndex, [source length]-newStartIndex);
            DSStyleString *nomalTextEnd = [[DSStyleString alloc] init];//autorelease];
            nomalTextEnd.isUrl = NO;
            nomalTextEnd.string = [source substringWithRange:notMatchRangeEnd];
            
            [elementsArray addObject:nomalTextEnd]; 
            
        }
       }
     
    }
    return [self splitElementArraybyNewLine:elementsArray];
}  

- (NSMutableArray *)splitElementArraybyNewLine:(NSMutableArray *)array {
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];// autorelease];
    for(DSStyleString *styleString in array)
    {
        if(styleString.isUrl==YES)
        {
            [elementsArray addObject:styleString];
        }
        
        else
        {
            NSString *source=styleString.string;
            
            NSError *error = NULL;
            //        matchesInString:options:range:
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([ ]*)\n"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            
            NSArray *matchs = [regex matchesInString:source
                                             options:NSMatchingReportCompletion
                                               range:NSMakeRange(0, [source length])];
            
            
            if ([matchs count] == 0||matchs == nil) {
                DSStyleString *currentElement = [[DSStyleString alloc] init];//autorelease];
                currentElement.isUrl = NO;
                currentElement.string = [NSString stringWithString:source];
                
                [elementsArray addObject:currentElement];
            }
            else
            {
                //游标
                NSInteger newStartIndex = 0;
                for (int i = 0; i<[matchs count];i++)
                {
                    
                    NSTextCheckingResult *match = [matchs objectAtIndex:i];
                    NSRange matchRange = [match range];
                    if (matchRange.location >0) {
                        NSRange notMatchRange = NSMakeRange(newStartIndex, matchRange.location-newStartIndex);
                        //>
                        DSStyleString *nomalTextElement = [[DSStyleString alloc] init];//autorelease];
                        nomalTextElement.isUrl = NO;
                        nomalTextElement.string = [source substringWithRange:notMatchRange];
                        
                        [elementsArray addObject:nomalTextElement];
                    }
                    
                    //<
                    //>
                    DSStyleString *urlElement = [[DSStyleString alloc] init];//a;//utorelease];
                    urlElement.isUrl = NO;
                    urlElement.style= NEW_LINE;
                    // NSRange urlRang = NSMakeRange(matchRange.location+1, matchRange.length - 2);
                    urlElement.string = @"\n";
                    //urlElement.url=urlElement.string ;
                    [elementsArray addObject:urlElement];
                    //<
                    newStartIndex = matchRange.location + matchRange.length;
                    
                }
                NSRange notMatchRangeEnd = NSMakeRange(newStartIndex, [source length]-newStartIndex);
                DSStyleString *nomalTextEnd = [[DSStyleString alloc] init];//autorelease];
                nomalTextEnd.isUrl = NO;
                nomalTextEnd.string = [source substringWithRange:notMatchRangeEnd];
                
                [elementsArray addObject:nomalTextEnd]; 
                
            }
        }
        
    }
    return elementsArray;

    
    
    
}
- (void) addUserElement: (NSRange) urlRange source: (NSString *) source elementsArray: (NSMutableArray *) elementsArray
{

    NSString *userString=[source substringWithRange:urlRange];
    NSString *userName = [userString substringFromIndex:1];
    
    
    DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
    urlElement.isUrl = YES;
    urlElement.style = USER;
    urlElement.url = userName;
    urlElement.string = [source substringWithRange:urlRange];
    [elementsArray addObject:urlElement];
}
//解析第2遍，对用户解析

#pragma mark - 
#pragma mark splitElementArraybyUser

-(BOOL)isRangeLocationFound:(NSRange)range
{
    if (range.location == NSNotFound) {
        return NO;
    }
return YES;
}


- (NSMutableArray *)splitElementArraybyUser:(NSMutableArray *)array
{
    NSMutableArray *elementsArray = [[NSMutableArray alloc] init];// autorelease];
    for(DSStyleString *styleString in array)
    {
        if(styleString.isUrl==YES)
        {
            [elementsArray addObject:styleString];
        }
        else
        {
            NSInteger index = 0;
            NSString *source=styleString.string;
            while (index < source.length) 
            {
                NSRange searchRange = NSMakeRange(index, source.length - index);
                NSRange startRange = [source rangeOfString:@"@" options:NSCaseInsensitiveSearch range:searchRange];
                if (startRange.location == NSNotFound)
                {
                    DSStyleString *currentElement = [[DSStyleString alloc] init];//autorelease];
                    currentElement.isUrl = NO;
                    currentElement.string = [source substringWithRange:searchRange];
                    [elementsArray addObject:currentElement];
                    
                    break;
                }
                else
                {
                    NSRange beforeRange = NSMakeRange(searchRange.location, startRange.location - searchRange.location);
                    if (beforeRange.length) 
                    {
                        DSStyleString *beforeElement = [[DSStyleString alloc] init];//autorelease];
                        beforeElement.isUrl = NO;
                        beforeElement.string = [source substringWithRange:beforeRange];
                        [elementsArray addObject:beforeElement];
                    }
                    
                    NSRange searchRange = NSMakeRange(startRange.location, source.length - startRange.location);
                    NSRange endRangeBlank = [source rangeOfString:@" " options:NSCaseInsensitiveSearch range:searchRange];
                    NSRange endRangeColon = [source rangeOfString:@":" options:NSCaseInsensitiveSearch range:searchRange];
                    NSRange endRangReturn = [source rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:searchRange];
                                        
                    if (endRangeBlank.location == NSNotFound &&
                        endRangeColon.location == NSNotFound &&
                        endRangReturn.location == NSNotFound) {
                        [self addUserElement: searchRange source: source elementsArray: elementsArray];
                        break;
                    }
               
                    if (endRangeBlank.location == NSNotFound && endRangReturn.location == NSNotFound) 
                    {
                        if (endRangeColon.location == NSNotFound)
                        {
                            if ([elementsArray count]==0) 
                            {
                                DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
                                urlElement.isUrl = NO;
                                urlElement.string = [source substringWithRange:searchRange];
                                [elementsArray addObject:urlElement];
                                break;
                            }
                            DSStyleString *urlElement = [elementsArray objectAtIndex:[elementsArray count]-1];
                            urlElement.string = [NSString stringWithFormat:@"%@%@",urlElement.string,[source substringWithRange:searchRange]];
                            break;
                        }
                        else
                        {
                            NSRange urlRange = NSMakeRange(startRange.location, endRangeColon.location - startRange.location);
                            [self addUserElement: urlRange source: source elementsArray: elementsArray];
                            index = endRangeColon.location;
                            
                        }
                    }
                    else 
                    {
                        //detect the end chart is " " or "\n"
                        NSRange tempEndRange;
                        
                        if ([self isRangeLocationFound:endRangReturn] && [self isRangeLocationFound:endRangeBlank]) {
                            tempEndRange = (endRangeBlank.location < endRangReturn.location) ?  endRangeBlank : endRangReturn;
                        }
                        else if([self isRangeLocationFound:endRangeBlank]) {
                            tempEndRange = endRangeBlank;

                        }
                        else {
                            tempEndRange = endRangReturn;
                            
                        }

                        
                        if (endRangeColon.location == NSNotFound)
                        {
                            
                            NSRange urlRange = NSMakeRange(startRange.location, tempEndRange.location - startRange.location);
                            [self addUserElement: urlRange source: source elementsArray: elementsArray];
                            index = tempEndRange.location;
                        }//分号和空格都有的情况
                        else {
                            NSRange urlRange = NSMakeRange(startRange.location, [self min:tempEndRange.location number2:endRangeColon.location] - startRange.location);
                            [self addUserElement: urlRange source: source elementsArray: elementsArray];
                            index = [self min:tempEndRange.location number2:endRangeColon.location];
                        }
                        
                    }
                }
            }

            
        }
    }
    return [self splitElementArraybyTopic:elementsArray];    
}


-(NSMutableArray *)splitStringByName:(NSString *)source{
	//[source retain];
	
	NSMutableArray *elementsArray = [[NSMutableArray alloc] init];//autorelease];
	NSInteger index = 0;
	while (index < source.length) 
    {
		NSRange searchRange = NSMakeRange(index, source.length - index);
		NSRange startRange = [source rangeOfString:@"@" options:NSCaseInsensitiveSearch range:searchRange];
		if (startRange.location == NSNotFound)
        {
			DSStyleString *currentElement = [[DSStyleString alloc] init];//autorelease];
			currentElement.isUrl = NO;
			currentElement.string = [source substringWithRange:searchRange];
			[elementsArray addObject:currentElement];
			
			break;
		}else
        {
			NSRange beforeRange = NSMakeRange(searchRange.location, startRange.location - searchRange.location);
			if (beforeRange.length) 
            {
				DSStyleString *beforeElement = [[DSStyleString alloc] init];//autorelease];
				beforeElement.isUrl = NO;
				beforeElement.string = [source substringWithRange:beforeRange];
				[elementsArray addObject:beforeElement];
			}
			
			NSRange searchRange = NSMakeRange(startRange.location, source.length - startRange.location);
			NSRange endRange = [source rangeOfString:@" " options:NSCaseInsensitiveSearch range:searchRange];
			NSRange endRange2 = [source rangeOfString:@":" options:NSCaseInsensitiveSearch range:searchRange];
			if (endRange.location == NSNotFound) 
			{
				if (endRange2.location == NSNotFound)
				{
                    if ([elementsArray count]==0) 
                    {
                        DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
                        urlElement.isUrl = NO;
                        urlElement.string = [source substringWithRange:searchRange];
                        [elementsArray addObject:urlElement];
                        break;
                    }
                    DSStyleString *urlElement = [elementsArray objectAtIndex:[elementsArray count]-1];
                    urlElement.string = [NSString stringWithFormat:@"%@%@", urlElement.string, [source substringWithRange:searchRange]];
					break;
				}
				else
				{
					NSRange urlRange = NSMakeRange(startRange.location, endRange2.location - startRange.location);
					DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
					urlElement.isUrl = YES;
					urlElement.string = [source substringWithRange:urlRange];
					[elementsArray addObject:urlElement];
					index = endRange2.location;
					
				}
			}
			else 
			{
				if (endRange2.location == NSNotFound)
				{
					
					NSRange urlRange = NSMakeRange(startRange.location, endRange.location - startRange.location);
					DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
					urlElement.isUrl = YES;
					urlElement.string = [source substringWithRange:urlRange];
					[elementsArray addObject:urlElement];
					index = endRange.location;
				}//分号和空格都有的情况
				else {
					NSRange urlRange = NSMakeRange(startRange.location, [self min:endRange.location number2:endRange2.location] - startRange.location);
					DSStyleString *urlElement = [[DSStyleString alloc] init];//autorelease];
					urlElement.isUrl = YES;
					urlElement.string = [source substringWithRange:urlRange];
					[elementsArray addObject:urlElement];
					index = [self min:endRange.location number2:endRange2.location];
				}

			}
		}
	}	
	return elementsArray;
}

-(NSUInteger) min:(NSUInteger)location1 number2:(NSUInteger)location2
{
	if(location1<location2)
		return location1;
	else
		return location2;
}




- (void)layoutURLViewWithElements:(NSMutableArray *)elements 
{
	//[elements retain];
    for(UIView *childView in self.subviews)
    {
        [childView removeFromSuperview];
    }
	NSInteger count = [elements count];
	if (count == 0) return;
	BOOL haveHttp = NO;
	for (DSStyleString *styleString in elements)
    {
		if (styleString.isUrl == YES) 
        {
			haveHttp = YES;
			break;
		}
	}
	
	if (haveHttp == YES)
    {
		for (int i = 0; i < count; i ++) 
        {
			DSStyleString *styleString = (DSStyleString *)[elements objectAtIndex:i];
			NSArray *existSubViews = [self subviews];
			if ([existSubViews count] > 0) 
            {
				UIView *lastSubView = [existSubViews lastObject];
				NSString *forwardSourceString = nil;
				NSString *lastLineStringOfForwardSourceString = nil;
				//NSInteger lastLineStringWidthOfForwardSourceString = 0;
				NSInteger leaveWidth = 0;
				CGFloat originX = 0;
				CGFloat originY = 0;
				CGFloat width = 0;
				CGFloat height = 0;
				CGFloat characterHeight = [self getHeightWithFontSize:FontSize];
				
				if ([[lastSubView class] isSubclassOfClass:[UILabel class]]) 
                {
					forwardSourceString = [(UILabel *)lastSubView text];
				}
                else if ([[lastSubView class] isSubclassOfClass:[DSURLLabel class]])
                {
					forwardSourceString = [[(DSURLLabel *)lastSubView urlLabel] text];
				}	
				CGSize forwardSourceStringSize = CGSizeZero;
                CGSize lastLineStringOfForwardSourceStringSize = CGSizeZero;
                
                if (forwardSourceString !=nil && forwardSourceString.length>0) { //字符串不为空
                   forwardSourceStringSize = [self sizeForString:forwardSourceString];
                    lastLineStringOfForwardSourceString = [forwardSourceString substringFromIndex:[self findStartIndexOfLastLineText:forwardSourceString]];
                   lastLineStringOfForwardSourceStringSize = [self sizeForString:lastLineStringOfForwardSourceString];
                    
                    if (forwardSourceStringSize.height > characterHeight)
                    {
                        leaveWidth = _frameWidth - lastLineStringOfForwardSourceStringSize.width;
                    }
                    else
                    {
                        leaveWidth = _frameWidth - lastSubView.frame.origin.x - lastSubView.frame.size.width;
                    }

                } else {
                    forwardSourceStringSize = lastSubView.frame.size;
                    lastLineStringOfForwardSourceStringSize = forwardSourceStringSize;
                    leaveWidth = 0;
                }
				                
                
                if (styleString.style == NEW_LINE) {
                    
                    if (leaveWidth>0) {
                        originX = lastSubView.frame.origin.x + lastLineStringOfForwardSourceStringSize.width;
                        originY = lastSubView.frame.origin.y + lastSubView.frame.size.height - characterHeight;
                        width = _frameWidth - leaveWidth;
                        height = characterHeight;
                        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                        textLabel.numberOfLines = 1;
                        textLabel.font = [UIFont systemFontOfSize:FontSize];
                        textLabel.backgroundColor = [UIColor clearColor];
                        [self addSubview:textLabel];
                        //;//[textLabel release];
                    }else {
                        originX = lastSubView.frame.origin.x;
                        originY = lastSubView.frame.origin.y + lastSubView.frame.size.height;
                        width = _frameWidth;
                        height = characterHeight;
                        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                        textLabel.numberOfLines = 1;
                        textLabel.font = [UIFont systemFontOfSize:FontSize];
                        textLabel.backgroundColor = [UIColor clearColor];
                        [self addSubview:textLabel];
//                        [textLabel release];
                        
                    }
                    //
                }
                else {
                    NSMutableArray *splitedSubStringByLimitWidthArray = [[NSMutableArray alloc] init];
                    [splitedSubStringByLimitWidthArray addObjectsFromArray:[self splitStringBylimitWidth:leaveWidth source:styleString.string]];
                    
                    if ([splitedSubStringByLimitWidthArray count] == 1)
                    {
                        if (_needNewLine)
                        {
                            originX = 0;
                            originY = lastSubView.frame.origin.y + lastSubView.frame.size.height;
                        }
                        else
                        {
                            if (forwardSourceStringSize.height > characterHeight)
                            {
                                originX = lastLineStringOfForwardSourceStringSize.width;
                            }
                            else
                            {
                                originX = lastSubView.frame.origin.x + lastSubView.frame.size.width;
                            }
                            originY = lastSubView.frame.origin.y + lastSubView.frame.size.height - characterHeight;
                        }
                        
                        CGSize newLabelSize = [self sizeForString:styleString.string];
                        width = newLabelSize.width;
                        height = newLabelSize.height;
                        
                        if (styleString.isUrl == YES)
                        {
                            DSURLLabel *urlLabel = [[DSURLLabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                            urlLabel.backgroundColor = [UIColor clearColor];
                            urlLabel.urlString=styleString.url;
                            
                            urlLabel.style=styleString.style;
                            urlLabel.urlLabel.text = styleString.string;
                            urlLabel.urlLabel.numberOfLines = 0;
                            urlLabel.urlLabel.lineBreakMode = LineBreakMode;
                            urlLabel.urlLabel.font = [UIFont systemFontOfSize:FontSize];
                            urlLabel.delegate = self;
                            [self addSubview:urlLabel];
//                            [urlLabel release];
                        }
                        else
                        {
                            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                            textLabel.numberOfLines = 0;
                            textLabel.lineBreakMode = LineBreakMode;
                            textLabel.font = [UIFont systemFontOfSize:FontSize];
                            textLabel.backgroundColor = [UIColor clearColor];
                            textLabel.text = styleString.string;
                            [self addSubview:textLabel];
//                            [textLabel release];
                        }
                        
                    }
                    else if ([splitedSubStringByLimitWidthArray count] == 2)
                    {
                        for(int i = 0; i < 2; i++)
                        {
                            NSString *currentSubString = [splitedSubStringByLimitWidthArray objectAtIndex:i];
                            CGSize newLabelSize = [self sizeForString:currentSubString];
                            if (i == 0)
                            {
                                if (forwardSourceStringSize.height > characterHeight)
                                {
                                    originX = lastLineStringOfForwardSourceStringSize.width;
                                }
                                else
                                {
                                    originX = lastSubView.frame.origin.x + lastSubView.frame.size.width;
                                }
                                originY = lastSubView.frame.origin.y + lastSubView.frame.size.height - characterHeight;
                                width = _frameWidth - originX;
                            }else if (i == 1)
                            {
                                originX = 0;
                                originY = lastSubView.frame.origin.y + lastSubView.frame.size.height;
                                width = newLabelSize.width;
                                
                            }
                            height = newLabelSize.height;
                            
                            
                            if (styleString.isUrl == YES)
                            {
                                DSURLLabel *urlLabel = [[DSURLLabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                                urlLabel.backgroundColor = [UIColor clearColor];
                                urlLabel.urlString=styleString.url;
                                urlLabel.style=styleString.style;
                                urlLabel.urlLabel.text = currentSubString;
                                urlLabel.urlLabel.font = [UIFont systemFontOfSize:FontSize];
                                urlLabel.urlLabel.lineBreakMode = LineBreakMode;
                                if (i == 0) 
                                {
                                    urlLabel.urlLabel.numberOfLines = 1;
                                }
                                else if (i == 1)
                                {
                                    urlLabel.urlLabel.numberOfLines = 0;
                                }
                                urlLabel.delegate = self;
                                [self addSubview:urlLabel];
//                                [urlLabel release];
                            }
                            else 
                            {
                                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
                                textLabel.backgroundColor =[UIColor clearColor];
                                textLabel.font = [UIFont systemFontOfSize:FontSize];
                                textLabel.lineBreakMode = LineBreakMode;
                                if (i == 0)
                                {
                                    textLabel.numberOfLines = 1;
                                }
                                else if (i == 1)
                                {
                                    textLabel.numberOfLines = 0;
                                }
                                textLabel.text = currentSubString;
                                [self addSubview:textLabel];
//                                [textLabel release];
                            }
                        }
                    }
                    
//                    [splitedSubStringByLimitWidthArray release];

                    
                }
                    
                    
				
								
			}else { ////////
				CGSize newLabelSize = [self sizeForString:styleString.string];
				if (styleString.isUrl == YES)
                {
					DSURLLabel *urlLabel = [[DSURLLabel alloc] initWithFrame:CGRectMake(0, 0, newLabelSize.width, newLabelSize.height)];
					urlLabel.backgroundColor = [UIColor clearColor];
					urlLabel.urlLabel.font = [UIFont systemFontOfSize:FontSize];
					urlLabel.urlLabel.numberOfLines = 0;
                     urlLabel.style=styleString.style;
					urlLabel.urlLabel.lineBreakMode = LineBreakMode;
					urlLabel.urlString=styleString.url;
					urlLabel.urlLabel.text = styleString.string;
					urlLabel.delegate = self;
					[self addSubview:urlLabel];
//					[urlLabel release];
                    
				}
                else 
                {
					UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, newLabelSize.width, newLabelSize.height)];
					label.backgroundColor = [UIColor clearColor];
					label.text = styleString.string;
					label.font = [UIFont systemFontOfSize:FontSize];
					label.numberOfLines = 0;
					label.lineBreakMode = LineBreakMode;
					[self addSubview:label];
//					[label release];
				}
			}
		}
	}
    else 
    {
		//DSStyleString *styleString = [elements objectAtIndex:0];
		CGSize textSize = [self sizeForString:_sourceText];
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
		textLabel.numberOfLines = 0;
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.lineBreakMode = LineBreakMode;
		textLabel.text = _sourceText;
		textLabel.font = [UIFont systemFontOfSize:FontSize];
		[self addSubview:textLabel];
//		[textLabel release];
	}
	[self setFrame];
	//[elements release];
}

- (void)setFrame {
	UIView *lastSubView = (UIView *)[[self subviews] lastObject];
	CGFloat heigh = lastSubView.frame.origin.y + lastSubView.frame.size.height;
	self.frame = CGRectMake(_frameOriginX, _frameOriginY , _frameWidth, heigh);
}

- (NSInteger)findStartIndexOfLastLineText:(NSString *)source {
//	[source retain];
	CGSize sourceTextSize = [self sizeForString:source];
	NSInteger lines = sourceTextSize.height / [self getHeightWithFontSize:FontSize];
	NSInteger startIndex = 0;
	if (lines > 1) {
		NSInteger length = [source length];
		for (int i = (int)length; i > 0; i --) {
			CGSize textSize = [self sizeForString:[source substringToIndex:i]];
			if (textSize.height < sourceTextSize.height) {
				startIndex = i;
				break;
			}
		}
	}
//	[source release];
	return startIndex;
}

- (NSMutableArray *)splitStringBylimitWidth:(CGFloat)width source:(NSString *)source {
//	[source retain];
    NSMutableArray *subStrings = [[NSMutableArray alloc] init];// autorelease];
	NSInteger length = [source length];
	for (int i = (int)length; i > 0; i--) {
		CGSize textSize = [self sizeForString:[source substringToIndex:i]];
		if (textSize.width <= width && i == length) {
			[subStrings addObject:source];
			_needNewLine = NO;
			break;
		}
		if ((textSize.width < width) && (textSize.height == [self getHeightWithFontSize:FontSize])) {
			[subStrings addObject:[source substringToIndex:i]];
			[subStrings addObject:[source substringFromIndex:i]];
			break;
		}
		if (i == 1) {
			[subStrings addObject:source];
			_needNewLine = YES;
			break;
		}
	}
//	[source release];
	return subStrings;
}

- (CGSize)sizeForString:(NSString *)string {
	CGSize textSize = [string sizeWithFont:[UIFont systemFontOfSize:FontSize] constrainedToSize:CGSizeMake(_frameWidth, 10000.0f) lineBreakMode:LineBreakMode];
    /*CGRect bounds = CGRectMake(0, 0, _frameWidth, 10000.0f);
    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
    }
	
    label.font = [UIFont systemFontOfSize:FontSize];
    label.text=string;
   CGRect textSize = [label textRectForBounds:bounds limitedToNumberOfLines:40];   

	return textSize.size;*/
    return textSize;
}

- (CGFloat)getHeightWithFontSize:(CGFloat)fontSize {
	NSString *character = @" ";
	CGSize characterSize = [self sizeForString:character];
	return characterSize.height;
}

- (void)setUrlLabelTextColorWithUrlString:(NSString *)url color:(UIColor *)color 
{
	NSArray *subViews = [self subviews];
	for (UIView *subView in subViews) {
		if ([[subView class] isSubclassOfClass:[DSURLLabel class]]) {
			if (((DSURLLabel *)subView).urlString == url) {
				((DSURLLabel *)subView).urlLabel.textColor = color;
			}
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(viewTouchesBegan:)])
        [_delegate viewTouchesBegan:self];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(viewTouchesMove:)])
        [_delegate viewTouchesMove:self];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(viewTouchesEnded:)])
        [_delegate viewTouchesEnded:self];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(viewTouchesCancle:)])
        [_delegate viewTouchesCancle:self];
}

#pragma mark -
#pragma mark DSURLLabelDelegate methods
- (void)urlTouchesCancle:(DSURLLabel *)urlLabel
{
    [self setUrlLabelTextColorWithUrlString:urlLabel.urlString color: RGBCOLOR(26, 133, 255)];
}
- (void)urlTouchesBegan:(DSURLLabel *)urlLabel {
	[self setUrlLabelTextColorWithUrlString:urlLabel.urlString color:RGBCOLOR(26, 133, 255)];
}

- (void)urlTouchesEnd:(DSURLLabel *)urlLabel 
{
	[self setUrlLabelTextColorWithUrlString:urlLabel.urlString color: RGBCOLOR(26, 133, 255)];
    switch (urlLabel.style) {
        case URL:     
        {
            if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(urlWasClicked:urlString:)]) 
            {
                [_delegate urlWasClicked:self urlString:urlLabel.urlString];
            }
        }
            break;
        case TOPIC:
            if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(topicWasClicked:urlString:)]) 
            {
                [_delegate topicWasClicked:self urlString:urlLabel.urlString];
            }
            break;
        case USER:
            if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(userWasClicked:urlString:)]) 
            {
                [_delegate userWasClicked:self urlString:urlLabel.urlString];
            }
            break;            
        default:
            if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(viewOtherWasClicked)]) 
            {
                [(NSObject *)_delegate performSelector:@selector(viewOtherWasClicked)];
            }
            break;
            
    }
	
}


#pragma mark -
#pragma mark dealloc memory methods

- (void)dealloc {
//	[_sourceText	release];
	_sourceText		= nil;
    //[super dealloc];
}


@end
