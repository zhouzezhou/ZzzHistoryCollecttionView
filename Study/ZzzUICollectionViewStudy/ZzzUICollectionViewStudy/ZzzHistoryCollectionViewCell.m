//
//  ZzzHistoryCollectionViewCell.m
//  ZzzUICollectionViewStudy
//
//  Created by zhouzezhou on 2018/5/31.
//  Copyright © 2018年 zzz. All rights reserved.
//

#import "ZzzHistoryCollectionViewCell.h"

@implementation ZzzHistoryCollectionViewCell

-(instancetype) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.rowNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self addSubview:self.rowNumLabel];
    }
    
    return self;
}

@end
