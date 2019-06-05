//
//  CollectionViewController.m
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "CollectionViewController.h"
#import "Model.h"
#import "CollectionViewCell.h"
#import "ViewModel.h"
#import "NSString+FilePath.h"

#define KCScreenW [UIScreen mainScreen].bounds.size.width
#define KCScreenH [UIScreen mainScreen].bounds.size.height

static NSString *reuseID = @"reuseID";

@interface CollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSMutableDictionary *imageCacheDict;
@property (nonatomic, strong) NSMutableDictionary *operationDict;
@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Operation应用";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除缓存" style:(UIBarButtonItemStyleDone) target:self action:@selector(deleteCacheData)];
    
    //添加到视图
    [self.view addSubview:self.collectionView];
    self.viewModel = [ViewModel new];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.viewModel loadDataSuccess:^(id  _Nonnull data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray addObjectsFromArray:(NSMutableArray *)data];
                [self.collectionView reloadData];
            });
        }];
    });
}
- (void)deleteCacheData {
    [self.imageCacheDict removeAllObjects];
    NSFileManager *fieldManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if ([fieldManager fileExistsAtPath:cachePath]) {
        BOOL isDel = [fieldManager removeItemAtPath:cachePath error:nil];
        if (isDel) {
            NSLog(@"删除沙盒数据成功");
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"收到内存警告");
    [self.imageCacheDict removeAllObjects];
    NSFileManager *fieldManager = [NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if ([fieldManager fileExistsAtPath:cachePath]) {
        BOOL isDel = [fieldManager removeItemAtPath:cachePath error:nil];
        if (isDel) {
            NSLog(@"删除沙盒数据成功");
        }
    }
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
//    cell.imageView.image = nil;
    //从内存加载
    UIImage *cacheImage = self.imageCacheDict[model.imageUrl];
    if (cacheImage) {
        NSLog(@"从内存加载image数据");
        cell.imageView.image = cacheImage;
        return cell;
    }
    
    //从磁盘加载
    cacheImage = [UIImage imageWithContentsOfFile:[model.imageUrl getDowloadImagePath]];
    if (cacheImage) {
        NSLog(@"从磁盘加载image数据");
        cell.imageView.image = cacheImage;
        [self.imageCacheDict setObject:cacheImage forKey:model.imageUrl];
        return cell;
    }
    
    if (self.operationDict[model.imageUrl]) {
        NSLog(@"稍等,%@正在下载中",model.title);
        return cell;
    }
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"开始下载图片 , %@",model.title);
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        if (image && data) {
            //保存内存
            [self.imageCacheDict setObject:image forKey:model.imageUrl];
            //保存磁盘
            [data writeToFile:[model.imageUrl getDowloadImagePath] atomically:YES];
            //下载完成，，从下载记录字典清除
            [self.operationDict removeObjectForKey:model.imageUrl];
            //更新UI
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.imageView.image = image;
                model.image = image;
            }];
        } else {
            NSLog(@"图片下载失败 %@",model.title);
        }
    }];
    //将下载任务添加到队列
    [self.queue addOperation:op];
    //将下载任务添加到记录字典
    [self.operationDict setObject:op forKey:model.imageUrl];
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
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}
- (NSMutableDictionary *)imageCacheDict {
    if (!_imageCacheDict) {
        _imageCacheDict = [[NSMutableDictionary alloc] init];
    }
    return _imageCacheDict;
}
- (NSMutableDictionary *)operationDict {
    if (!_operationDict) {
        _operationDict = [[NSMutableDictionary alloc] init];
    }
    return _operationDict;
}
- (void)dealloc {
    NSLog(@"__dealloc__ collectionViewController");
}
@end
