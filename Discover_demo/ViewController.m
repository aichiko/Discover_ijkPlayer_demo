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
    
    [self configTableView];
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
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

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
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"朋友圈";
    }else if (indexPath.row == 0 && indexPath.section == 1){
        cell.textLabel.text = @"ijkPlayer";
    }
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
