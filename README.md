# DKAttributeLabel
自己写的图文混排Label,可以满足基本社区类,IM类功能,可自行修改

##正则表达式解析
[#r{}#]
#r:点击事件
#f:表情
#l:链接

###Key for touch redirect 

    t: subType
    bc: background color
    bsc: background selected color
    tc: text color
    tsc: text selected color
    ct: conent show
    id:content id


##Usage

    DKAttributeLabel *label = [[DKAttributeLabel alloc]initWithFrame:CGRectMake(40, 40, [UIScreen mainScreen].nativeBounds.size.width/3-80, 200)];
    label.delegate = self;      
    label.text = @"大家好,我叫[#r:{\"t\":1,\"id\":0,\"ct\":\"陈独秀\"}#],[#f:1#][#f:2#][#f:3#][#f:4#][#f:4#] 我的我的我的我的我的网站是http://liudukun.com,lidukun.com,1.com,av.net,https://123,ftp://234,哈哈哈哈,我的帖子推荐给你:[#r:{\"t\":2,\"id\":1,\"ct\":\"第一次发帖哆哆asdfsdf关照,嗷嗷\",\"tc\":\"#ff0000\",\"bc\":\"#ffffff\"}#]";
    [self.view addSubview:label];
    

##Touch DKAttributeLabelDelegate 

    - (void)actionNode:(DKAttributeNode *)node {
        NSLog(@"action node ,content =%@",node.content);
    }

##End
