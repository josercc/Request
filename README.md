# Request

一个基于`Alamofire`库支持请求和数据上传的简单网络请求框架。

## Overview

`Request`请求库是基于单个请求配置，去发起请求，做相应的数据返回处理的网络处理框架。
单个请求配置区别于`Alamofire`直接请求的好处是，创建对应请求的配置文件。可以提前对于请求的参数进行验证，修饰等。对于多地方重用和团队合作使用，请求逻辑更加集中。
单个请求配置对于请求的可扩展和接口的升级和维护比传统的增强了不少。

## 安装
### Swift Package Manager
```swift
.package(url: "https://github.com/josercc/Request.git", from: "2.0.0")
```
> 目前只支持了`Swift Package Manager`的安装

## 使用

比如我们基于`https://www.xxx.com`域名进行说明，那么我们需要创建一个`API`协议的配置。
```swift
class SampleApi: API {

}
```
### 设置域名

我们实现`API`协议的`host`属性,值得注意的是。框架内部做了环境变量的支持，如果环境变量设置了`HOST`值，则优先读取`HOST`的值作为请求的域名。
```swift
class SampleApi: API {
    static var host: String {"https://www.xxx.com"}
}
```

### 例子

比如发送一个`GET`的网络请求
```swift
https://www.xxx.com/api/json?name=josercc
```
我们需要创建对应的网络请求配置

```swift
class SampleRequest: API {
    static var defaultHeadersConfig: ((inout HTTPHeaders) -> Void)?
    static var host: String {"https://www.xxx.com"}
}
```

我们创建一个请求的配置文件

```swift
struct SampleApi:APIConfig {
    var path: String {"/api/json"}
    var parameters: [String : Any]? {
        [
            "name":"josercc"
        ]
    }
}
```

我们还需要创建一个模型

```swift
struct SampleModel:Model {
    var _isSuccess: Bool {self._code == 0}
    var _code: Int {0}
    var _message: String {"success"}
}
```

这个模型需要根据实际返回需求来，这里就只是演示一下。

现在你就可以这样的发起请求了

```swift
SampleRequest.request(type: SampleModel.self,
                      config: SampleApi()) { model in

} failure: { code, message in

}
```

async/await的支持（2.3版本之后）

```swift
do {
    let model = try await SampleRequest.request(type:SampleModel.self, config)
    print(model)
}catch(e:NSError) {
    print("code:\(e.code) message:\(e.message)")
}
```

更新的详细信息请查阅[接口文档](https://josercc.github.io/Request)
