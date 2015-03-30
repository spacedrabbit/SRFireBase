//
//  SRSignInPage.m
//  SRFirebaseScratchPad
//
//  Created by Louis Tur on 3/29/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

#import "UIColor+TubulrColors.h"
#import "SRSignInPageViewController.h"
#import <Parse/Parse.h>

static NSString * const kSRUserClass = @"users";
static NSString * const kSRAdminClass = @"admins";

@interface SRSignInPageViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIView      * containerView;
@property (strong, nonatomic) UIScrollView * scrollView;
@property (strong, nonatomic) UITextField * usernameField;
@property (strong, nonatomic) UITextField * passwordField;
@property (strong, nonatomic) UIImageView * iconImageView;

@property (strong, nonatomic) UIButton * loginButton;
@property (strong, nonatomic) UIButton * forgotPasswordButton;
@property (strong, nonatomic) UIButton * createAccountButton;

@property (strong, nonatomic) UILabel * authenticationIssueLabel;

typedef BOOL (^SRVerificationBlock)(NSString *);

@end

@implementation SRSignInPageViewController

#pragma mark - Overriden UIViewController Methods
-(void)loadView{
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.containerView setBackgroundColor:[UIColor srl_navBarPink]];
    [self.view setBackgroundColor:[UIColor srl_navBarPink]];
    
    [self setTitle:@"lè chat"];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    
    [self.view          addSubview:self.scrollView];
    [self.scrollView    addSubview:self.containerView];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.usernameField.delegate = nil;
    self.passwordField.delegate = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor srl_watchBlueColor]];
    [[UINavigationBar appearance] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Menlo" size:48.0],
                                                            NSForegroundColorAttributeName : [UIColor srl_baseBeige]}];
    
    
    

}

-(void)viewDidLoad;{
    [super viewDidLoad];
    
    [self addLoginFieldsAndIcon];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
}

#pragma mark - Some Text Field Validation
- (BOOL)validateUserName{
    
    __block NSString * usernameToValidate = self.usernameField.text.copy;
    
    SRVerificationBlock usernameIsAtLeast6Characters = ^BOOL(NSString * string){
        return string.length >= 6;
    };
    
    SRVerificationBlock usernameIsUnique = ^BOOL(NSString * string){

        PFQuery * searchForExistingNameQuery = [PFQuery queryWithClassName:kSRUserClass];
        [searchForExistingNameQuery fromLocalDatastore];
        NSArray * locatedUsers = [searchForExistingNameQuery findObjects];
        
        for (PFObject * userObject in locatedUsers) {
            if ([userObject[@"name"] isEqualToString:string]) {
                return NO;
            }
        }
        return YES;
    };
    
    return usernameIsAtLeast6Characters(usernameToValidate) && usernameIsUnique(usernameToValidate);
}

- (BOOL)validatePasswordEntry{
    
    NSString * passwordEntry = self.passwordField.text;
    SRVerificationBlock hasAtLeast8Characters = ^BOOL(NSString *string){
        return string.length >= 8;
    };
    
    SRVerificationBlock hasAtLeast1NonAlphaNumberic = ^BOOL(NSString *string){
        NSCharacterSet * nonAlphaSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSRange nonAlphaRange = [string rangeOfCharacterFromSet:nonAlphaSet];

        return nonAlphaRange.location == NSNotFound ? NO : YES;
    };
    
    SRVerificationBlock hasAtLeast1UpperCase = ^BOOL(NSString *string){
        NSCharacterSet * upperSet = [NSCharacterSet uppercaseLetterCharacterSet];
        NSRange uppercaseRange = [string rangeOfCharacterFromSet:upperSet];
        
        return uppercaseRange.location == NSNotFound ? NO : YES;
    };
    
    BOOL final = hasAtLeast8Characters(passwordEntry)
                    && hasAtLeast1NonAlphaNumberic(passwordEntry)
                    && hasAtLeast1UpperCase(passwordEntry);

    return final;
}

- (void)logInUser:(id) sender{
   
    PFQuery * lookForUser = [PFQuery queryWithClassName:kSRUserClass];
    [lookForUser fromLocalDatastore];
    
    [lookForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"All things: %@", objects);
        }
    }];
    
}

- (void)createAccount:(id) sender{
    
    if ([self validatePasswordEntry] && [self validateUserName]) {
        PFObject * newUser = [PFObject objectWithClassName:kSRUserClass dictionary:@{@"name" : self.usernameField.text ,
                                                                                     @"password" : self.passwordField.text }];
        
        [newUser pinInBackgroundWithName:@"adminAdd" block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"User saved as: %@   --  %@", newUser[@"name"], newUser[@"password"]);
            }
         }];

    }
    else{
        NSLog(@"New user not valid");
    }
}

#pragma mark - Views Setup
- (void)addLoginFieldsAndIcon{
    
    self.usernameField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.usernameField setClearsOnBeginEditing:YES];
    [self.passwordField setClearsOnBeginEditing:YES];
    [self.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.passwordField  setBorderStyle:UITextBorderStyleBezel];
    self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hungryCat"]];
    [self.iconImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.createAccountButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.createAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[UIColor blueColor]];
    [self.createAccountButton setBackgroundColor:[UIColor purpleColor]];
    
    [self.loginButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.createAccountButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.loginButton setReversesTitleShadowWhenHighlighted:YES];
    [self.createAccountButton setReversesTitleShadowWhenHighlighted:YES];
    
    [self.loginButton setShowsTouchWhenHighlighted:YES];
    [self.createAccountButton setShowsTouchWhenHighlighted:YES];
    
    self.loginButton.layer.cornerRadius = 10.0;
    self.createAccountButton.layer.cornerRadius = 10.0;
    
    [self.iconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.usernameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.passwordField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView    setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.loginButton   setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.createAccountButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.containerView addSubview:self.iconImageView];
    [self.containerView addSubview:self.usernameField];
    [self.containerView addSubview:self.passwordField];
    [self.containerView addSubview:self.loginButton];
    [self.containerView addSubview:self.createAccountButton];
    
    self.usernameField.placeholder = @"username";
    self.passwordField.placeholder = @"password";
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.usernameField.backgroundColor = [UIColor whiteColor];
    
    [self.usernameField setUserInteractionEnabled:YES];
    [self.passwordField setUserInteractionEnabled:YES];
    [self.scrollView setUserInteractionEnabled:YES];
    [self.containerView setUserInteractionEnabled:YES];
    
    [self.usernameField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.usernameField setFont:[UIFont fontWithName:@"Menlo" size:24.0]];
    [self.passwordField setFont:[UIFont fontWithName:@"Menlo" size:24.0]];
    [self.passwordField setSecureTextEntry:YES];
    
    NSDictionary * signInPageUIElements = @{ @"username" : self.usernameField,
                                             @"password" : self.passwordField,
                                             @"icon"     : self.iconImageView,
                                             @"container" : self.containerView,
                                             @"super" : self.view,
                                             @"scrollView" : self.scrollView,
                                             @"login" : self.loginButton,
                                             @"create" : self.createAccountButton};
    
    NSDictionary * sizeKeys = @{ @"iconSideSize" : @(256.0),
                                 @"width" : @([UIScreen mainScreen].bounds.size.width),
                                 @"height" : @([UIScreen mainScreen].bounds.size.height),
                                 @"buttonHeight" : @(30.0)};
    
    // -- Scroll View -- //
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:signInPageUIElements]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:signInPageUIElements]];

    
    // -- Container View -- //
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[container(==height)]|"
                                                                             options:0
                                                                             metrics:sizeKeys
                                                                              views:signInPageUIElements]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container(==width)]|"
                                                                            options:0
                                                                            metrics:sizeKeys
                                                                              views:signInPageUIElements]];
    
    // -- Container view -- //
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==20.0)-[icon(==iconSideSize)]-[username]-[password]-[login(==buttonHeight)]-[create(==buttonHeight)]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:sizeKeys
                                                                        views:signInPageUIElements]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==20.0)-[username]-(==20.0)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:signInPageUIElements]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==20.0)-[password]-(==20.0)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:signInPageUIElements]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==64.0)-[login]-(==64.0)-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:signInPageUIElements]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==64.0)-[create]-(==64.0)-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:signInPageUIElements]];
    
    [self.loginButton addTarget:self action:@selector(logInUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.createAccountButton addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Helpers
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self dismissKeyboard];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    textField.text = @"";
    return YES;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dismissKeyboard{
    [self.view endEditing:YES];
}

#pragma mark - Delegate Methods (Scroll & Text)
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"Yes touches");
    for (UITouch * touch in touches) {
        if (![touch.view isEqual:self.usernameField] || ![touch.view isEqual:self.passwordField]) {
            [self dismissKeyboard];
        }
    }
    
}

#pragma mark - Observers
-(void)toggleKeyboard:(id)notification{
    
    NSNotification * keyboardNotification = (NSNotification *)notification;
    if ([keyboardNotification.name isEqualToString:UIKeyboardDidShowNotification]) {
        
        NSDictionary * userInfo = keyboardNotification.userInfo;
        NSValue * keyboardKVCValue = [userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameFromKVCValue = [keyboardKVCValue CGRectValue];
        
        [self.scrollView setContentOffset:CGPointMake(0, keyboardFrameFromKVCValue.size.height * .5) animated:YES];
        
    }else if( [keyboardNotification.name isEqualToString:UIKeyboardDidHideNotification]){
        [self.scrollView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
    }
    
    
}

@end
