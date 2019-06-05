//
//  ViewController.m
//  Code
//
//  Created by 兰旭平 on 2019/6/4.
//  Copyright © 2019 兰旭平. All rights reserved.
//

#import "MainController.h"
#import "CollectionViewController.h"
#import "WebImageCollectionViewController.h"

@interface MainController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_data;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MainController
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (void)getData {
    _data = @[@"CollectionViewController",@"WebImageCollectionViewController"];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = NSClassFromString(_data[indexPath.row]);
    if (class) {
        UIViewController *vc = (UIViewController *)[[class alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view, typically from a nib.
}


@end
