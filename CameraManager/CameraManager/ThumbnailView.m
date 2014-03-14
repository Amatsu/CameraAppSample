//
//  ThumbnailView.m
//  CameraManager
//
//  Created by Amatsu on 2014/01/26.
//  Copyright (c) 2014年 Amatsu. All rights reserved.
//

#import "ThumbnailView.h"

@implementation ThumbnailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint p = CGPointZero;
    p.x += 5;
    for (UIImage* image in _imageList) {
        
        UIImageView *iv = [[UIImageView alloc] initWithImage:image];
        iv.userInteractionEnabled = YES;
        
        CGRect frame = iv.frame;
        frame.origin.x = p.x;
        frame.origin.y = 10;
        frame.size.height = 50;
        frame.size.width = 50;
        iv.frame = frame;
        
        p.x += iv.frame.size.width + 10;
        
        [iv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTap:)]];
        [self addSubview:iv];
        
    }
    
}

//画像選択イベント
- (void)imgTap: (UITapGestureRecognizer *)sender{
    //[(UIImageView *)sender image];
    
    //イベントを発生させる
    NSNotification *n = [NSNotification notificationWithName:@"FUKIDASHI_TAP" object:sender.view];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}



@end
