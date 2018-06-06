//
//  DataZzzHistory.h
//  ZzzHistoryCollecttionView
//
//  Created by zhouzezhou on 2018/6/6.
//  Copyright © 2018 Zzz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataZzzHistory : NSObject

@property (nonatomic, strong) NSDate *date;     // 代表的哪一天,YYYY-mm-dd
@property (nonatomic, strong) NSDate *start;    // 开始时间,YYYY-mm-dd HH:mm:ss:ms
@property (nonatomic, strong) NSDate *end;      // 结束时间,YYYY-mm-dd HH:mm:ss:ms

@property (nonatomic, assign) NSInteger levelData; // 等级

@end

NS_ASSUME_NONNULL_END
