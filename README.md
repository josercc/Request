# Request

一个基于八斗资讯提炼出来请求库，支持普通数据请求和上传文件。目前八斗资讯和数据收集系统都是用这个库开发的。

## 安装

```swift
.Package(url: "http://pineal.ai:30000/pineal-ios/sub-modules/Request.git", from: "2.0.0")
```

## 使用

新建一个`Class`实现`API`协议

```swift
public protocol API: AnyObject {
    /// 设置请求的`Host` 如果在`Xcode`中设置变量`HOST`则优先使用变量`HOST`,否则就使用设置的请求`host`
    static var host:String {get}
    /// 设置请求的`Mock` 如果在对应接口开启了`mock`则优先使用`mock`
    static var mock:String {get}
    /// 配置默认`Headers`
    /// - headers: 当前请求`header`
    static var defaultHeadersConfig:((_ headers:inout HTTPHeaders) -> Void)? {get}
}
```

例子

> ```swift
> public class PinealAiApi: API {
>     public static var host: String {
>         #if DEBUG
>         return "[DEBUG HOST]"
>         #else
>         return "[RELEASE HOST]"
>         #endif
>     }
>     public static var mock: String { "[MOCK HOST]" }
>     public static var defaultHeadersConfig: ((inout HTTPHeaders) -> Void)? {
>         return { (header:inout HTTPHeaders) in
>             var headers:[String:String] = [:]
> 
>             if let defaultHeadersConfig:(() -> [String:String]) = ControllerCenter.center.get(globaleParameter: "defaultHeadersConfig") {
>                 headers = defaultHeadersConfig()
>             }
>             for (key,value) in headers {
>                 header.add(name: key, value: value)
>             }
>         }
>     }
> }
> ```

新建一个`Struct`或者`Class`实现`Model`协议

```swift
public protocol Model:Codable {
    /// 接口是否成功
    var _isSuccess:Bool {get}
    /// 接口状态吗
    var _code:Int {get}
    /// 接口返回信息
    var _message:String {get}
}
```

例子

> ```swift
> public struct BaseModel<T:Codable> :Model {
>     public var _isSuccess: Bool {self.code == 0}
>     public var _code: Int {self.code}
>     public var _message: String {self.message}
>     
>     public let message:String
>     public let code:Int
>     public let success:Bool
>     public let data:T?
> }
> ```

每个对应接口实现`APIConfig`协议

```swift
public protocol APIConfig {
    /// 请求的方法默认为`get` 可选
    var method:HTTPMethod {get}
    /// 请求的路径
    var path:String {get}
    /// 请求的参数 可选
    var parameters:[String:Any]? {get}
    /// 请求的头部 可选
    var headers:[String:String]? {get}
    /// 请求的参数编码 默认`get`方法为`URLEncoding.default`, `post`为`JSONEncoding.default` 可选
    var encoding:ParameterEncoding? { get }
}
```

例子

> ```swift
> public struct AutoIssuer:APIConfig {
>     public var path: String { "/bond/autoIssuer" }
>     public var parameters: [String : Any]?
>     struct Parameter:Encodable {
>         let keyWord:String
>     }
>     /// 根据搜索的内容获取关联的债券发行人的名称
>     /// - Parameters:
>     ///   - keyWord: 搜索的名称
>     ///   - success: 成功的回掉
>     ///   - failure: 失败的回掉
>     public static func request(keyWord:String,
>                                success:@escaping(([String]?) -> Void),
>                                failure:@escaping((Int,String) -> Void)) {
>         let parameter = Parameter(keyWord: keyWord)
>         let api = AutoIssuer(parameters: parameter.toParameters())
>         PinealAiApi.request(type: BaseModel<[String]>.self, config: api, success: { (model) in
>             success(model.data)
>         }, failure: failure)
>     }
> }
> ```

将一个`Encodable`转换为字典

```swift
extension Encodable {

    /// 将一个`Encodable`编码为字典
    /// - Returns: 参数字典
    public func toParameters() -> [String : Any]?
}
```

