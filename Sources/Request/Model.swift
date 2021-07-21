//
//  Model.swift
//  
//
//  Created by 张行 on 2020/8/12.
//

import Foundation

/// 响应数据的基础模型，可以根据自己的数据结构去实现
public protocol Model:Codable {
    /// 接口是否成功
    /// 比如如果`code=0`代表成功 那么此时可以这样重写
    /// ```swift
    ///     var _isSuccess:Bool { self._code == 0 }
    /// ```
    var _isSuccess:Bool {get}
    /// 接口状态吗
    var _code:Int {get}
    /// 接口返回信息
    var _message:String {get}
}
