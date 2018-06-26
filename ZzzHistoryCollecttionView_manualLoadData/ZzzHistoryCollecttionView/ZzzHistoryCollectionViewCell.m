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
    
    self.levelView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2)];
    [self addSubview:self.levelView];
    
    self.rowNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self.rowNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.rowNumLabel setFont:[UIFont systemFontOfSize:10]];
    
    [self addSubview:self.rowNumLabel];
    
//    NSLog(@"UICollectionViewCell size is :%f,%f", self.bounds.size.width, self.bounds.size.height);

    
    return self;
}

@end
