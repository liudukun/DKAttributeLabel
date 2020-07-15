//
//  DKAttributeLabel.h
//  DDChat
//
//  Created by liudukun on 2018/1/12.
//  Copyright © 2018年 com.ldk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DKTextTypeText,
    DKTextTypeFace,
    DKTextTypeMotion,
    DKTextTypeLink,
} DKTextType;

typedef enum : NSUInteger {
    DKTextMotionTypeText,
    DKTextMotionTypeAssigner,
    DKTextMotionTypeSubject,
} DKTextMotionType;


@interface DKAttributeNode : NSObject

@property (nonatomic,strong) NSString *content,*contentId;
@property (nonatomic) DKTextMotionType subType;

@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UIColor *selectedTextColor;

@property (nonatomic,strong) UIColor *backgroundColor;
@property (nonatomic,strong) UIColor *selectedBackgroundColor;
@property (nonatomic,strong) UIFont *font;

@property (nonatomic) BOOL selected;

@property (nonatomic) DKTextType type;
@property (nonatomic) NSRange range;
@property (nonatomic) NSRange realRange;


@end


@interface DKAttributeText : NSObject

@property (nonatomic,strong) NSMutableArray<DKAttributeNode *> *nodes;
@property (nonatomic,strong) NSArray<NSString *> *regulars;
@property (nonatomic,strong) NSMutableAttributedString *attributedString;
@property (nonatomic,strong) NSDictionary *dataDictionary;
@property (nonatomic,strong) NSString *orginalText;
@property (nonatomic,strong) NSString *text;
@property (nonatomic) NSTextAlignment alignment;
@property (nonatomic) CGFloat height;

@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *backgroundColor;
@property (nonatomic,strong) UIColor *textColor;

@property (nonatomic,strong) NSString *faceDirectory;

- (CGFloat)getHeightOfWidth:(CGFloat)width orginalText:(NSString *)orginalText;

@end

@protocol DKAttributeLabelDelegate<NSObject>

- (void)actionNode:(DKAttributeNode *)node;

@end


@interface DKAttributeLabel : UIView

@property (nonatomic,strong) NSString *text;

@property (nonatomic,weak) id<DKAttributeLabelDelegate> delegate;

@property (nonatomic,strong) DKAttributeText *attributeText;


@end
