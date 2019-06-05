//
//  CollectionViewController.m
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "WebImageCollectionViewController.h"
#import "Model.h"
#import "CollectionViewCell.h"
#import "ViewModel.h"
#import "NSString+FilePath.h"
#import "UIImageView+WebCache.h"

extern NSString *ApplicationActionRemoveWebImageCache;

#define KCScreenW [UIScreen mainScreen].bounds.size.width
#define KCScreenH [UIScreen mainScreen].bounds.size.height

static NSString *reuseID = @"reuseID";

@interface WebImageCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation WebImageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SDWebimage(自定义NSOperation)";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除缓存" style:(UIBarButtonItemStyleDone) target:self action:@selector(deleteCacheData)];
    
    //添加到视图
    [self.view addSubview:self.collectionView];
    ViewModel *viewModel = [ViewModel new];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [viewModel loadDataSuccess:^(id  _Nonnull data) {
            NSLog(@"%@",self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray addObjectsFromArray:(NSMutableArray *)data];
                [self.collectionView reloadData];
            });
        }];
    });
}
- (void)deleteCacheData {
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationActionRemoveWebImageCache object:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    Model *model = self.dataArray[indexPath.row];
    cell.moneyLabel.text = model.money;
    cell.titleLabel.text = model.title;
    [cell.imageView my_setImageWithUrlString:model.imageUrl tag:model.title];
    return cell;
}

#pragma mark - lazy
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        //创建一个流水布局
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection              = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing      = 5;
        layout.minimumLineSpacing           = 5;
        layout.itemSize                     = CGSizeMake((KCScreenW-15)/2.0, 260);
        
        //初始化collectionView
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 0, KCScreenW-10, KCScreenH) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.scrollsToTop    = NO;
        //        _collectionView.pagingEnabled   = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces         = YES;
        _collectionView.dataSource      = self;
        _collectionView.delegate        = self;
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseID];
        
    }
    return _collectionView;
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray;
}
- (void)dealloc {
    NSLog(@"__dealloc__ collectionViewController");
}
@end
