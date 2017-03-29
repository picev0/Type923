//
//  ViewController.m
//  Type923
//
//  Created by 村田 秀平 on 2014/08/06.
//  Copyright (c) 2014年 suppdev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    BOOL isTitle;
    UITextView *tv;
    UILabel *lb1;
    UILabel *lb2;
    UIImageView *ivt4;
    UIImageView *ivt5;
    NSMutableString *str;
    NSMutableString *buf;
    NSString *directoryPath;
    NSString *filename;
    NSURL *path;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //走行予想、どの区間を走行しているか表示予定
    //走行予定、区間の表示
    
    lb1 = [[UILabel alloc] init];
    lb1.frame = CGRectMake(30, 30, 250, 60);
    lb1.text = @"次回の走行まで、";
    lb1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:lb1];
    
    lb2 = [[UILabel alloc] init];
    lb2.frame = CGRectMake(55, 90, 235, 60);
    lb2.text = @"あと「11」日（8/18）です。";
    lb2.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:lb2];
    
    //同期通信
    
    // request
    directoryPath =
    [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    //ダウンロードファイルの保存先
    
    NSString *filePath =
    [[directoryPath stringByAppendingPathComponent:filename]
      stringByStandardizingPath];            //保存したファイルへのパス
    
    //NSString *urlsv = @"http://t923back.esy.es/jikoku/txt/answer.csv";
    NSURL *url1 = [NSURL URLWithString:@"http://t923back.esy.es/jikoku/txt/answer.csv"];
    
    /*
    NSString *str = [NSString stringWithContentsOfURL:url1 encoding:NSShiftJISStringEncoding error:&err];
    
    //Write
    //path = [filePath URLByAppendingPathComponent:filename];
    NSString *url2 = [urlsv stringByAppendingString:filename];
    
    BOOL result = [str writeToURL:filePath atomically:YES encoding:NSUTF8StringEncoding];
    if (result == NO) break;
    */
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url1];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [
                    NSURLConnection
                    sendSynchronousRequest : request
                    returningResponse : &response
                    error : &error
                    ];
     
    
    
    
    // error
    NSString *error_str = [error localizedDescription];
    if (0<[error_str length]) {
        UIAlertView *alert = [
                              [UIAlertView alloc]
                              initWithTitle : @"RequestError"
                              message : error_str
                              delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil
                              ];
        [alert show];
        //[alert release];
        //return cell;
    }
     
    
    // responseを受け取ったあとの処理
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createFileAtPath:filePath contents:[NSData data] attributes:nil];
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [file writeData:data];
    
    
    //T4画像を表示
    UIImage *imt4 = [UIImage imageNamed:@"T4.jpg"];
    ivt4 = [[UIImageView alloc] initWithImage:imt4];
    [ivt4 sizeToFit];
    ivt4.frame = CGRectMake(35, 160, 250, 150);
    [self.view addSubview:ivt4];
    
    //T5画像を表示
    UIImage *imt5 = [UIImage imageNamed:@"T5.jpg"];
    ivt5 = [[UIImageView alloc] initWithImage:imt5];
    [ivt5 sizeToFit];
    ivt5.frame = CGRectMake(35, 160, 250, 150);
    [self.view addSubview:ivt5];
    
    //RSS表示
    tv = [[UITextView alloc] init];
    tv.frame = CGRectMake(30, 350, 300, 110);
    tv.editable = YES;
    
    str = [[NSMutableString alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://snow.advenbbs.net/bbs/yybbs.cgi?id=Type923&mode=rss"];
    NSXMLParser *ps
    = [[NSXMLParser alloc] initWithContentsOfURL:url];
    ps.delegate = self;
    [ps parse];
    
    [self.view addSubview:tv];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [UIApplication sharedApplication]
    .networkActivityIndicatorVisible = YES;
    isTitle = NO;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"title"]){
        isTitle = YES;
        buf = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"title"]){
        isTitle = NO;
        [str appendString:buf];
        [str appendString:@"\n\n"];
        buf = nil;
    }
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    if(isTitle == YES){
        [buf appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    tv.text = str;
    [UIApplication sharedApplication]
    .networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
