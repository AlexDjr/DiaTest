//
//  LoginViewController.m
//  DiaTest
//
//  Created by Alex Delin on 11/05/2019.
//  Copyright © 2019 Alex Delin. All rights reserved.
//

#import "LoginViewController.h"
#import "AccessToken.h"

@interface LoginViewController () <UIWebViewDelegate>
@property (copy, nonatomic) LoginCompletionBlock completion;
@property (weak, nonatomic) UIWebView *webView;
@end

@implementation LoginViewController

- (id)initWithCompletionBlock:(LoginCompletionBlock)completion {
    self = [super init];
    if (self) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *requestString = request.URL.description;
    const BOOL isRequestContainAccessToken = [requestString rangeOfString:@"#access_token="].location != NSNotFound;
    
    if (isRequestContainAccessToken) {
        NSArray *accessTokenAttrPairs = [self obtainAccessTokenAttrPairsFromRequest:requestString];
        AccessToken *accessToken = [self accessTokenFromAttrPairs:accessTokenAttrPairs];
        
        if (self.completion) {
            self.completion(accessToken);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

#pragma mark - Methods
- (void)setupView {
    [self setupNavBar];
    [self setupCancelBarButton];
    
    NSURLRequest * request = [self setupURLRequest];
    [self setupWebViewWithRequest:request];
}

- (NSString *)setupNavBar {
    return self.navigationItem.title = @"Авторизация";
}

- (void)setupCancelBarButton {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:item animated:NO];
}

- (NSURLRequest *)setupURLRequest {
    NSString *urlString = [NSString stringWithFormat:
                           @"https://oauth.vk.com/authorize?"
                           "client_id=6984654&"
                           "display=mobile&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "scope=wall&"
                           "response_type=token&"
                           "v=5.95"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
}

- (void)setupWebViewWithRequest:(NSURLRequest *)request  {
    UIWebView *webView = [UIWebView new];
    webView.delegate = self;
    
    [self.view addSubview:webView];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [webView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    [webView loadRequest:request];
}

- (NSArray *)obtainAccessTokenAttrPairsFromRequest:(NSString *)query {
    NSString *accessTokenFullString = [[query componentsSeparatedByString:@"#"] lastObject];
    NSArray *accessTokenAttrPairs = [accessTokenFullString componentsSeparatedByString:@"&"];
    return accessTokenAttrPairs;
}

- (AccessToken *)accessTokenFromAttrPairs:(NSArray *)attrPairs {
    AccessToken *accessToken = [AccessToken new];
    for (NSString *attrPair in attrPairs) {
        [self setupAccessToken:accessToken fromAttrPair:attrPair];
    }
    return accessToken;
}

- (void)setupAccessToken:(AccessToken *)accessToken fromAttrPair:(NSString *)attrPair {
    NSArray *attributeComponents = [attrPair componentsSeparatedByString:@"="];
    
    const BOOL isCorrectAttrPair = [attributeComponents count] == 2;
    
    if (isCorrectAttrPair) {
        NSString *attributeKey = [attributeComponents firstObject];
        NSString *attributeValue = [attributeComponents lastObject];
        
        if ([attributeKey isEqualToString:@"access_token"]) {
            accessToken.token = attributeValue;
        } else if ([attributeKey isEqualToString:@"expires_in"]) {
            accessToken.expirationDate = [NSDate dateWithTimeIntervalSinceNow:[attributeValue doubleValue]];
        } else if ([attributeKey isEqualToString:@"user_id"]) {
            accessToken.userId = attributeValue;
        }
    }
}

#pragma mark - Actions
- (void)actionCancel:(UIBarButtonItem *)item {
    if (self.completion) {
        self.completion(nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
