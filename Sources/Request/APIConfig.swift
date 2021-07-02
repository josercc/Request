//
//  APIConfig.swift
//  
//
//  Created by 张行 on 2020/8/12.
//

import Foundation
import Alamofire

public protocol APIConfig {
    /// 请求的方法默认为`get`
    var method:HTTPMethod {get}
    /// 请求的路径
    var path:String {get}
    /// 请求的参数
    var parameters:[String:Any]? {get}
    /// 请求的头部
    var headers:[String:String]? {get}
    /// 请求的参数编码 默认`get`方法为`URLEncoding.default`, `post`为`JSONEncoding.default`
    var encoding:ParameterEncoding? { get }
    /// 文件上传的后缀 默认为`.png`
    var fileExtension:String { get }
    /// 上传文件的进度
    var uploadProgress:((Progress) -> Void)? { get }
}

public extension APIConfig {
    var method:HTTPMethod {.get}
    var parameters:[String:Any]? {nil}
    var headers:[String:String]? {nil}
    var encoding:ParameterEncoding? { nil }
    var fileExtension:String { ".png" }
    var uploadProgress:((Progress) -> Void)? { nil }
}
