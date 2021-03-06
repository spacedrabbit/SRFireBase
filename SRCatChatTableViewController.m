//
//  SRCatChatTableViewController.m
//  SRFirebaseScratchPad
//
//  Created by Louis Tur on 4/1/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

#import "SRChatWindowFooterView.h"
#import "SRCatChatTableViewController.h"
#import "UIColor+TubulrColors.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

static NSUInteger maximumMarginFromTextBubbleToEdge = .25;
static NSString * const kSRChatBubbleCellIdentifier = @"chatBubbleCell";
static NSString * const kSRChatTextFieldCellIdentifier = @"chatTextField";

static NSUInteger minimumHeightForChatTextField = 44.0;
static NSUInteger maximumHeightForChatTextField = 88.0;
    
@interface SRCatChatTableViewController () <UITextFieldDelegate>

@property (nonatomic) NSUInteger numberOfMessagesInRecentHistory;
@property (nonatomic) BOOL hasSentFirstMessage;

@property (strong, nonatomic) UITextField * chatInput;

@property (strong, nonatomic) NSDictionary * chatLog;

@end

@implementation SRCatChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor srl_baseBeige]];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfMessagesInRecentHistory > 0 ? self.numberOfMessagesInRecentHistory : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSRChatBubbleCellIdentifier];
    if (!cell) {
        cell = [self createChatCellWithMessage:@"Test"];
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * footer;
    if (section == 0) {
        footer = [[SRChatWindowFooterView alloc] init];
    }
    return footer;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return minimumHeightForChatTextField;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return minimumHeightForChatTextField;
}

#pragma mark - Cell Creation

- (UITableViewCell *)createChatCellWithMessage:(NSString *)message {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSRChatBubbleCellIdentifier];
    [cell setBackgroundColor:[UIColor srl_baseBeige]];
    cell.contentView.backgroundColor = [UIColor srl_baseBeige];
    cell.textLabel.text = message;
    
    return cell;
}

@end
