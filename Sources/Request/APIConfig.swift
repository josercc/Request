//
//  APIConfig.swift
//  
//
//  Created by 张行 on 2020/8/12.
//

import Foundation

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
}

extension APIConfig {
    public var method:HTTPMethod {.get}
    public var parameters:[String:Any]? {nil}
    public var headers:[String:String]? {nil}
    public var encoding:ParameterEncoding? { nil }
}
