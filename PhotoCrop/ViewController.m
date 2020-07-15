//
//  ViewController.m
//  PhotoCrop
//
//  Created by liudukun on 2020/4/19.
//  Copyright © 2020 liudukun. All rights reserved.
//

#import "DKAttributeLabel.h"
#import "ViewController.h"

@interface ViewController ()<DKAttributeLabelDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    ///  测试 ct 中包含 \]
    DKAttributeLabel *label = [[DKAttributeLabel alloc]initWithFrame:CGRectMake(40, 40, [UIScreen mainScreen].nativeBounds.size.width/3-80, 200)];
    label.delegate = self;
    
    label.text = @"大家好,我叫[#r:{\"t\":1,\"id\":0,\"ct\":\"陈独##[]秀\"}#],[#f:1#][#f:2#][#f:3#][#f:4#][#f:4#] 我的我的我的我的我的网站是http://liudukun.com,lidukun.com,1.com,av.net,https://123,ftp://234,哈哈哈哈,我的帖子推荐给你:[#r:{\"t\":2,\"id\":1,\"ct\":\"第一次发帖哆哆asdfsdf关照,嗷嗷\",\"tc\":\"#ff0000\",\"bc\":\"#ffffff\"}#]";
    label.text = @"大家好,我叫]";
    [self.view addSubview:label];
    
     [label getHeight];
}





- (void)actionNode:(DKAttributeNode *)node {
    NSLog(@"action node ,content =%@",node.content);
}


@end
