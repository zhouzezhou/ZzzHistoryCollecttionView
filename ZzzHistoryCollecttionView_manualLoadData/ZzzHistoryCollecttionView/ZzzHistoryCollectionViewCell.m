//
//  ZzzHistoryCollectionViewCell.m
//  ZzzHistoryCollecttionView
//
//  Created by zhouzezhou on 2018/5/30.
//  Copyright © 2018年 Zzz. All rights reserved.
//

#import "ZzzHistoryCollectionViewCell.h"

@implementation ZzzHistoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    
    self.rowNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    [self.rowNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.rowNumLabel setFont:[UIFont systemFontOfSize:10]];
    
    [self addSubview:self.rowNumLabel];
    
    return self;
}

@end
