//
//  Request.swift
//  PinealAi
//
//  Created by 张行 on 2020/6/1.
//  Copyright © 2020 zhanghang. All rights reserved.
//

import Alamofire
import CleanJSON
import Foundation

/// 配置请求的全局函数
public protocol API: AnyObject {
    /// 设置请求的`Host` 如果在`Xcode`中设置变量`HOST`则优先使用变量`HOST`,否则就使用设置的请求`host`
    static var host:String {get}
    /// 配置默认`Headers`
    /// - headers: 当前请求`header`
    static var defaultHeadersConfig:((_ headers:inout HTTPHeaders) -> Void)? {get}
}


extension API {
    /// 获取当前请求的`URL`地址
    /// 如果在环境变量设置了`HOST`参数，则优先读取环境参数`HOST`的值
    static var url:String {
        if let host = ProcessInfo.processInfo.environment["HOST"] {
            return host
        } else {
            return self.host
        }
    }
    
    /// 获取请求的参数的编码格式
    /// 如果设置了编码则优先自定义编码类型
    /// 如果是`GET`则使用`URLEncoding.default`
    /// 如果是`POST`则使用`JSONEncoding.default`
    /// - Parameter config: 请求的配置
    /// - Returns: 请求参数的编码
    private static func requestEncoding(config:APIConfig) -> ParameterEncoding {
        if let confiEncoding = config.encoding {
            return confiEncoding
        } else if config.method == .get {
            return URLEncoding.default
        } else {
            return JSONEncoding.default
        }
    }
    /// 请求成功的回掉函数
    /// - Parameter model: 请求成功的模型（基于`Model`的范型对象）
    public typealias RequestSuccessHandle<M:Model> = (_ model:M) -> Void
    /// 请求失败的回掉函数
    /// - Parameter code: 失败的错误吗
    /// - Parameter message: 错误的原因
    public typealias RequestFailureHandle = (_ code:Int, _ message:String) -> Void
    
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public static func request<M:Model, A:APIConfig>(type:M.Type,
                                                     config:A) async throws -> M {
        try await withCheckedThrowingContinuation({ continuation in
            request(type: type, config: config, success: { model in
                continuation.resume(returning: model)
            }, failure: { code, message in
                continuation.resume(throwing: NSError(domain: message,
                                                      code: code,
                                                      userInfo: nil))
            })
        })
    }
    
    
    /// 发起一个请求（成功和失败回掉设置为可选值，是为了允许只发送请求不需要关心成功还是失败）
    /// - Parameter type: 请求的模型类型
    /// - Parameter config: 发起请求的实例(基于`APIConfig`协议的对象)
    /// - Parameter success: 发起请求成功的回掉
    /// - Parameter failure: 发起请求失败的回掉
    public static func request<M:Model, A:APIConfig>(type:M.Type,
                                                     config:A,
                                                     success:RequestSuccessHandle<M>?,
                                                     failure:RequestFailureHandle?) {
        let encoding:ParameterEncoding = requestEncoding(config: config)
        
        /// 配置发起请求的`Headers`
        var headers:HTTPHeaders = HTTPHeaders([])
        /// 如果编码是`JSONEncoding`编码，则在`Header`添加`Content-Type=application/json`
        if let _ = encoding as? JSONEncoding {
            headers.add(HTTPHeader(name: "Content-Type", value: "application/json"))
        }
        
        /// 添加全局的`Headers`和自定义的`Headers`
        /// 先添加`Content-Type=application/json`再添加全局的`Headers`之后是自定义的`Headers`，是为了单个请求的
        /// 配置可以重写`Headers`的某个字段的值
        addHeaders(with: config, in: &headers)
        
        /// 当前请求的域名 比如`https://www.baidu.com`
        let url = self.url
        
        let requestContent = """
        
        [request]:
        \(url)\(config.path)
        \(config.method)
        \(String(describing: config.parameters))
        \(String(describing: headers))
        
        """
        print(requestContent)
        /// 使用`Alamofire`发起请求
        AF.request("\(url)\(config.path)",
                   method: config.method,
                   parameters: config.parameters,
                   encoding: encoding,
                   headers: headers)
            .responseString {didReviceResponse(type: type,
                                               response: $0,
                                               decoder: config.decoder,
                                               success: success,
                                               failure: failure)}
    }
    
    @available(iOS 15.0.0, *)
    @available(macOS 12.0.0, *)
    public static func uploadFile<M:Model, A:APIConfig>(type:M.Type,
                                                        config:A,
                                                        fileData:Data) async throws -> M {
        try await withCheckedThrowingContinuation({ continuation in
            uploadFile(type: type, config: config, fileData: fileData, success: { model in
                continuation.resume(returning: model)
            }, failure: { code, message in
                continuation.resume(throwing: NSError(domain: message,
                                                      code: code,
                                                      userInfo: nil))
            })
        })
    }
    
    /// 上传文件服务
    /// - Parameter type: 接收模型的类型
    /// - Parameter config: 上传接口的配置
    /// - Parameter fileData: 上传的数据
    /// - Parameter success: 上传成功的回掉
    /// - Parameter failure: 上传失败的回掉
    public static func uploadFile<M:Model, A:APIConfig>(type:M.Type,
                                                        config:A,
                                                        fileData:Data,
                                                        success:RequestSuccessHandle<M>?,
                                                        failure:RequestFailureHandle?) {
        /// 添加上传文件头`Content-Type=multipart/form-data`
        var headers:HTTPHeaders = HTTPHeaders(["Content-Type":"multipart/form-data"])
        /// 添加全局的`Headers`和单个请求自定义的`Headers`
        addHeaders(with: config, in: &headers)
        
        /// 请求的域名 比如`https://www.baidu.com`
        let url = self.url
        let requestContent = """
        
        [request]:
        \(url)\(config.path)
        \(config.method)
        \(String(describing: config.parameters))
        \(String(describing: headers))
        
        """
        print(requestContent)
        
        /// 使用`Alamofire`进行文件上传服务
        AF.upload(multipartFormData: { (multipartFormData) in
            if let multipartFormDataHandle = config.multipartFormData {
                multipartFormDataHandle(multipartFormData)
            } else {
                /// 生成一个随机的上传文件名称
                let fileName = "\(Int(Date().timeIntervalSince1970))\(config.fileExtension)"
                multipartFormData.append(fileData, withName: "file", fileName: fileName)
                /// 添加文件路径参数
                let path = "iOS/\(fileName)"
                if let pathData = path.data(using: .utf8) {
                    multipartFormData.append(pathData, withName: "filePath")
                }
            }
        },
                  to: "\(url)\(config.path)",
                  method: config.method,
                  headers: headers,
                  requestModifier: {$0.timeoutInterval = 5 * 60})
            .responseString{didReviceResponse(type: type,
                                              response: $0,
                                              decoder: config.decoder,
                                              success: success,
                                              failure: failure)}
            .uploadProgress {config.uploadProgress?($0)}
    }
    
    /// 添加公共`Headers`和请求的自定义`Headers`
    /// - Parameter config: 请求的配置
    /// - Parameter headers: 需要修改的`Headers`对象指针
    private static func addHeaders<A:APIConfig>(with config:A,
                                                in headers:inout HTTPHeaders) {
        /// 配置公共的`Headers`
        defaultHeadersConfig?(&headers)
        /// 添加请求的自定义`Headers`
        if let configHeaders = config.headers {
            for (key,value) in configHeaders {
                headers.add(name: key, value: value)
            }
        }
    }
    
    /// 已经收到到请求的响应
    /// - Parameter type: 返回模型的类型
    /// - Parameter response: 请求响应
    /// - Parameter success: 请求成功的回掉
    /// - Parameter failure: 请求失败的回掉
    private static func didReviceResponse<M:Model, Decoder:JSONDecoder>(type:M.Type,
                                                   response:AFDataResponse<String>,
                                                   decoder:Decoder,
                                                   success:RequestSuccessHandle<M>?,
                                                   failure:RequestFailureHandle?) {
        /// 如果获取相应失败 则返回异常
        guard let urlResponse = response.response else {
            failure?(-1,"接口服务报错")
            return
        }
        
        let responseContent = """
        
        [response]:
        \(response.request?.url?.absoluteString ?? "")
        \(response.value ?? "\(urlResponse.statusCode)")
        
        """
        print(responseContent)
        
        guard let data = response.data else {
            if let failure = failure {
                failure(-1,"接口服务报错")
            }
            return
        }
        do {
            /// 尝试将返回的数据进行模型解析 如果解析失败 则返回解析失败的提示
            let model = try decoder.decode(type, from: data)
            /// 如果成功 则返回对应的模型信息 失败则返回对应失败信息
            if let success = success, model._isSuccess {
                success(model)
            } else if let failure = failure {
                let code = model._code
                var message = model._message
                if message.count == 0, let resultString = String(data: data, encoding: .utf8) {
                    message = resultString
                }
                failure(code,message)
            }
        } catch (let error) {
            print("[Error] \(error)")
            if let failure = failure {
                failure(-1,response.value ?? error.localizedDescription)
            }
        }
    }
}
