# RunLoop

引入链接：https://www.jianshu.com/p/b80a8d4484e6
一、概述
二、runloop和线程的关系
一、概述
一般来讲，一个线程一次只能执行一个任务，执行完毕后线程就会退出。如果我们需要一个机制，让线程能够随时处理事件但不退出。通常的代码逻辑是这样的：
function loop() {
    initialize();
    do {
        var message = get_next_message();
        process_message(message);
    } while (message != quit);
}
看起来很像是 do-while循环，这种模型通常被称为EventLoop。EventLoop在需要系统和框架中都有实现，比如Node.js，Windows程序的消息循环。实现这种模型的关键点就是没有处理消息时避免被资源占用，在有消息来临的时候即时处理。

OSX/iOS 系统，提供了这两个对象，NSRunloop和CFRunloopRef。
CFRunLoopRef 是在 CoreFoundation 框架内的，它提供了纯 C 函数的 API，所有这些 API 都是线程安全的。
NSRunLoop 是基于 CFRunLoopRef 的封装，提供了面向对象的 API，但是这些 API 不是线程安全的。

二、runloop和线程的关系
1、每条线程都有唯一一个与之对应的Runloop；
2、子线程的Runloop需要手动创建，主线程的Runloop已经创建好了；
3、Runloop第一获取时创建，线程结束时销毁。
苹果不允许直接创建Runloop，它只提供了两个自动获取的函数，
CFRunloopGetMain()和CFRunloopGetCurrent();
/// 全局的Dictionary，key 是 pthread_t， value 是 CFRunLoopRefstatic CFMutableDictionaryRef loopsDic;/// 访问 loopsDic 时的锁static CFSpinLock_t loopsLock; /// 获取一个 pthread 对应的 RunLoop。CFRunLoopRef _CFRunLoopGet(pthread_t thread) {    OSSpinLockLock(&loopsLock);        if (!loopsDic) {        // 第一次进入时，初始化全局Dic，并先为主线程创建一个 RunLoop。        loopsDic = CFDictionaryCreateMutable();        CFRunLoopRef mainLoop = _CFRunLoopCreate();        CFDictionarySetValue(loopsDic, pthread_main_thread_np(), mainLoop);    }        /// 直接从 Dictionary 里获取。    CFRunLoopRef loop = CFDictionaryGetValue(loopsDic, thread));        
if (!loop) {        
/// 取不到时，创建一个        
loop = _CFRunLoopCreate();        
CFDictionarySetValue(loopsDic, thread, loop);        
/// 注册一个回调，当线程销毁时，顺便也销毁其对应的 RunLoop。        
_CFSetTSD(..., thread, loop, __CFFinalizeRunLoop);    
}        
OSSpinLockUnLock(&loopsLock);    
return loop;
} 
CFRunLoopRef CFRunLoopGetMain() {    return _CFRunLoopGet(pthread_main_thread_np());} CFRunLoopRef CFRunLoopGetCurrent() {    return _CFRunLoopGet(pthread_self());}
线程刚创建的时候是没有Runloop的，如果不主动获取，就永远不会有。
[NSRunloop CurrentRunloop]方法调用，会查看字典有没有对应的runloop，如果有直接返回runloop，如果没有就会创建一个，并写入字典中。
