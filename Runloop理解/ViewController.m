//
//  ViewController.m
//  Runloop理解
//
//  Created by gaoguangxiao on 2018/7/31.
//  Copyright © 2018年 gaoguangxiao. All rights reserved.
//

#import "ViewController.h"
#import "GXThread.h"
@interface ViewController ()

@property (nonatomic,strong)GXThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testThread];
    
    //NSThread：
    //手动管理生命周期，开始一个生命周期，当任务执行完毕就会销毁
    
    //Runloop知识点1
//    1、延长线程的生命线，不会每次执行任务之后销毁
    
//    2、和NSTime用，解决在主线程之下，runloop运行在其他mode造成定时器 不能正常使用
}
- (IBAction)StartRunloop:(id)sender {
    //当子线程的任务执行完毕，线程就被立刻销毁。如果程序中，需要经常在子线程执行任务，频繁的创建和销毁线程，会造成资源的浪费，这时候就可以使用runloop来让该线程长时间存活而不被销毁
    
    
//    情形一：复用原来的线程，不去创建新的子线程
    [self performSelector:@selector(threadMethod) onThread:self.thread withObject:nil waitUntilDone:NO];
    
    //情形二：类似这样每次点击按钮发起一次网络请求，就创建一次子线程，任务执行完毕销毁子线程 造成资源的浪费
    
//    Runloop解决了，频繁的请求某个任务，在同一个线程执行，不会频繁的创建子线程。作用一：延长了线程存活的时间 / NSRunLoopCommonModes
    
//    [self testThread];
}


#pragma mark - test Thresd
/**
 * thread加入 runloop中的时候
 */
-(void)testThread{
    //NSThread：手动管理生命周期
    //动态创建
    GXThread *thread = [[GXThread alloc]initWithTarget:self selector:@selector(subThreadEntryPoint) object:nil];
    thread.name = @"高广校";
    [thread start];
    self.thread = thread;
    //静态创建
    //    [NSThread detachNewThreadSelector:@selector(saleTickt) toTarget:self withObject:nil];
    //    [NSThread detachNewThreadSelector:@selector(saleTickt) toTarget:self withObject:nil];
    
    //
//    GXThread *t = [[GXThread alloc]initWithTarget:self selector:@selector(threadMethod) object:nil];
//    t.name = @"ggx";
//    [t start];
//
//    self.thread = t;
}

/**
 子线程启动后，启动runloop
 */
- (void)subThreadEntryPoint{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    //如果注释了下面这一行，子线程中的任务并不能正常执行
    
    //NSMachPort 是什么玩意？
//    NSRunLoopCommonModes 包含三种model(kCFRunLoopDefaultMode、NSTaskDeathCheckMode、UITrackingRunLoopMode)
//    NSRunLoopCommonModes
    [runLoop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    NSLog(@"启动RunLoop前--%@",runLoop.currentMode);
    [runLoop run];
}

-(void)threadMethod{
    NSLog(@"runloop之后：%@",[NSRunLoop currentRunLoop].currentMode);
    
    NSLog(@"%@----子线程任务开始",[NSThread currentThread]);
    for (NSInteger i = 0; i < 10; i ++) {
        NSLog(@" i = %ld",i);
    }
    
    NSLog(@"%@----子线程任务结束",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
