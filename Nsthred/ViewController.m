//
//  ViewController.m
//  Nsthred
//
//  Created by wordy on 2017/7/6.
//  Copyright © 2017年 golddatacommunications. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
    int tickets;
    int count;
    NSThread* ticketsThreadone;
    NSThread* ticketsThreadtwo;
    NSCondition* ticketsCondition;
    NSLock *theLock;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 创建方法: 1. 实例创建 2. 类方法创建
    // 手动管理线程
    
    // 1. 实例创建
    NSThread *myThread =   [[NSThread alloc] initWithTarget:self selector:@selector(downloadImage:) object:nil];
    [myThread start];
    // 2. 类方法创建
    [NSThread detachNewThreadSelector:@selector(downloadImage:) toTarget:self withObject:nil];
    
    
    // 线程同步
    tickets = 100;
    count = 0;
    theLock = [[NSLock alloc] init];
    // 锁对象,同步锁
    ticketsCondition = [[NSCondition alloc] init];

    ticketsThreadone = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [ticketsThreadone setName:@"thread1"];
    [ticketsThreadone start];
    
    ticketsThreadtwo = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [ticketsThreadtwo setName:@"thread2"];
    [ticketsThreadtwo start];
    

//        上面例子我使用了两种锁，一种NSCondition ，一种是：NSLock。 NSCondition我已经注释了。
//    还有其他的一些锁对象，比如：循环锁NSRecursiveLock，条件锁NSConditionLock，分布式锁NSDistributedLock等等,
    // 线程顺序执行
    /*
     他们都可以通过
     [ticketsCondition signal]; 发送信号的方式，在一个线程唤醒另外一个线程的等待。
     */
    //wait是等待，我加了一个 线程3 去唤醒其他两个线程锁中的wait
    NSThread *ticketsThreadthree = [[NSThread alloc] initWithTarget:self selector:@selector(run3) object:nil];
    [ticketsThreadthree setName:@"Thread-3"];
    [ticketsThreadthree start];
    
    
    
    
    
    
}
- (void)downloadImage:(NSString *)imageUrl
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    UIImage *image = [[UIImage alloc] initWithData:data];

    if (image ==nil) {
        
    }else
    {
        // 主线程刷新UI
        [self performSelectorOnMainThread:@selector(refreshUI:) withObject:nil waitUntilDone:YES];
    }
    
}
- (void)refreshUI:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)run
{
    
//    如果没有线程同步的lock，卖票数可能是-1.加上lock之后线程同步保证了数据的正确性。
    while (true) {
        //上锁
        [theLock lock];
        if (tickets > 0) {
            [NSThread sleepForTimeInterval:0.09];
            count = 100 - tickets;
            NSLog(@"当前票数是:%d,售出:%d,线程名:%@",tickets,count,[[NSThread currentThread] name]);
            tickets --;
        }else
        {
            break;
        }
        [theLock unlock]; //解锁
    }
}



- (void)run3
{
    while (YES) {
        [ticketsCondition lock];
        [NSThread sleepForTimeInterval:3];
        [ticketsCondition signal];
        [ticketsCondition unlock];
    }
}


//
//其他同步
//我们可以使用指令 @synchronized 来简化 NSLock的使用，这样我们就不必显示编写创建NSLock,加锁并解锁相关代码。
- (void)doSomeThing:(id)anObj
{
    
    // 这种方式==同步锁
    @synchronized(anObj)
    {
        // Everything between the braces is protected by the @synchronized directive.
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
