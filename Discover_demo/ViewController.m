//
//  ViewController.m
//  Discover_demo
//
//  Created by 24hmb on 16/9/5.
//  Copyright © 2016年 24hmb. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(reloadTableView:)];
    
    [self configTableView];
}

- (void)reloadTableView:(UIBarButtonItem *)button {
    [self.tableView reloadData];
}

- (void)configTableView {
    @weakify(self)
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.edges.equalTo(self.view);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1?3:1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"discoverCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"discoverCell"];
    }
    cell.textLabel.numberOfLines = 0;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"朋友圈";
    }else if (indexPath.row == 0 && indexPath.section == 1){
        cell.textLabel.text = @"ijkPlayer";
    }else {
        cell.textLabel.text = @"ijkPlayer\nijkPlayer\nijkPlayer\nijkPlayer";
    }
//    UILabel *accessoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 44)];
//    accessoryLabel.textAlignment = NSTextAlignmentRight;
//    accessoryLabel.font = [UIFont systemFontOfSize:12];
//    accessoryLabel.textColor = [UIColor colorWithRed:0.22 green:0.71 blue:0.28 alpha:1];
//    accessoryLabel.adjustsFontSizeToFitWidth = YES;
//    cell.accessoryView = accessoryLabel;
//    accessoryLabel.text = @"直播";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"discover" sender:nil];
    }else if (indexPath.row == 0 && indexPath.section == 1){
        [self performSegueWithIdentifier:@"ijkPlayer" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
