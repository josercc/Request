//
//  APIConfig.swift
//  
//
//  Created by 张行 on 2020/8/12.
//

import Foundation
import Alamofire

/// 请求`API`的设置
///
/// 我们需要将实现这个协议，重写一些属性完成我们请求的配置。这个协议会默认实现一个简单的请求，请求方式为`GET`，没有任何参数，没有任何`Header`参数。
///
/// 默认`GET`请求参数编码为`URLEncoding.default`,`POST`的请求参数编码为`JSONEncoding.default`
///
/// 上传文件的默认后缀名称为`.png`
///
/// 比如一个简单的`GET`的请求`https://xxx.xxx.com/api/json?name=josercc`
/// ```swift
///     struct SampleApi: APIConfig {
///         var path: String { "/api/json" }
///         var parameters: [String : Any] {
///             [
///                 "name":"josercc"
///             ]
///         }
///     }
/// ```
public protocol APIConfig {
    /// 请求的方法默认为`get`
    /// 更多的支持的请求方式请查看`HTTPMethod`相关信息
    var method:HTTPMethod {get}
    /// 请求的路径
    /// 需要和`API.host`组成一个请求链接
    /// 比如`https://xxx.xxx.com/api/json?name=josercc`
    /// 如果设置`API.hos=https://xxx.xxx.com`，那么此时的`path="/api/json"`
    /// 如果设置`API.hos=https://xxx.xxx.com/`，那么此时的`path="api/json"`
    var path:String {get}
    /// 请求的参数
    /// 如果请求为`GET`则为`Path Parameter`
    /// 如果请求为`POST`则为`Body Parameter`
    var parameters:[String:Any]? {get}
    /// 请求的头部
    /// 设置公共的头部信息请在`API.defaultHeadersConfig`进行设置
    var headers:[String:String]? {get}
    /// 请求的参数编码 默认`get`方法为`URLEncoding.default`, `post`为`JSONEncoding.default`
    var encoding:ParameterEncoding? { get }
    /// 文件上传的后缀 默认为`.png`
    var fileExtension:String { get }
    
    /// 上传进度的回掉
    /// - Parameter progress: 上传的当前进度
    typealias UploadProgressHandle = (_ progress:Progress) -> Void
    /// 上传文件的进度
    var uploadProgress:UploadProgressHandle? { get }
    
    /// 上传文件设置自定义参数的回掉
    /// - Parameter multipartFormData: 上传文件`MultipartFormData`对象
    typealias MultipartFormDataHandle = (_ multipartFormData:MultipartFormData) -> Void
    /// 设置自定义上传
    var multipartFormData:MultipartFormDataHandle? {get}
}

public extension APIConfig {
    var method:HTTPMethod {.get}
    var parameters:[String:Any]? {nil}
    var headers:[String:String]? {nil}
    var encoding:ParameterEncoding? { nil }
    var fileExtension:String { ".png" }
    var uploadProgress:((Progress) -> Void)? { nil }
    var multipartFormData:MultipartFormDataHandle? {nil}
}
