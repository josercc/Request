//
//  File.swift
//  
//
//  Created by 张行 on 2020/8/12.
//

import Foundation

extension Encodable {
    /// 将一个`Encodable`编码为字典
    /// - Returns: 参数字典
    public func toParameters() -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(self), let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
            return nil
        }
        return obj
    }
}
