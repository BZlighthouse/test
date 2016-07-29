//
//  ViewController.m
//  UISwipeGestureRecognizerTest
//
//  Created by 周兵 on 16/7/25.
//  Copyright © 2016年 RNT. All rights reserved.
//

#import "ViewController.h"
//#import "VVC.swift"
#import "UISwipeGestureRecognizerTest-Swift.h"
#import <SocketIOClientSwift/SocketIOClientSwift-Swift.h>
#import "SocketRocket.h"

@interface ViewController ()<SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UILabel *swipeLabel;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@property (weak, nonatomic) IBOutlet UISwitch *s;
@property (nonatomic, assign) BOOL swich;

@property (nonatomic, strong) SocketIOClient* socket;

@property (nonatomic, strong) SRWebSocket *webSocket;
@end

@implementation ViewController
- (IBAction)buttonClick:(id)sender {
    
    //socketio
//    [self.socket emit:@"message" withItems:@[@{@"key" : @"vs"}]];
//    [self.socket emitWithAck:@"connect" withItems:@[@{@"key" : @"vs"}]](0, ^(NSArray* data) {
//        
//    });
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"id" : @"001", @"name" : @"zhoubing"} options:NSJSONWritingPrettyPrinted error:nil];
    
    [self.webSocket send:jsonData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //手势test
//    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
//    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
//    
//    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    
//    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
//    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    
    
    //socketIO
//    [self socketIOInit];
    
//    [self socketRocketInit];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        CGPoint labelPosition = CGPointMake(self.swipeLabel.frame.origin.x - 100.0, self.swipeLabel.frame.origin.y);
        [UIView animateWithDuration:0.5 animations:^{
            self.swipeLabel.frame = CGRectMake( labelPosition.x , labelPosition.y , self.swipeLabel.frame.size.width, self.swipeLabel.frame.size.height);
        }];
        self.swipeLabel.text = @"尼玛的, 你在往左边跑啊....";
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        CGPoint labelPosition = CGPointMake(self.swipeLabel.frame.origin.x + 100.0, self.swipeLabel.frame.origin.y);
        [UIView animateWithDuration:0.5 animations:^{
            self.swipeLabel.frame = CGRectMake( labelPosition.x , labelPosition.y , self.swipeLabel.frame.size.width, self.swipeLabel.frame.size.height);
        }];
        self.swipeLabel.text = @"尼玛的, 你在往右边跑啊....";
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.s.on) {
//        [self.socket connect];
        [self socketRocketInit];
    } else {
//        [self.socket disconnect];
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
    }
//    self.swich = !self.swich;
}

- (void)socketIOInit {
    NSURL* url = [[NSURL alloc] initWithString:@"http://chat.socket.io/"];
    self.socket = [[SocketIOClient alloc] initWithSocketURL:url options:@{@"log": @NO, @"forcePolling": @YES}];
    
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        self.s.on = YES;
    }];
    
    [self.socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket disconnected");
        self.s.on = NO;
    }];
    
    [self.socket on:@"currentAmount" callback:^(NSArray* data, SocketAckEmitter* ack) {
        double cur = [[data objectAtIndex:0] floatValue];
        
        [self.socket emitWithAck:@"canUpdate" withItems:@[@(cur)]](0, ^(NSArray* data) {
            [self.socket emit:@"update" withItems:@[@{@"amount": @(cur + 2.50)}]];
        });
        
        [ack with:@[@"Got your currentAmount, ", @"dude"]];
    }];
    
    [self.socket on:@"message" callback:^(NSArray * data, SocketAckEmitter * em) {
        NSLog(@"%@", data);
    }];
    
    [self.socket onAny:^(SocketAnyEvent * ev) {
        NSLog(@"======%@", ev.description);
    }];
    
    [self.socket connect];
}


#pragma mark - socketRocket
- (void)socketRocketInit {
    
    self.webSocket.delegate = nil;
    [self.webSocket close];
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://echo.websocket.org"]]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
	
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSData *data = (NSData *)message;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    self.s.on = NO;
    [self socketRocketInit];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    self.s.on = YES;
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    self.s.on = NO;
}
@end
