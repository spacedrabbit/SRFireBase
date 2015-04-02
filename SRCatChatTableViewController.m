//
//  SRCatChatTableViewController.m
//  SRFirebaseScratchPad
//
//  Created by Louis Tur on 4/1/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

#import "SRCatChatTableViewController.h"
#import "UIColor+TubulrColors.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.numberOfMessagesInRecentHistory > 0 ? self.numberOfMessagesInRecentHistory : 1;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}*/


- (UITableViewCell *)createChatCellWithMessage:(NSString *)message {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSRChatBubbleCellIdentifier];
    
    return cell;
}

- (UITableViewHeaderFooterView *)createChatTextField{
    UITableViewHeaderFooterView *chatTextFieldFooter = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier: kSRChatTextFieldCellIdentifier];
    chatTextFieldFooter.backgroundColor = [UIColor srl_textFieldLightGrayColor];

    UITextField *chatTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [chatTextField setBorderStyle:UITextBorderStyleBezel];
    chatTextField.placeholder = @"Meoowww?";
    
    
    
    
    return chatTextFieldFooter;
}

@end
