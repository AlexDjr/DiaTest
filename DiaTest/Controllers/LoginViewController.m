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
    
    [self setupWebView];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //    проверяем, что полученный URL это ответ, содержащий в себе access_token
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        AccessToken *token = [[AccessToken alloc] init];
        
        //    делаем парсинг полученного ответа
        NSString *query = [[request URL] description];
        //    разбиваем строку на части по знаку #. Части складываем в массив
        NSArray *array = [query componentsSeparatedByString:@"#"];
        //    получаем часть после знака #
        if ([array count] > 1) {
            query = [array lastObject];
        }
        
        //    разбиваем строку на части по знаку &. Части складываем в массив
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            //    разбиваем строку на части по знаку =. Части складываем в массив
            NSArray *values = [pair componentsSeparatedByString:@"="];
            //    получаем значения ключа и значения
            if ([values count] == 2) {
                NSString *key = [values firstObject];
                //    если это access_token, то заполняем свойства нашего объекта token
                if ([key isEqualToString:@"access_token"]) {
                    token.token = [values lastObject];
                } else if ([key isEqualToString:@"expires_in"]) {
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                } else if ([key isEqualToString:@"user_id"]) {
                    token.userId = [values lastObject];
                }
            }
        }
        
        if (self.completion) {
            self.completion(token);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Methods
- (void)setupWebView {
    UIWebView *webView = [[UIWebView alloc] init];
    [self.view addSubview:webView];
    
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    [webView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    self.navigationItem.title = @"Авторизация";
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://oauth.vk.com/authorize?"
                           "client_id=6984654&"
                           "display=mobile&"
                           "redirect_uri=https://oauth.vk.com/blank.html&"
                           "scope=wall&"
                           "response_type=token&"
//                           "revoke=1&"
                           "v=5.95"];
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    webView.delegate = self;
    [webView loadRequest:request];
}

#pragma mark - Actions
- (void)actionCancel:(UIBarButtonItem *)item {
    if (self.completion) {
        self.completion(nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
