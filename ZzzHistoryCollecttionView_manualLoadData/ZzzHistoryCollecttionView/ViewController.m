//
//  ViewController.m
//  ZzzHistoryCollecttionView
//
//  Created by zhouzezhou on 2018/5/18.
//  Copyright © 2018年 Zzz. All rights reserved.
//

#import "ViewController.h"
#import "ZzzHistoryCollectionViewCell.h"
#import "DataZzzHistory.h"

// 屏幕的宽度
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

// 屏幕的高度
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

// 系统状态栏高度
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

//设置RGB颜色值
#define COLOR(R,G,B,A)    [UIColor colorWithRed:(CGFloat)R/255.0 green:(CGFloat)G/255.0 blue:(CGFloat)B/255.0 alpha:A]

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *historyCollectionView;


// collectionView size
@property (nonatomic, assign) float collectionViewHorPadding;   // collectionView左右的Padding
@property (nonatomic, assign) float collectionViewWidth;        // collectionView的宽度
@property (nonatomic, assign) float collectionViewHeight;       // collectionView的高度
// 计算cell size
@property (nonatomic, assign) int rowCellNum;           // 每行显示几个
@property (nonatomic, assign) float cellPaddingAll;     // 一行的总padding大小
@property (nonatomic, assign) float cellPaddingOne;     // 一行内每一个padding的大小
@property (nonatomic, assign) float cellWidth;          // 显示内容的item的宽
@property (nonatomic, assign) float cellHeight;         // 显示内容的item的高
@property (nonatomic, assign) CGSize cellSize;          // 显示内容的item的大小

@property (nonatomic, assign) int onePageRowNum;       // 一个屏幕里能显示的行数
@property (nonatomic, assign) int onePageCellNum;      // 一个屏幕里能显示的item个数
@property (nonatomic, assign) int onePageSubRow;       // 为了填充完整个屏幕补充的行数
@property (nonatomic, assign) int increaseRowNumMax;   // 为了显示最早的数据需要增加显示多少行(比之前算出来的一个屏幕能显示的所有item还要多出 几行)


// Data
@property (nonatomic, assign) NSInteger selectedItemID; // 被选中的item的ID
@property (nonatomic, strong) NSMutableArray *dataHistoryArray;       // 数据源
@property (nonatomic, strong) NSDate *dateCreateDate;    // 数据生成的时间，为了保证在一天的临界点数据分析正常，每次生成数据的时候使用一个时间而不是多次生成，更新整个数据源的时候才更新此值
//    详情显示label
@property (nonatomic, strong) UILabel *dateLabel;       // 日期标签

@property (nonatomic, strong) UIButton *testBtn1;        // 测试用的按钮
@property (nonatomic, strong) UIButton *testBtn2;        // 测试用的按钮



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 初始化数据
    self.dataHistoryArray = [NSMutableArray array];
    
    // 配置CollectionView参数
    // collectionView size
    float descriptionViewHeight = 150;
    
    self.rowCellNum = 12;
    self.onePageSubRow = 3;
    self.collectionViewHorPadding = kScreenWidth / (10 * self.rowCellNum);
    
    self.collectionViewWidth = kScreenWidth - (self.collectionViewHorPadding * 2);
    self.collectionViewHeight = kScreenHeight - kStatusBarHeight - descriptionViewHeight;
    
    // 计算cell size
    self.cellPaddingAll = self.collectionViewWidth / 30;
    self.cellPaddingOne = self.cellPaddingAll / (self.rowCellNum  + 1);
    self.cellWidth = (self.collectionViewWidth - self.cellPaddingAll) / self.rowCellNum;
    self.cellHeight = self.cellWidth;
    self.cellSize = CGSizeMake(self.cellWidth, self.cellHeight);
    
    // 计算一页的个数
    self.onePageRowNum = (int)(self.collectionViewHeight / (self.cellHeight + self.cellPaddingOne));
    self.onePageCellNum = (self.onePageRowNum + self.onePageSubRow) * self.rowCellNum;
    NSLog(@"onePageCellNum :%d", self.onePageCellNum);
   
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    //2.初始化collectionView
    CGRect collectionViewRect = CGRectMake(self.collectionViewHorPadding, kScreenHeight - self.collectionViewHeight, self.collectionViewWidth, self.collectionViewHeight);
    self.historyCollectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:layout];
    [self.view addSubview:self.historyCollectionView];
    self.historyCollectionView.backgroundColor = [UIColor whiteColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.historyCollectionView registerClass:[ZzzHistoryCollectionViewCell class] forCellWithReuseIdentifier:@"ZzzHistoryCollectionViewCellId"];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    //    [self.historyCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    
    //4.设置代理
    self.historyCollectionView.delegate = self;
    self.historyCollectionView.dataSource = self;
    
    
    //  顶部的详细内容显示区
    UIView *descrpitionView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, descriptionViewHeight)];
    [self.view addSubview:descrpitionView];
    [descrpitionView setBackgroundColor:[UIColor whiteColor]];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 34)];
    [self.dateLabel setText:@"日期"];
    [descrpitionView addSubview:self.dateLabel];
    [self.dateLabel setBackgroundColor:[UIColor whiteColor]];
    [self.dateLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
    [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.testBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.testBtn1 setFrame:CGRectMake(20, 50, kScreenWidth - 40, 30)];
    [self.testBtn1 setTitle:@"开始加载 少量 数据并显示" forState:UIControlStateNormal];
    [self.testBtn1 setBackgroundColor:[UIColor redColor]];
    self.testBtn1.layer.cornerRadius = 4.f;
    [self.testBtn1 addTarget:self action:@selector(testBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [descrpitionView addSubview:self.testBtn1];
    
    
    self.testBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.testBtn2 setFrame:CGRectMake(20, 100, kScreenWidth - 40, 30)];
    [self.testBtn2 setTitle:@"开始加载 大量 数据并显示" forState:UIControlStateNormal];
    [self.testBtn2 setBackgroundColor:[UIColor redColor]];
    self.testBtn2.layer.cornerRadius = 4.f;
    [self.testBtn2 addTarget:self action:@selector(testBtn2Click) forControlEvents:UIControlEventTouchUpInside];
    [descrpitionView addSubview:self.testBtn2];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private mothed

-(void) testBtnClick
{
    NSLog(@"testBtnClick");
    
    self.dateCreateDate = [NSDate date];
    
    // 最早一次记录距今天多少天
//    int allItemNum = 1;
    int allItemNum = 277;
    
    // 比一页显示的数量都少，则最多显示当前页
    if(allItemNum <= self.onePageCellNum)
    {
        self.increaseRowNumMax = 0;
    }
    else
    {
        float fMax = ((float)allItemNum - (float)self.onePageCellNum) / (float)self.rowCellNum;
        // 判断fMax是否为小数
        if(fMax != (int)fMax)
        {
            self.increaseRowNumMax = fMax + 1;
        }
        else
        {
            self.increaseRowNumMax = fMax;
        }
    }
    NSLog(@"increaseRowNumMax is :%d", self.increaseRowNumMax);
    
    NSUInteger maxColloectionItem = self.onePageCellNum + (self.increaseRowNumMax * self.rowCellNum);
    
    [self.dataHistoryArray removeAllObjects];
    // 初始化数据源数组
    for(int i = 0; i < maxColloectionItem; i++)
    {
        DataZzzHistory *tempDataZzzHistory = [[DataZzzHistory alloc] init];
        tempDataZzzHistory.date = [self formatDateByDayBeforeNow:i nowDate:self.dateCreateDate];
        tempDataZzzHistory.levelData = 0;
        
        [self.dataHistoryArray addObject:tempDataZzzHistory];
    }
    
    NSLog(@"Array count is :%ld", [self.dataHistoryArray count]);
    
    // 模拟在特定的日期加上不同的内容,此数据应来自数据库
    NSArray *dataLevelArray = [NSArray arrayWithObjects:
                               [self formatDateByDayBeforeNow:0 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:4 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:5 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:7 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:8 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:12 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:14 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:20 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:27 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:33 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:37 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:40 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:41 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:43 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:44 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:45 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:60 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:275 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:700 nowDate:self.dateCreateDate],
                               nil];

    for(NSDate *temp in dataLevelArray)
    {
        NSDate *today = self.dateCreateDate;

        // 相差多少天
        NSTimeInterval timeBetween = [today timeIntervalSinceDate:temp];
//        NSLog(@"timeBetween is :%f", timeBetween);

        NSUInteger lTimeBetween = (long)timeBetween;

        NSUInteger daysBetween = lTimeBetween / (3600 * 24);
//        NSLog(@"between days is :%lu", (unsigned long)daysBetween);

        // 模拟数据 - 不同的等级
        int tempLevel = (daysBetween % 5) + 1;
//        NSLog(@"tempLevel is :%d", tempLevel);
        if(daysBetween < [self.dataHistoryArray count])
        {
            [self.dataHistoryArray[daysBetween] setLevelData:tempLevel];
        }
    }
    
    [self.historyCollectionView reloadData];
}



-(void) testBtn2Click
{
    NSLog(@"testBtnClick");
    
    self.dateCreateDate = [NSDate date];
    
    // 最早一次记录距今天多少天
    int allItemNum = 365 * 20;
    
    // 比一页显示的数量都少，则最多显示当前页
    if(allItemNum <= self.onePageCellNum)
    {
        self.increaseRowNumMax = 0;
    }
    else
    {
        float fMax = ((float)allItemNum - (float)self.onePageCellNum) / (float)self.rowCellNum;
        // 判断fMax是否为小数
        if(fMax != (int)fMax)
        {
            self.increaseRowNumMax = fMax + 1;
        }
        else
        {
            self.increaseRowNumMax = fMax;
        }
    }
    NSLog(@"increaseRowNumMax is :%d", self.increaseRowNumMax);
    
    NSUInteger maxColloectionItem = self.onePageCellNum + (self.increaseRowNumMax * self.rowCellNum);
    
    [self.dataHistoryArray removeAllObjects];
    // 初始化数据源数组
    for(int i = 0; i < maxColloectionItem; i++)
    {
        DataZzzHistory *tempDataZzzHistory = [[DataZzzHistory alloc] init];
        tempDataZzzHistory.date = [self formatDateByDayBeforeNow:i nowDate:self.dateCreateDate];
        tempDataZzzHistory.levelData = 0;
        
        [self.dataHistoryArray addObject:tempDataZzzHistory];
    }
    
    NSLog(@"Array count is :%ld", [self.dataHistoryArray count]);
    
    // 模拟在特定的日期加上不同的内容,此数据应来自数据库
    NSArray *dataLevelArray = [NSArray arrayWithObjects:
                               [self formatDateByDayBeforeNow:0 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:4 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:5 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:7 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:8 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:12 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:14 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:20 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:27 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:33 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:37 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:40 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:41 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:43 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:44 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:45 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:60 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:275 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:700 nowDate:self.dateCreateDate],
                               [self formatDateByDayBeforeNow:2000 nowDate:self.dateCreateDate],
                               nil];

    for(NSDate *temp in dataLevelArray)
    {
        NSDate *today = self.dateCreateDate;

        // 相差多少天
        NSTimeInterval timeBetween = [today timeIntervalSinceDate:temp];
//        NSLog(@"timeBetween is :%f", timeBetween);

        NSUInteger lTimeBetween = (long)timeBetween;

        NSUInteger daysBetween = lTimeBetween / (3600 * 24);
//        NSLog(@"between days is :%lu", (unsigned long)daysBetween);

        // 模拟数据 - 不同的等级
        int tempLevel = (daysBetween % 5) + 1;
//        NSLog(@"tempLevel is :%d", tempLevel);
        if(daysBetween < [self.dataHistoryArray count])
        {
            [self.dataHistoryArray[daysBetween] setLevelData:tempLevel];
        }
    }
    
    [self.historyCollectionView reloadData];
}

- (NSDate *)formatDateByDayBeforeNow:(NSInteger) day nowDate:(NSDate *) now
{
    NSDate *newdate = now;
    
    if (day != 0) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        comps.day -= day;
        newdate = [calendar dateFromComponents:comps];
    }
    
    return newdate;
}

// 判断某个日期是否为一个月的第一天，如果是则返回当前的月份，如果不是返回空字符串
-(NSString *) isFirstDayForMonth:(NSDate *) date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    if(comps.day == 1)
    {
        return [NSString stringWithFormat:@"%ld月", comps.month];
    }
    return @"";
}

#pragma mark - collectionView代理方法
// 返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// 每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataHistoryArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZzzHistoryCollectionViewCell *cell = (ZzzHistoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZzzHistoryCollectionViewCellId" forIndexPath:indexPath];
    
    if(self.selectedItemID == indexPath.row)
    {
        cell.backgroundColor = [UIColor redColor];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy'年'MM'月'dd'日"];
        NSString *selectedItemDateStr = [df stringFromDate:[self.dataHistoryArray[indexPath.row] date]];
        
        [self.dateLabel setText:[NSString stringWithFormat:@"  %@ level %ld", selectedItemDateStr, (long)[self.dataHistoryArray[indexPath.row] levelData]]];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];        
    }
    
    
    switch ([self.dataHistoryArray[indexPath.row] levelData]) {
        case 0:
            cell.levelView.backgroundColor = COLOR(0xE7,0xE8,0xED,1.f);
            break;
        case 1:
            cell.levelView.backgroundColor = COLOR(0X00, 0XCC, 0XFF, 1);
            break;
        case 2:
            cell.levelView.backgroundColor = COLOR(0X00, 0X99, 0XFF, 1);
            break;
        case 3:
            cell.levelView.backgroundColor = COLOR(0X00, 0X66, 0XFF, 1);
            break;
        case 4:
            cell.levelView.backgroundColor = COLOR(0X00, 0X33, 0XFF, 1);
            break;
        case 5:
            cell.levelView.backgroundColor = [UIColor blueColor];
            break;
            
        default:
            cell.levelView.backgroundColor = COLOR(0xE7,0xE8,0xED,1.f);
            break;
    }
    
    NSString *monthStr = [self isFirstDayForMonth:[self.dataHistoryArray[indexPath.row] date]];
    if(monthStr.length != 0)
    {
        [cell.rowNumLabel setText:[NSString stringWithFormat:@"%@", monthStr]];
        [cell.rowNumLabel setTextColor:[UIColor redColor]];
//        [cell.rowNumLabel setText:[NSString stringWithFormat:@"%@ %ld", monthStr, indexPath.row]];
    }
    else
    {
//        [cell.rowNumLabel setText:[NSString stringWithFormat:@"%ld", indexPath.row]];
        [cell.rowNumLabel setTextColor:[UIColor blackColor]];
        
        // 虽然这种情况下不显示任何rowNumLabel，但下一行代码不能注释掉，注释了之后setText之后的rowNumLabel会被重用到其它item上，导致不该出现内容的item上出现内容
        [cell.rowNumLabel setText:@""];
    }
    
    
    
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}

//footer的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//header的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //    return UIEdgeInsetsMake(10, 10, 10, 10);
    return UIEdgeInsetsZero;
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    //    return 10;
    return self.cellPaddingOne;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    //    return 15;
    
    return self.cellPaddingOne;
}


//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
//    headerView.backgroundColor =[UIColor grayColor];
//    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
//    label.text = @"这是collectionView的头部";
//    label.font = [UIFont systemFontOfSize:20];
//    [headerView addSubview:label];
//    return headerView;
//}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectedItemID != indexPath.row)
    {
        
        // 更新collectionview对应的两个item
        NSMutableArray *reloadArray = [NSMutableArray array];
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:self.selectedItemID inSection:0];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
        
        [reloadArray addObject:oldIndexPath];
        [reloadArray addObject:newIndexPath];
        
        
        self.selectedItemID = indexPath.row;
        
        [collectionView reloadItemsAtIndexPaths:reloadArray];
    }
    else
    {
        // 进入另一个界面之类的
        // ...
        
    }
}

@end

