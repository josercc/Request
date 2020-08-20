//
//  Model.swift
//  
//
//  Created by 张行 on 2020/8/12.
//

import Foundation

public protocol Model:Codable {
    /// 接口是否成功
    var _isSuccess:Bool {get}
    /// 接口状态吗
    var _code:Int {get}
    /// 接口返回信息
    var _message:String {get}
}
