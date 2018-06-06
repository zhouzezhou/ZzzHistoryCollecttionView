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

//@property (nonatomic, strong) UICollectionView *mainCollectionView;


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
@property (nonatomic, assign) NSInteger allItemCount;   // Item的数量

@property (nonatomic, assign) int onePageRowNum;       // 一个屏幕里能显示的行数
@property (nonatomic, assign) int onePageCellNum;       // 一个屏幕里能显示的item个数

@property (nonatomic, assign) int oneIncreaseRowNum;    // 每次下拉到达要求时增加的行数
@property (nonatomic, assign) int allIncreaseTimes;     // 增加（多）行的总次数

@property (nonatomic, assign) int allIncreaseTimes_MAX; // 增加（多）行的总次数的最大值

@property (nonatomic, assign) int increaseRowSubNum;    // 加载倒数第几行的时候开始增加总行数

// Data
@property (nonatomic, assign) NSInteger selectedItemID; // 被选中的item的ID
@property (nonatomic, strong) NSMutableArray *date;       // 数据源

//    详情显示label
@property (nonatomic, strong) UILabel *dateLabel;       // 日期标签



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view setBackgroundColor:[UIColor redColor]];
    
    
    // collectionView size
    //    self.collectionViewHorPadding = kScreenWidth / 10;
    float descriptionViewHeight = 50;
    
    self.collectionViewHorPadding = 0;
    self.collectionViewWidth = kScreenWidth - (self.collectionViewHorPadding * 2);
    self.collectionViewHeight = kScreenHeight - kStatusBarHeight - descriptionViewHeight;
    self.allIncreaseTimes_MAX = 100;        // 之后需要根据日期和其它信息动态计算
    
    // 计算cell size
    self.rowCellNum = 10;
    self.cellPaddingAll = self.collectionViewWidth / 10;
    self.cellPaddingOne = self.cellPaddingAll / (self.rowCellNum  + 1);
    self.cellWidth = (self.collectionViewWidth - self.cellPaddingAll) / self.rowCellNum;
    self.cellHeight = self.cellWidth;
    self.cellSize = CGSizeMake(self.cellWidth, self.cellHeight);
    
    
    // 计算一页的个数
    self.onePageRowNum = (int)(self.collectionViewHeight / (self.cellHeight + self.cellPaddingOne));
    self.onePageCellNum = (self.onePageRowNum + 0) * self.rowCellNum;
    
    self.oneIncreaseRowNum = 5;
    self.allIncreaseTimes = 1;
    self.increaseRowSubNum = 2;
    
    self.allItemCount = self.onePageCellNum + (self.allIncreaseTimes * self.oneIncreaseRowNum * self.rowCellNum);
    
    
    [self configData];
    
    // UICollectionView会默认从系统状态栏下开始绘制
    UICollectionView *mainCollectionView;
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    //    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 100);
    //    //该方法也可以设置itemSize
    //    layout.itemSize =CGSizeMake(110, 150);
    
    //2.初始化collectionView
    CGRect collectionViewRect = CGRectMake(self.collectionViewHorPadding, kScreenHeight - self.collectionViewHeight, self.collectionViewWidth, self.collectionViewHeight);
    mainCollectionView = [[UICollectionView alloc] initWithFrame:collectionViewRect collectionViewLayout:layout];
    [self.view addSubview:mainCollectionView];
    mainCollectionView.backgroundColor = [UIColor greenColor];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [mainCollectionView registerClass:[ZzzHistoryCollectionViewCell class] forCellWithReuseIdentifier:@"cellId"];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    //    [mainCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    
    //4.设置代理
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    
    UIView *descrpitionView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, descriptionViewHeight)];
    [self.view addSubview:descrpitionView];
    [descrpitionView setBackgroundColor:[UIColor greenColor]];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    [self.dateLabel setText:@"日期"];
    [descrpitionView addSubview:self.dateLabel];
    [self.dateLabel setBackgroundColor:[UIColor orangeColor]];
    
    
    
}

-(void) configData
{
    NSUInteger maxColloectionItem = self.onePageCellNum + (self.allIncreaseTimes_MAX * self.oneIncreaseRowNum * self.rowCellNum);
    self.date = [NSMutableArray array];
    
    for(int i = 0; i < maxColloectionItem; i++)
    {
        DataZzzHistory *tempDataZzzHistory = [[DataZzzHistory alloc] init];
        tempDataZzzHistory.date = [self formatDateByDayBeforeNow:i];
        
        [self.date addObject:tempDataZzzHistory];
    }

    NSLog(@"Array count is :%ld", [self.date count]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private mothed

- (NSDate *)formatDateByDayBeforeNow:(NSInteger) day
{
    NSDate *now = [NSDate date];
    NSDate *newdate = now;
    
    if (day != 0) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        comps.day -= day;
        newdate = [calendar dateFromComponents:comps];
    }
    
    return newdate;
    
//    //实例化一个NSDateFormatter对象
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
//    //设定时间格式,这里可以设置成自己需要的格式
//    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
//
//    //用[NSDate date]可以获取系统当前时间
//    return [dateFormatter stringFromDate:newdate];
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
    NSLog(@"%d", (self.onePageCellNum + (self.allIncreaseTimes * self.oneIncreaseRowNum * self.rowCellNum)) / self.rowCellNum);
    return self.onePageCellNum + (self.allIncreaseTimes * self.oneIncreaseRowNum * self.rowCellNum);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"indexPath is %ld", indexPath.row);
    //    NSLog(@"self.onePageRowNum:%d", self.onePageRowNum);
    
    //    NSLog(@"当前总共可显示多少行：%d\n", self.onePageRowNum + self.allIncreaseTimes * self.oneIncreaseRowNum);
    if((indexPath.row / self.rowCellNum) + 1 >= ((self.onePageRowNum + self.allIncreaseTimes * self.oneIncreaseRowNum) - self.increaseRowSubNum) && self.allIncreaseTimes < self.allIncreaseTimes_MAX)
    {
        NSLog(@"正在加载多少行：%ld\n", (indexPath.row / self.rowCellNum) + 1);
        //        NSLog(@"refresh collectionview !");
        //        NSLog(@"当前总共可显示多少行：%d", self.onePageRowNum + self.allIncreaseTimes * self.oneIncreaseRowNum);
        //        if((indexPath.row + 1) <= 238)
        //        {
        self.allIncreaseTimes++;
        NSLog(@"self.allIncreaseTimes is :%d", self.allIncreaseTimes);
        //            [collectionView reloadData];
        
        NSMutableArray *insertArray = [NSMutableArray array];
        for(int i = 0; i < (self.oneIncreaseRowNum * self.rowCellNum); i++)
        {
            NSIndexPath *tempIndexPath = [NSIndexPath indexPathForItem:(self.onePageCellNum + (self.allIncreaseTimes * self.oneIncreaseRowNum * self.rowCellNum) - 1 - i) inSection:0];
            
            [insertArray addObject:tempIndexPath];
        }
        [collectionView insertItemsAtIndexPaths:insertArray];
        
        //        }
    }
    
    ZzzHistoryCollectionViewCell *cell = (ZzzHistoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    
    //    for (UIView *view in cell.contentView.subviews) {
    //        if (view) {
    //            [view removeFromSuperview];
    //        }
    //    }
    
    //    if(!cell)
    //    {
    ////        while ([cell.contentView.subviews lastObject] != nil)
    ////        {
    ////            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
    ////        }
    //        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, self.cellWidth, self.cellHeight)];
    //
    //    }
    
    //    cell.botlabel.text = [NSString stringWithFormat:@"{%ld,%ld}",(long)indexPath.section,(long)indexPath.row];
    
    //    for (UIView *view in cell.contentView.subviews) {
    //        [view removeFromSuperview];
    //    }
    
    
    if(self.selectedItemID == indexPath.row)
    {
        cell.backgroundColor = [UIColor purpleColor];
    }
    else
    {
        cell.backgroundColor = [UIColor yellowColor];
    }
    
    
    //    UILabel *rowNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.cellWidth, self.cellHeight)];
    //    [rowNumLabel setText:[NSString stringWithFormat:@"%ld", (indexPath.row / self.rowCellNum) + 1]];
    //    [rowNumLabel setTextAlignment:NSTextAlignmentCenter];
    //
    //    [cell addSubview:rowNumLabel];
    
    //    [cell.rowNumLabel setText:[NSString stringWithFormat:@"%ld", (indexPath.row / self.rowCellNum) + 1]];
    
    [cell.rowNumLabel setText:[NSString stringWithFormat:@"%ld", indexPath.row]];
    
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
    //    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    NSString *msg = cell.botlabel.text;
    //    NSLog(@"%@",msg);
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy'年'MM'月'dd'日"];
    NSString *selectedItemDateStr = [df stringFromDate:[self.date[indexPath.row] date]];
    
    [self.dateLabel setText:[NSString stringWithFormat:@"Your selected item date is :%@", selectedItemDateStr]];
    
    // 更新collectionview对应的两个item
    NSMutableArray *reloadArray = [NSMutableArray array];
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:self.selectedItemID inSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    
    [reloadArray addObject:oldIndexPath];
    [reloadArray addObject:newIndexPath];
    
    
    self.selectedItemID = indexPath.row;
    
    [collectionView reloadItemsAtIndexPaths:reloadArray];
    
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"collectionview.contentOffset.y: %f", scrollView.contentOffset.y);
    //
    //
    //    float increaseRowPointY = self.allIncreaseTimes * self.oneIncreaseRowNum * self.cellHeight;
    //    if(scrollView.contentOffset.y)
    //    {
    //
    //    }
    
    //    self.allIncreaseTimes++;
    
    
    
}


@end

