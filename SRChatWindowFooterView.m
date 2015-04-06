//
//  SRChatWindowFooterView.m
//  SRFirebaseScratchPad
//
//  Created by Louis Tur on 4/6/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

#import "SRChatWindowFooterView.h"
#import "UIColor+TubulrColors.h"
#import <VBFPopFlatButton/VBFPopFlatButton.h>

static NSString * const kSRChatBubbleCellIdentifier = @"chatBubbleCell";
static NSString * const kSRChatTextFieldCellIdentifier = @"chatTextField";

static NSUInteger minimumHeightForChatTextField = 44.0;
static NSUInteger maximumHeightForChatTextField = 88.0;

@interface SRChatWindowFooterView ()

@property (strong, nonatomic) UIView * sendButtonContainerView;

@end

@implementation SRChatWindowFooterView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createChatTextField];
    }
    return self;
}

-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (void)createChatTextField{
    UIView * chatContentView = [[UIView alloc] initWithFrame:CGRectZero];
    [chatContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:chatContentView];
    
    UITextField *chatTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [chatTextField setBorderStyle:UITextBorderStyleBezel];
    [chatTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    chatTextField.placeholder = @"Meoowww?";
    
    self.sendButtonContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.sendButtonContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [chatContentView addSubview:chatTextField];
    [chatContentView addSubview:self.sendButtonContainerView];
    
    NSDictionary * viewsDictionary = NSDictionaryOfVariableBindings(chatTextField, chatContentView, _sendButtonContainerView);
    NSDictionary * viewMetrics = @{
                                    @"cellHeight" : @(minimumHeightForChatTextField),
                                    @"buttonSize" : @(44.0)
                                    };
    
    NSDictionary * footViewDictionary = @{ @"content": chatContentView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[content]|" options:0 metrics:nil views:footViewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[content]|" options:0 metrics:nil views:footViewDictionary]];
    
    [chatContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[chatTextField]-[_sendButtonContainerView(==buttonSize)]-|"
                                                                                            options:NSLayoutFormatAlignAllCenterY
                                                                                            metrics:viewMetrics
                                                                                              views:viewsDictionary]];
    [chatContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[chatTextField]-|"
                                                                                            options:0
                                                                                            metrics:viewMetrics
                                                                                              views:viewsDictionary]];
    [chatContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_sendButtonContainerView(==buttonSize)]"
                                                                                            options:0
                                                                                            metrics:viewMetrics
                                                                                              views:viewsDictionary]];
}

-(void) animatedSendButtonInView{
    VBFPopFlatButton * sendButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectZero buttonType:buttonAddType buttonStyle:buttonRoundedStyle animateToInitialState:NO];
    [sendButton setLineThickness:3.0];
    [sendButton setTintColor:[UIColor srl_linkNormalOrangeColor] forState:UIControlStateNormal];
    [sendButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [sendButton addTarget:self action:@selector(sendMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary * buttonViews = @{ @"button" : sendButton };
    [sendButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|" options:0 metrics:nil views:buttonViews]];
    [sendButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:buttonViews]];
}

-(void)sendMessageTapped:(VBFPopFlatButton *)buttonSender{
    [buttonSender animateToType:buttonUpBasicType];
    
}

+(BOOL)requiresConstraintBasedLayout{
    return YES;
}

@end
