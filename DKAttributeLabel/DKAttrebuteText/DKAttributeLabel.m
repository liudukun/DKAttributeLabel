//
//  DKAttributeLabel.m
//  DDChat
//
//  Created by liudukun on 2018/1/12.
//  Copyright © 2018年 com.ldk. All rights reserved.
//

#import "DKAttributeLabel.h"
#import <CoreText/CoreText.h>


#define DKAttribute_Font_Name @"PingFang SC"

@implementation DKAttributeNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textColor = [UIColor blueColor];
        self.backgroundColor = [UIColor whiteColor];
        
        self.selectedTextColor = [UIColor whiteColor];
        self.selectedBackgroundColor = [UIColor blueColor];
        
        self.font = [UIFont fontWithName:DKAttribute_Font_Name size:14.f];
    }
    return self;
}

- (void)setNilValueForKey:(NSString *)key{
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"t"]) {
        _subType = [value intValue];
    }
    if ([key isEqualToString:@"bc"]) {
        _backgroundColor = [self colorWithHexString:value alpha:1];
    }
    if ([key isEqualToString:@"tc"]) {
        _textColor = [self colorWithHexString:value alpha:1];
    }
    if ([key isEqualToString:@"bsc"]) {
        _selectedBackgroundColor = [self colorWithHexString:value alpha:1];
    }
    if ([key isEqualToString:@"tsc"]) {
        _selectedTextColor = [self colorWithHexString:value alpha:1];
    }
    if ([key isEqualToString:@"ct"]) {
        _content = value;
    }
    if ([key isEqualToString:@"id"]) {
        _contentId = value;
    }
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    
}

- (UIColor *)colorWithHexString:(NSString *)hexColor alpha:(float)opacity{
    NSString * cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString * rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString * gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString * bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:opacity];
}

@end


@interface DKAttributeText (){
    
    
    NSString *regluarLink,*regluarEmotion,*regluarFace;
}

@end


@implementation DKAttributeText


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor grayColor];
        self.font = [UIFont fontWithName:DKAttribute_Font_Name size:14.f];
        self.alignment = NSTextAlignmentNatural;
        regluarFace = @"\\[#f:.*?#\\]";
        regluarLink = @"(https?|ftp|file|http)://[-A-Za-z0-9+&@#/%?=~_|!.]+[-A-Za-z0-9+&@#/%=~_|]";
        regluarEmotion = @"\\[#r:\\{.*?\\}#\\]";
        self.regulars = @[regluarFace,regluarLink,regluarEmotion];
        
    }
    return self;
}

- (void)parseText:(NSString *)orginalText{
    self.orginalText = orginalText;
    
    self.nodes = [NSMutableArray array];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = self.alignment;
    self.attributedString = [[NSMutableAttributedString alloc]initWithString:orginalText attributes:@{NSForegroundColorAttributeName:self.textColor,NSBackgroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:self.font,NSParagraphStyleAttributeName:style}];
    NSInteger offset = 0;
    NSInteger count = 0;
    while (1) {
        NSRange result = [self matchPatternOffset:offset];
        if (!result.length) {
            break;
        }
        NSString *string = self.attributedString.mutableString;
        NSString *match = [string substringWithRange:result];
        NSLog(@"match=%@",match);
        
        DKTextType type = [self typeOfText:match];
        
        if (type == DKTextTypeMotion) {
            NSRange range = [match rangeOfString:@"\\{[^\\}]*\\}" options:NSRegularExpressionSearch];
            if (!range.length) {
                NSLog(@"range is null");
                continue;;
            }
            NSString *jsonString = [match substringWithRange:range];
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                NSLog(@"%@",error);
                continue;
            }
            DKAttributeNode *node = [DKAttributeNode new];
            node.type = DKTextTypeMotion;
            [node setValuesForKeysWithDictionary:dic];
            
            NSAttributedString *replace = [[NSAttributedString alloc]initWithString:node.content attributes:@{NSForegroundColorAttributeName:node.textColor,NSBackgroundColorAttributeName:node.backgroundColor,NSFontAttributeName:node.font,NSParagraphStyleAttributeName:style}];
            [self.attributedString replaceCharactersInRange:result withAttributedString:replace];
            node.range = NSMakeRange(result.location, node.content.length);
            offset = node.range.location + node.range.length;
            [self.nodes  addObject:node];
        }
        if (type == DKTextTypeFace) {
            NSString *content = [match stringByReplacingOccurrencesOfString:@"\\[#f:|#\\]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, match.length)];
            NSString *path = [NSString stringWithFormat:@"%@emoji%@.png",_faceDirectory,content];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (!image) {
                path = [NSString stringWithFormat:@"%@emoji_nu.png",_faceDirectory];
                //                image = [UIImage imageWithContentsOfFile:path];
                image = [UIImage imageNamed:@"emoji_null"];
                
            }
            NSTextAttachment *att = [[NSTextAttachment alloc]init];
            att.image = image;
            att.bounds = CGRectMake(0, _font.descender, _font.lineHeight, _font.lineHeight);
            
            NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:att];
            [self.attributedString replaceCharactersInRange:result withAttributedString:imgStr];
            
            DKAttributeNode *node = [DKAttributeNode new];
            node.type = DKTextTypeFace;
            node.content = content;
            node.range = NSMakeRange(result.location, 1);
            offset = node.range.location + node.range.length;
            [self.nodes addObject:node];
        }
        if (type == DKTextTypeLink) {
            DKAttributeNode *node = [DKAttributeNode new];
            node.type = DKTextTypeLink;
            NSAttributedString *replace = [[NSAttributedString alloc]initWithString:match attributes:@{NSForegroundColorAttributeName:node.textColor,NSBackgroundColorAttributeName:node.backgroundColor,NSFontAttributeName:self.font,NSParagraphStyleAttributeName:style}];
            [self.attributedString replaceCharactersInRange:result withAttributedString:replace];
            node.range = result;
            node.content = match;
            offset = node.range.location + node.range.length;
            [self.nodes addObject:node];
        }
        count ++;
    }
    self.text = self.attributedString.string;
    
}

- (CGFloat)getHeightOfWidth:(CGFloat)width orginalText:(NSString *)orginalText{
    if (self.height!=0) {
        return self.height;
    }
    [self parseText:orginalText];
    CGRect rect = [self.attributedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size.height;
}


- (DKTextType)typeOfText:(NSString *)tx{
    NSRange range = [tx rangeOfString:regluarEmotion options:NSRegularExpressionSearch];
    if (range.length) {
        return DKTextTypeMotion;
    }
    range = [tx rangeOfString:regluarFace options:NSRegularExpressionSearch];
    if (range.length) {
        return DKTextTypeFace;
    }
    range = [tx rangeOfString:regluarLink options:NSRegularExpressionSearch];
    if (range.length) {
        return DKTextTypeLink;
    }
    return DKTextTypeText;
}


- (NSRange)matchPatternOffset:(NSInteger)offset{
    NSString *regluar = [self.regulars componentsJoinedByString:@"|"];
    NSString *string = [self.attributedString.mutableString substringWithRange:NSMakeRange(offset, self.attributedString.mutableString.length - offset)];
    NSRange range = [string rangeOfString:regluar options:NSRegularExpressionSearch];
    NSRange result = NSMakeRange(range.location + offset, range.length);
    return result;
}


@end


@interface DKAttributeLabel(){
    
}
@end

@implementation DKAttributeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        
    }
    return self;
}



- (void)setText:(NSString *)text{
    _text = text;
    DKAttributeText *attrString = [[DKAttributeText alloc]init];
    [attrString parseText:text];
    self.attributeText = attrString;
    [self setNeedsDisplay];
}






- (void)drawRect:(CGRect)rect {
    [self.attributeText.attributedString drawInRect:rect];
}

- (NSInteger)getLineIndex:(NSArray *)lines s:(CGPoint)s{
    __block NSInteger lineIndex = -1;
    __block CGFloat hc = 0;
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CTLineRef line = (__bridge CTLineRef)(obj);
        CGRect bounds = CTLineGetBoundsWithOptions(line, 0);
        NSLog(@"line = %li( %f,%f,%f,%f )",idx,bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
        hc = bounds.size.height  + hc;
        
        if (s.y < hc) {
            lineIndex = idx;
            *stop = YES;
        }
    }];
    
    return lineIndex;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint s = [touches.anyObject locationInView:self];
    if (s.y < 0) {
        return;
    }
    CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributeText.attributedString);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height), NULL);
    CTFrameRef frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    // 获取点击h行
    if (!lines.count) {
        return;
    }
    
    NSInteger lineIndex = [self getLineIndex:lines s:s];
    if (lineIndex == -1) {
        return;
    }
    CTLineRef currentLine = (__bridge CTLineRef)lines[lineIndex];
    
    CFRange lineRange = CTLineGetStringRange(currentLine);
    NSString *lineString = [self.attributeText.text substringWithRange:NSMakeRange(lineRange.location, lineRange.length)];
    NSLog(@"%@",lineString);
    
    CFIndex currentIndex = -1;
    unichar placeHolder = 0xFFFC;//创建空白字符
    NSString *blank = [NSString stringWithCharacters:&placeHolder length:1];
    int countBlank =0;
    for (CFIndex i = lineRange.location; i < lineRange.length + lineRange.location+1; i++) {
        CGFloat second = 0;
        CGFloat wordX = CTLineGetOffsetForStringIndex(currentLine, i, &second);
        
        currentIndex = i - 1;
        NSString *c = [self.attributeText.text substringWithRange:NSMakeRange(currentIndex, 1)];
        
        CGFloat offset = countBlank * self.attributeText.font.lineHeight;
        
        if (s.x - offset< wordX) {
            NSLog(@"%@ | %f | %f %li",c,wordX,second, currentIndex);
            break;
        }
        if ([c isEqualToString:blank]) {
            countBlank ++;
        }
    }
    if (currentIndex == -1) {
        return;
    }
    [self.attributeText.nodes enumerateObjectsUsingBlock:^(DKAttributeNode *node, NSUInteger idx, BOOL * _Nonnull stop) {
        if (NSLocationInRange(currentIndex , node.range)) {
            if (node) {
                node.selected = YES;
                [self.attributeText.attributedString addAttributes:@{NSForegroundColorAttributeName:node.selectedTextColor,NSBackgroundColorAttributeName:node.selectedBackgroundColor} range:node.range];
                [self setNeedsDisplay];
            }
        }
    }];
    
    lines = nil;
    CGPathRelease(path);
    CFRelease(setter);
    CFRelease(frame);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.attributeText.nodes enumerateObjectsUsingBlock:^(DKAttributeNode *node, NSUInteger idx, BOOL * _Nonnull stop) {
        if (node.selected) {
            [self.delegate actionNode:node];
        }
        node.selected = NO;
        [self.attributeText.attributedString addAttributes:@{NSForegroundColorAttributeName:node.textColor,NSBackgroundColorAttributeName:node.backgroundColor} range:node.range];
        [self setNeedsDisplay];
    }];
}


- (void)touchesCanceled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.attributeText.nodes enumerateObjectsUsingBlock:^(DKAttributeNode *node, NSUInteger idx, BOOL * _Nonnull stop) {
        if (node.selected) {
            [self.delegate actionNode:node];
        }
        node.selected = NO;
        [self.attributeText.attributedString addAttributes:@{NSForegroundColorAttributeName:node.textColor,NSBackgroundColorAttributeName:node.backgroundColor} range:node.range];
        [self setNeedsDisplay];
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.attributeText.nodes enumerateObjectsUsingBlock:^(DKAttributeNode *node, NSUInteger idx, BOOL * _Nonnull stop) {
        if (node.selected) {
            [self.delegate actionNode:node];
        }
        node.selected = NO;
        [self.attributeText.attributedString addAttributes:@{NSForegroundColorAttributeName:node.textColor,NSBackgroundColorAttributeName:node.backgroundColor} range:node.range];
        [self setNeedsDisplay];
    }];
}


@end
