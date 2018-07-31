//
//  WKVideoListViewController.m
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/14.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "WKVideoListViewController.h"
#import "MJExtension.h"
#import "WKVideoListCell.h"
#import "WKPlayerView.h"
#import "AFNetworking.h"

@interface WKVideoListViewController () <UITableViewDelegate,UITableViewDataSource,WKPlayerViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WKPlayerView *palyerView;
@property (nonatomic, assign) NSInteger playIndex;


@end

@implementation WKVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频列表";
    self.view.backgroundColor = [UIColor whiteColor];

    [self getNetworkData];
}

- (void)getNetworkData {
    AFHTTPSessionManager *sessionMgr = [AFHTTPSessionManager manager];
    sessionMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    __weak typeof(self) weakSelf = self;
//    NSString *getstr = @"http://c.m.163.com/nc/video/home/0-10.html";
    NSString *getstr = @"http://c.m.163.com/recommend/getChanListNews?channel=T1457068979049&size=20";
    
    [sessionMgr GET:getstr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json = responseObject;
        weakSelf.dataArr = [WKVideoListItem mj_objectArrayWithKeyValuesArray:json[@"视频"]];
        [weakSelf.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取数据失败：%@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cell_Id = @"cell_id";
    WKVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_Id];
    if (cell == nil) {
        cell = [[WKVideoListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_Id];
        __weak typeof(self) weakSelf = self;
        cell.playBtnBlcok = ^(WKVideoListCell *cell) {
            [weakSelf clickPlayBtnWithCell:cell];
        };
    }
    
    WKVideoListItem *item = self.dataArr[indexPath.row];
    cell.videoItem = item;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

// 根据Cell位置隐藏并暂停播放
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.playIndex && _palyerView) {
        [_palyerView removePlayer];
        [_palyerView removeFromSuperview];
        _palyerView = nil;
    }
}

- (void)clickPlayBtnWithCell:(WKVideoListCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.playIndex = indexPath.row;
    CGRect cellF = [self.tableView rectForRowAtIndexPath:indexPath];
    self.palyerView.frame =
    CGRectMake(cellF.origin.x, cellF.origin.y, cellF.size.width, cellF.size.width * 0.56);
    [self.tableView addSubview:self.palyerView];
    
    self.palyerView.coverImage = cell.imgView.image;
    self.palyerView.name = cell.videoItem.title;
    [self.palyerView playWithViedeoUrl:cell.videoItem.mp4_url];
}

#pragma mark - WKPlayerViewDelegate

- (UIViewController *)getpresentViewController {
    return self.navigationController;
}

- (UIView *)getPlayerSuperView {
    return self.tableView;
}

#pragma mark - Getter

- (WKPlayerView *)palyerView {
    if (!_palyerView) {
        _palyerView = [[WKPlayerView alloc] init];
        _palyerView.delegate = self;
    }
    return _palyerView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.dataSource = self;
        tableView.delegate = self;
        _tableView = tableView;
        [self.view addSubview:tableView];
        
        _tableView.rowHeight = [WKVideoListCell cellHeight];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delaysContentTouches = NO;
        CGFloat h1 = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat h2 = self.navigationController.navigationBar.bounds.size.height;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
            _tableView.estimatedRowHeight = 0;
            if ([UIScreen mainScreen].bounds.size.height == 812) {
                if (@available(iOS 11.0, *)) {
                    _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                } else {
                    // Fallback on earlier versions
                }
                _tableView.contentInset = UIEdgeInsetsMake(h1 + h2, 0, 0, 0);
                _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(h1 + h2, 0, 0, 0);
            }
        } else {
            _tableView.contentInset = UIEdgeInsetsMake(h1 + h2, 0, 0, 0);
        }
    }
    return _tableView;
}

@end
