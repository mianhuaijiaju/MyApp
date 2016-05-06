//
//  TestViewController.m
//  MyApp
//
//  Created by 王崇 on 16/5/5.
//  Copyright © 2016年 wangchong. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.searchBar];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    searchBar.frame = CGRectMake(0, 20, self.view.bounds.size.width, 30);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    searchBar.frame = CGRectMake(0, 64, self.view.bounds.size.width, 30);
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 30)];
        _searchBar.searchBarStyle = UISearchBarStyleProminent;
        _searchBar.delegate = self;
    }
    return _searchBar;
}

@end
