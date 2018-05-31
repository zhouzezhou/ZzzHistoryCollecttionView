//
//  ViewController.m
//  ZzzUICollectionViewStudy
//
//  Created by zhouzezhou on 2018/5/31.
//  Copyright © 2018年 zzz. All rights reserved.
//

#import "ViewController.h"
#import "ZzzHistoryCollectionViewCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger itemNum;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.itemNum = 2;
    
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionview = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:fl];
    [collectionview setBackgroundColor:[UIColor greenColor]];
    
    [self.view addSubview:collectionview];
    
    collectionview.delegate = self;
    collectionview.dataSource = self;
    
    [collectionview registerClass:[ZzzHistoryCollectionViewCell class] forCellWithReuseIdentifier:@"historyCellID"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"get item num .");
    return self.itemNum;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"now loading item row is :%ld", indexPath.row);
    
    ZzzHistoryCollectionViewCell *cell = (ZzzHistoryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"historyCellID" forIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor redColor]];
    
    [cell.rowNumLabel setText:[NSString stringWithFormat:@"%ld", indexPath.row]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
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
        return 10;
//    return self.cellPaddingOne;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
        return 15;
    
//    return self.cellPaddingOne;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected !");
    
//    self.itemNum++;
//    [collectionView reloadData];
//    [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0],
//                                              [NSIndexPath indexPathForItem:1 inSection:0]]];
    
//    self.itemNum--;
//    [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    
    self.itemNum += 2;
    [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:(self.itemNum - 2) inSection:0],
                                              [NSIndexPath indexPathForItem:(self.itemNum - 1) inSection:0]]];

//    for(int i = 0; i < 100; i++)
//    {
//        self.itemNum++;
//        [collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:(self.itemNum - 1) inSection:0]]];
//
////        sleep(0.2);
//
//
//    }

}

@end
