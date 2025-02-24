//
//  UMengUFPViewController.m
//  ElongClient
//
//  Created by Dawn on 13-11-12.
//  Copyright (c) 2013年 elong. All rights reserved.
//

#import "UMengUFPViewController.h"
#import "UMTableViewCell.h"
#import "UMTableViewLoadingCell.h"

@interface UMengUFPViewController ()

@end

@implementation UMengUFPViewController

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    _mTableView.dataLoadDelegate = nil;
    [_mTableView removeFromSuperview];
    _mTableView = nil;
    [_mLoadingStatusLabel release];
    _mLoadingStatusLabel = nil;
    [_mLoadingActivityIndicator release];
    _mLoadingActivityIndicator = nil;
    [_mNoNetworkImageView release];
    _mNoNetworkImageView = nil;
    [_mLoadingWaitView removeFromSuperview];
    [_mLoadingWaitView release];
    _mLoadingWaitView = nil;
    self.delegate = nil;
    [super dealloc];
}

-(id)init:(NSString *)name style:(NavBtnStyle)style{
	if (self=[super init:name style:style]) {
        
	}
	return self;
}

#pragma mark - View lifecycle

- (void)setupLoadingWaitView
{
    _mLoadingWaitView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mLoadingWaitView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    _mLoadingWaitView.autoresizesSubviews = YES;
    _mLoadingWaitView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _mLoadingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-300)/2, 210, 300, 21)];
    _mLoadingStatusLabel.backgroundColor = [UIColor clearColor];
    _mLoadingStatusLabel.textColor = [UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:1.0];
    _mLoadingStatusLabel.font = [UIFont systemFontOfSize:15.0f];
    _mLoadingStatusLabel.text = @"正在加载数据，请稍等...";
    _mLoadingStatusLabel.textAlignment = UITextAlignmentCenter;
    _mLoadingStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_mLoadingWaitView addSubview:_mLoadingStatusLabel];
    
    _mLoadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _mLoadingActivityIndicator.backgroundColor = [UIColor clearColor];
    _mLoadingActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mLoadingActivityIndicator.frame = CGRectMake((self.view.bounds.size.width-30)/2, 170, 30, 30);
    [_mLoadingWaitView addSubview:_mLoadingActivityIndicator];
    
    [_mLoadingActivityIndicator startAnimating];
    
    [self.view insertSubview:_mLoadingWaitView aboveSubview:_mTableView];
}

/*
 该SDK同时兼容原有产品应用联盟（侧重换量，交叉推广）和友盟新产品UFP（侧重广告管理），创建各种样式相关的view时，需要传入的参数中包含appkey和slotid：
 1. 对于应用联盟的用户，appkey为必填字段，广告数据的获取将依赖于该字段，slotId传nil即可
 2. 对于UFP的用户，slotid为必填字段，广告数据的获取将依赖于该字段，appkey传nil即可
 3. 对于appkey和slotid都非空的情况，将默认按应用联盟处理, 请酌情使用
 */

- (void)setupTableView
{
    //如果设置了tableview的dataLoadDelegate，请在viewController销毁时将tableview的dataLoadDelegate置空，这样可以避免一些可能的delegate问题，虽然我有在tableview的dealloc方法中将其置空
    [UMUFPTableView setAppChannel:CHANNELID];
    _mTableView = [[UMUFPTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain appkey:UFP_KEY slotId:nil currentViewController:self];
    _mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mTableView.rowHeight = 70.0f;
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.backgroundColor = [UIColor clearColor];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mTableView.dataLoadDelegate = (id<UMUFPTableViewDataLoadDelegate>)self;
    [self.view addSubview:_mTableView];
    [_mTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.title = @"精彩推荐";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTableView];
    [self setupLoadingWaitView];
    
    [_mTableView requestPromoterDataInBackground];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    _mTableView.frame = self.view.bounds;
    
    if ([_mLoadingWaitView superview])
    {
        _mLoadingWaitView.frame = self.view.bounds;
    }
}

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0)
    {
        return [_mTableView.mPromoterDatas count] + 1;
    }
    else if (_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0)
    {
        return [_mTableView.mPromoterDatas count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UMUFPTableViewCell";
    
    if (indexPath.row < [_mTableView.mPromoterDatas count])
    {
        UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.row];
        cell.textLabel.text = [promoter valueForKey:@"title"];
        cell.detailTextLabel.text = [promoter valueForKey:@"ad_words"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        
        return cell;
    }
    else
    {
        UMTableViewLoadingCell *cell = (UMTableViewLoadingCell*)[tableView dequeueReusableCellWithIdentifier:@"UMTableViewLoadingCell"];
        if (cell == nil) {
            cell = [[[UMTableViewLoadingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UMTableViewLoadingCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.loadingLabel.text = @"加载中...";
        [cell.loadingIndicator startAnimating];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_mTableView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.row];
        [_mTableView didClickPromoterAtIndex:promoter index:indexPath.row];
    }
}

#pragma mark - UMTableViewDataLoadDelegate methods

- (void)removeLoadingMaskView {
    
    if ([_mLoadingWaitView superview])
    {
        [_mLoadingWaitView removeFromSuperview];
    }
}

- (void)loadDataFailed {
    
    _mLoadingActivityIndicator.hidden = YES;
    
    if (!_mNoNetworkImageView)
    {
        UIImage *image = [UIImage imageNamed:@"UMUFP.bundle/um_no_network.png"];
        CGSize imageSize = image.size;
        _mNoNetworkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_mLoadingWaitView.bounds.size.width - imageSize.width) / 2, 80, imageSize.width, imageSize.height)];
        _mNoNetworkImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _mNoNetworkImageView.image = image;
    }
    
    if (![_mNoNetworkImageView superview])
    {
        [_mLoadingWaitView addSubview:_mNoNetworkImageView];
    }
    
    _mLoadingStatusLabel.text = @"抱歉，网络连接不畅，请稍后再试！";
}

//该方法在成功获取广告数据后被调用
- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters {
    if ([self.delegate respondsToSelector:@selector(umengUFPVC:statusEnable:)]) {
        [self.delegate umengUFPVC:self statusEnable:YES];
    }
    if ([promoters count] > 0)
    {
        [self removeLoadingMaskView];
        
        [_mTableView reloadData];
    }
    else if ([_mTableView.mPromoterDatas count])
    {
        [_mTableView reloadData];
    }
    else
    {
        [self loadDataFailed];
    }
}

//该方法在获取广告数据失败后被调用
- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(umengUFPVC:statusEnable:)]) {
        [self.delegate umengUFPVC:self statusEnable:NO];
    }
    if ([_mTableView.mPromoterDatas count])
    {
        [_mTableView reloadData];
    }
    else
    {
        [self loadDataFailed];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize contentSize = scrollView.contentSize;
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    float y = contentOffset.y + bounds.size.height - contentInset.bottom;
    if (y > contentSize.height-30)
    {
        [_mTableView requestMorePromoterInBackground];
    }
}


@end
