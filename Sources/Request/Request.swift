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

public protocol API: AnyObject {
    /// 设置请求的`Host` 如果在`Xcode`中设置变量`HOST`则优先使用变量`HOST`,否则就使用设置的请求`host`
    static var host:String {get}
    /// 配置默认`Headers`
    /// - headers: 当前请求`header`
    static var defaultHeadersConfig:((_ headers:inout HTTPHeaders) -> Void)? {get}
}


extension API {
    static var url:String {
        if let host = ProcessInfo.processInfo.environment["HOST"] {
            return host
        } else {
            return self.host
        }
    }
    
    /// 根据路径获取对应的请求地址 如果开启`mock`返回对应`mock`
    /// - Parameter path: 请求路径
    /// - Returns: 该路径对应的请求地址
    private static func requestURL(path:String) -> String {
        return url
    }

    private static func requestEncoding(config:APIConfig) -> ParameterEncoding {
        var encoding:ParameterEncoding
        if config.method == .get {
            encoding = URLEncoding.default
        } else {
            encoding = JSONEncoding.default
        }
        if let confiEncoding = config.encoding {
            encoding = confiEncoding
        }
        return encoding
    }
    
    public static func request<T:Model>(type:T.Type, config:APIConfig, success:((T) -> Void)?, failure:((Int,String) -> Void)?) {
        var headers:HTTPHeaders = HTTPHeaders([])
        defaultHeadersConfig?(&headers)
        let encoding:ParameterEncoding = requestEncoding(config: config)
        if let _ = encoding as? JSONEncoding {
            headers.add(HTTPHeader(name: "Content-Type", value: "application/json"))
        }
        if let configHeaders = config.headers {
            for (key,value) in configHeaders {
                headers.add(name: key, value: value)
            }
        }
        let url = requestURL(path: config.path)
        
        let requestContent = """
        
        [request]:
        \(url)\(config.path)
        \(config.method)
        \(String(describing: config.parameters))
        \(String(describing: headers))
        
        """
        print(requestContent)
        AF.request("\(url)\(config.path)", method: config.method, parameters: config.parameters, encoding: encoding, headers: headers).responseString { (response) in
            didReviceResponse(type: type, response: response, success: success, failure: failure)
        }
    }
    
    public static func uploadFile<T:Model>(type:T.Type, config:APIConfig, fileData:Data, success:((T) -> Void)?, failure:((Int,String) -> Void)?) {
        let headers:HTTPHeaders = HTTPHeaders(["Content-Type":"multipart/form-data"])
        let url = requestURL(path: config.path)
        let requestContent = """
        
        [request]:
        \(url)\(config.path)
        \(config.method)
        \(String(describing: config.parameters))
        \(String(describing: headers))
        
        """
        print(requestContent)
        AF.upload(multipartFormData: { (multipartFormData) in
            let fileName = "\(Int(Date().timeIntervalSince1970)).png"
            multipartFormData.append(fileData, withName: "file", fileName: fileName)
            let path = "iOS/\(fileName)"
            if let pathData = path.data(using: .utf8) {
                multipartFormData.append(pathData, withName: "filePath")
            }
        }, to: "\(url)\(config.path)", method: config.method, headers: headers).responseString { (response) in
            didReviceResponse(type: type, response: response, success: success, failure: failure)
        }
    }
    
    private static func didReviceResponse<T:Model>(type:T.Type, response:AFDataResponse<String>, success:((T) -> Void)?, failure:((Int,String) -> Void)?) {
        guard let urlResponse = response.response else {
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
            let model = try CleanJSONDecoder().decode(type, from: data)
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
                failure(-1,response.value ?? "解析数据模型报错")
            }
        }
    }
}
