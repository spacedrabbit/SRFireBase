//
//  SRFireBaseTableViewController.m
//  SRFirebaseScratchPad
//
//  Created by Louis Tur on 3/31/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

#import <Parse/Parse.h>
#import "UIColor+TubulrColors.h"
#import "SRFireBaseTableViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
static NSString * const kSRUserClass = @"users";
static NSString * const kSRAdminClass = @"admins";
static NSString * const kSRHeroImageCell = @"heroCell";
static NSString * const kSRUserNameFieldCell = @"usernameCell";
static NSString * const kSRPasswordFieldCell = @"passwordCell";
static NSString * const kSRLoginButtonsCell = @"loginButtonsCell";
static NSString * const kSRAuthenticationWarningCell = @"warningCell";

static NSUInteger heightForHeroImageCell = 256.0;
static NSUInteger heightForTextFieldCells = 44.0;
static NSUInteger heightForLoginButtonsCells = 52.0;
static NSUInteger heightForWarningCell = 44.0;

NS_ENUM(NSUInteger, SRCellPositions){
    heroCellPosition = 0,
    usernameCellPosition,
    passwordCellPosition,
    buttonsCellPosition,
    warningLabelCellPosition,
};

@interface SRFireBaseTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField * usernameField;
@property (strong, nonatomic) UITextField * passwordField;

@property (strong, nonatomic) UIImageView * iconImageView;
@property (strong, nonatomic) UIButton * loginButton;
@property (strong, nonatomic) UIButton * createAccountButton;
@property (strong, nonatomic) UILabel * authenticationIssueLabel;

typedef BOOL (^SRVerificationBlock)(NSString *);

@end

@implementation SRFireBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[UINavigationBar appearance] setBarTintColor:[UIColor srl_watchBlueColor]];
    [[UINavigationBar appearance] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Menlo" size:48.0],
                                                            NSForegroundColorAttributeName : [UIColor srl_baseBeige]}];
    
    self.tableView.backgroundColor = [UIColor srl_navBarPink];
    [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
    
}

#pragma mark - Some Text Field Validation
- (void)validateUserName:(void(^)(BOOL))success{
    
    __block NSString * usernameToValidate = self.usernameField.text.copy;
    __block SRVerificationBlock userNameIsUnique;
    BOOL usernameIsAtLeast6Characters = usernameToValidate.length >= 6;
    
    /* Note to future self if I ever go through this code again:
     *  Yes, I realise that I'm making this validation logic unnecessarily complicated
     *  There is no real reason to nest in all of these blocks, nor is it necessary to
     *  perform this crazy optimized search on such a small DB for such a simple check.
     *  I did it because I felt like it, and I was bored.
     *  Also, nesting the Parse call -[PFQuery findObjectsInBackgroundWithBlock:] inside of a block
     *  (in this case it originally was in an SRVerificationBlock) resulted in a warning
     *  to the tune of "a long running operation has been added to the main queue". So,
     *  in an effort to squelch this error, I decided to take a roundabout academic approach and
     *  redesigned this method to mirror what I may actually ahve to do if optimization
     *  was a factor.
     *
     *  As such, this code is more difficult to read than the method's functions may imply.
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        PFQuery * searchForExistingNameQuery = [PFQuery queryWithClassName:kSRUserClass];
        [searchForExistingNameQuery fromLocalDatastore];
        [searchForExistingNameQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects) {
                userNameIsUnique = ^BOOL(NSString * string){
                    
                    for (PFObject * userObject in objects) {
                        if ([userObject[@"name"] isEqualToString:string]) {
                            return NO;
                        }
                    }
                    return YES;
                };
            }
            
            success(userNameIsUnique(usernameToValidate) && usernameIsAtLeast6Characters);
        }];
    });
}

- (BOOL)validatePasswordEntry{
    
    NSString * passwordEntry = self.passwordField.text;
    BOOL hasAtLeast8Characters = passwordEntry.length >= 8;
    
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
    
    BOOL final = hasAtLeast8Characters
    && hasAtLeast1NonAlphaNumberic(passwordEntry)
    && hasAtLeast1UpperCase(passwordEntry);
    
    return final;
}

#pragma mark - Login / Create Account button logic

- (void)logInUser:(id) sender{
    
    __block NSString * usernameEntry = self.usernameField.text.copy;
    __block NSString * passwordEntry = self.passwordField.text.copy;
    
    PFQuery * lookForUser = [PFQuery queryWithClassName:kSRUserClass];
    [lookForUser fromLocalDatastore];
    
    [lookForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject * userObject in objects) {
                if ([userObject[@"name"] isEqualToString:usernameEntry] &&
                    [userObject[@"password"] isEqualToString:passwordEntry]) {
                    NSLog(@"User found and authenticated");
                }
            }
        }
    }];
    
}

- (void)createAccount:(id) sender{
    
    [self validateUserName:^(BOOL success){
        
        BOOL validPassword = [self validatePasswordEntry];
        if (success && validPassword) {
            
            PFObject * newUser = [PFObject objectWithClassName:kSRUserClass dictionary:@{@"name" : self.usernameField.text ,
                                                                                         @"password" : self.passwordField.text }];
            
            [newUser pinInBackgroundWithName:@"adminAdd" block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"User saved as: %@   --  %@", newUser[@"name"], newUser[@"password"]);
                }
            }];
        }else{
            NSLog(@"New user not valid");
        }
        
    }];
}


#pragma mark - TableView Delegation -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    switch (indexPath.row) {
        case heroCellPosition:
            cell = [self createHeroImageCell];
            break;

        case buttonsCellPosition:
            cell = [self createLoginButtonsCell];
            break;
            
        case usernameCellPosition:
            cell = [self createUsernameCell];
            break;
            
        case passwordCellPosition:
            cell = [self createPasswordCell];
            break;
            
        default:
            cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForTextFieldCells)];
            break;
    }
    
    cell.contentView.backgroundColor = [UIColor srl_navBarPink];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case heroCellPosition:
            return heightForHeroImageCell;
            break;
            
        case buttonsCellPosition:
            return heightForLoginButtonsCells;
            break;
            
        case warningLabelCellPosition:
            return heightForWarningCell;
            break;
            
        case usernameCellPosition:
        case passwordCellPosition:
            return heightForTextFieldCells;
            break;
            
        default:
            return 44.0;
            break;
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - Cell Creation -
-(UITableViewCell *) createHeroImageCell{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSRHeroImageCell];
    
    self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hungryCat"]];
    [self.iconImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.iconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [cell.contentView addSubview:self.iconImageView];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    return cell;
}

-(UITableViewCell *) createUsernameCell{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSRUserNameFieldCell];
    
    self.usernameField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.usernameField setClearsOnBeginEditing:YES];
    [self.usernameField setBorderStyle:UITextBorderStyleBezel];
    [self.usernameField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.usernameField.placeholder = @"username";
    self.usernameField.backgroundColor = [UIColor whiteColor];
    [self.usernameField setUserInteractionEnabled:YES];
    [self.usernameField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.usernameField setFont:[[self class] menloFontStyle]];
    self.usernameField.delegate = self;
    
    [cell.contentView addSubview:self.usernameField];

    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==20.0)-[_usernameField]-(==20.0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_usernameField)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_usernameField]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_usernameField)]];
    
    return cell;
}

-(UITableViewCell *) createPasswordCell{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSRPasswordFieldCell];
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.passwordField setClearsOnBeginEditing:YES];
    [self.passwordField setBorderStyle:UITextBorderStyleBezel];
    [self.passwordField setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.passwordField.placeholder = @"password";
    self.passwordField.backgroundColor = [UIColor whiteColor];
    [self.passwordField setUserInteractionEnabled:YES];
    [self.usernameField setFont:[[self class] menloFontStyle]];
    [self.passwordField setSecureTextEntry:YES];
    self.passwordField.delegate = self;
    
    [cell.contentView addSubview:self.passwordField];
    
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==20.0)-[_passwordField]-(==20.0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_passwordField)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_passwordField]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_passwordField)]];
    
    return cell;
}

-(UITableViewCell *) createLoginButtonsCell{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSRLoginButtonsCell];
    
    self.createAccountButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectZero];
    
    [self.createAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    [self.loginButton setBackgroundColor:[UIColor srl_deeperBlue]];
    [self.createAccountButton setBackgroundColor:[UIColor srl_deeperBlue]];
    
    [self.loginButton.layer setBorderColor:[UIColor srl_baseBeige].CGColor];
    [self.loginButton.layer setBorderWidth:2.0];
    [self.createAccountButton.layer setBorderColor:[UIColor srl_baseBeige].CGColor];
    [self.createAccountButton.layer setBorderWidth:2.0];
    self.loginButton.layer.cornerRadius = 10.0;
    self.createAccountButton.layer.cornerRadius = 10.0;
    
    [self.loginButton   setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.createAccountButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [cell.contentView addSubview:self.loginButton];
    [cell.contentView addSubview:self.createAccountButton];
    
    NSDictionary * buttonViews = NSDictionaryOfVariableBindings(_createAccountButton, _loginButton);
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==44.0)-[_loginButton]-[_createAccountButton(==_loginButton)]-(==44.0)-|"
                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                               metrics:nil
                                                                                 views:buttonViews]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_loginButton]-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:buttonViews]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_createAccountButton]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:buttonViews]];
    
    [self.loginButton addTarget:self action:@selector(logInUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.createAccountButton addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

+(UIFont *) menloFontStyle{
    return [UIFont fontWithName:@"Menlo" size:18.0];
}


#pragma mark - UITextField Delegates

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    if ([textField.text isEqualToString:@"username"] || [textField.text isEqualToString:@"password"]) {
        return YES;
    }else if([textField.text isEqualToString:@""]){
        [self restorePlaceholderText:textField];
    }
    return NO;
}

-(void)restorePlaceholderText:(UITextField *)textfield{
    if ([textfield isEqual:self.usernameField]) {
        textfield.placeholder = @"username";
    }
    if ([textfield isEqual:self.passwordField]){
        textfield.placeholder = @"password";
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
