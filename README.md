iOS 开发周报
===
2017年02月6-10日
___

###1.app有关图片的内存优化
我们平时开发项目过程中经常会写有关UIImage图片的加载显示，而UIImage加载图片的方式无非也就两种，一种是通过`imageWithContentsOfFile:`，另一种是通过`imageNamed:`，虽然最终都可以达到加载图片的目的，但是这两种方法是有很大不同的。

* imageWithContentsOfFile: 这种方式加载图片首先图片不能放在ImageAssets，需要直接拖到项目文件中，通过`- (nullable NSString *)pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext`方式找到图片路径，然后加载成NSData，最后转成UIImage对象。这种加载方式产生的NSData和UIImage都是局部变量，当执行完该代码所处方法时会被自动释放，如果下次需要加载该图片资源又得重新加载。
	* 优点：UIImage对象的生命周期可以被管理，需要的时候创建一个，不需要的时候就会自动销毁，不会长期在内存中保存。
	* 缺点：加载相同图片资源时仍多次去沙盒中加载图片，造成不必要的内存消耗

* imageNamed: 这种方式加载图片对图片位置没有限定，编译器在通过这种方式去加载图片时，会先去一个字典中通过图片名作为key查找有没有对应的UIImage对象，如果有就直接使用这个对象，否则就重新加载然后保存在该字典中
	* 优点：图片资源第一次加载会留在内存中，下次使用时不会重复加载会继续复用之前的图片
	* 缺点：由于存储加载图片的字典是强引用，字典不释放图片资源也不会释放并且伴随整个app生命周期

* 解决办法，可以使用imageWithContentsOfFile:方式让图片对象的生命周期可控，同事借鉴imageNamed:方式来做内存上的处理。具体方法有两个(这里[github](https://github.com/Magic-Unique/HXImage/blob/master/description.md)里面说的很详细这里我简化了其中一种)。
	* 一种是循环存放图片对象的字典，如果该对象的引用计数为1则手动释放该对象(在MRC中可以直接读取对象的引用计数retainCount，ARC中则需要通过KVC的方式读取`[[self valueForKey:@"retainCount"] unsignedLongValue]`)
	* 另一种是用弱引用字典的形式让字典里的图片对象在没有被强引用引用时自动释放，实现弱引用字典的方式就是通过block封装解封实现的：
```objc
typedef id (^WeakReference)(void);
WeakReference makeWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}
id weakReferenceNonretainedObjectValue(WeakReference ref) {
    return ref ? ref() : nil;
}
``` 

综上所诉，通过创建一个UIIMage分类重写imageName:方法来替换原有图片加载方法


___

###2.链式调用的 DSL
* 基本样式：在没有使用链式调用情况下我们创建一个UIView的方式是这样的：
```objc
UIView *aView = [[[[UIView alloc] initWithFrame:aFrame] bgColor:aColor] intoView:aSuperView];
```
如果使用链式调用可以变成这样：
```objc
UIView *dslView = AllocA(UIView).with.postion(128, 300).size(120, 120).color([UIColor cyanColor]).intoView(self.view);
```
* 具体实现：链式调用主要有两种实现方式
	* 一种是在返回值中使用属性来保存方法中的信息，例如：Masonry中的`.left .right .top .bottom`调用时会返回一个 MASConstraintMaker 类的实例，里面有 left/right/top/bottom 等属性来保存每次调用时的信息，直到调用赋值方法(如`.offset(15)`)给它们赋值
	* 另一种是使用block类型的属性来接受参数，比如Masonry中的`.offset(15)`通过的就是block传入15
* 对应代码`AllocA(UIView)`创建一个makerHelper对象同时记录需要创建的类，`.with`则是使用第一种方式但是返回的是maker对象用于配置后面的属性,`.postion(128, 300).size(120, 120).color([UIColor cyanColor]).intoView(self.view)`则是使用的第二种方式通过block方式将对应的数值传入