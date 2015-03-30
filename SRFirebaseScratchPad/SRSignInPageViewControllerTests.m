//
//  SRSignInPageViewControllerTests.m
//  SRFirebaseScratchPad
//
//  Created by Louis Tur on 3/29/15.
//  Copyright (c) 2015 Louis Tur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SRSignInPageViewController.h"

@interface SRSignInPageViewControllerTests : XCTestCase

@property (strong, nonatomic) SRSignInPageViewController * signInVC;

@end

@implementation SRSignInPageViewControllerTests

- (void)setUp {
    [super setUp];

    self.signInVC = [[SRSignInPageViewController alloc] init];
    
}

- (void)tearDown {

    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssertNotNil(self.signInVC, @"Intial ViewController should not be nil");

}

- (void)testRootViewShoulBeRed{
    
    XCTAssertNotNil(self.signInVC.view, @"Root view should not be nil");
    XCTAssertTrue([self.signInVC.view.backgroundColor isEqual:[UIColor redColor]], @"Root view should be red");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
