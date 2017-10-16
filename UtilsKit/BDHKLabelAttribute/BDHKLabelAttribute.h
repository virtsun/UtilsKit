//
//  BDHKLabelAttribute.h
//  ArcPlayer
//
//  Created by YHL on 2017/10/13.
//  Copyright © 2017年 L.T.ZERO. All rights reserved.
//

//  BDHKLabelAttribute.h

#import <UIKit/UIKit.h>

/*!
 @enum BDHKVerticalTextAlignment
 @abstract 垂直方式
 */
typedef NS_ENUM(NSInteger, BDHKVerticalTextAlignment) {
    /*!
     @abstract 顶部
     */
    BDHKVerticalTextAlignmentTop,
    
    /*!
     @abstract 居中
     */
    BDHKVerticalTextAlignmentMiddle,
    
    /*!
     @abstract 底部
     */
    BDHKVerticalTextAlignmentBottom
};

@class BDHKLabelAttribute;
@protocol BDHKLabelAttributeDelegate <NSObject>

@optional
- (void)textView: (BDHKLabelAttribute *)textView didSelectedEmoji: (NSString *)emojiName;
- (void)textView: (BDHKLabelAttribute *)textView didSelectedHyperlink: (NSString *)hyperlink;
- (void)textView: (BDHKLabelAttribute *)textView didTruncationEndAttributedString: (NSAttributedString *)str;

@end

@interface BDHKLabelAttribute : UILabel

/*!
 @property verticalTextAlignment
 @abstract 上下对齐方式
 */
@property (nonatomic, assign) BDHKVerticalTextAlignment verticalTextAlignment;

/*!
 @property linesSpace
 @abstract 行间距
 */
@property (nonatomic, assign) CGFloat linesSpace;

/*!
 @property margin
 @abstract 边距
 */
@property (nonatomic, assign) UIEdgeInsets margin;

/*!
 @property lastLineRightIndent
 @abstract 尾行右缩进
 */
//@property (nonatomic, assign) CGFloat lastLineRightIndent;

/*!
 @property truncationEndAttributedString
 @abstract 尾行结束字符串
 */
@property (nonatomic, strong) NSAttributedString *truncationEndAttributedString;

/*!
 @property linesSpace
 @abstract 实际绘制的行数,当numberOfLines==0时
 */
@property (nonatomic, assign, readonly) NSInteger drawOfLines;

@property (nonatomic, weak) id<BDHKLabelAttributeDelegate> delegate;

@end


@interface NSString(BDHKLabelAttribute)

/*!
 @method sizeWithFont:width:linesSpace:numberOfLines:
 @abstract 测量字符串所要的大小
 @param font 字体
 @param width 宽度
 @param linesSpace 行高
 @param numberOfLines 行数
 */
- (CGSize)sizeWithFont:(UIFont *)font width:(CGFloat)width linesSpace:(CGFloat)linesSpace numberOfLines:(NSInteger)numberOfLines;

@end
