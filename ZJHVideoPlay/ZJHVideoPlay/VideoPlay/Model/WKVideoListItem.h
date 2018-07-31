//
//  WKVideoListItem.h
//  WuKongVideoPlayDemo
//
//  Created by ZhangJingHao2345 on 2018/3/14.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WKVideoListItem : NSObject

/**
 *  题目
 */
@property (nonatomic , copy) NSString * title;
/**
 *  描述
 */
@property (nonatomic , copy) NSString * Description;
/**
 *  图片
 */
@property (nonatomic , copy) NSString * cover;
/**
 *  时长
 */
@property (nonatomic , assign) CGFloat length;
/**
 *  播放数
 */
@property (nonatomic , copy) NSString * playCount;
/**
 *  时间
 */
@property (nonatomic , copy) NSString * ptime;
/**
 *  视频地址
 */
@property (nonatomic , copy) NSString * mp4_url;
/**
 *  播放来源title
 */
@property (nonatomic , copy) NSString * topicName;
/**
 *  播放来源图片
 */
@property (nonatomic , copy) NSString * topicImg;

@end
