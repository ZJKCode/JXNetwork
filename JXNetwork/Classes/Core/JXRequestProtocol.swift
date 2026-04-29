//
//  RequestProtocol.swift
//  JXNetwork
//
//  Created by jikuan zhang on 2026/4/29.
//

// 抽象协议
import Foundation


/// HTTP 请求方法
public enum JXHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// 参数编码方式
public enum JXParameterEncoding {
    case urlEncoding
    case jsonEncoding
}

/// 网络请求协议（业务接口必须遵循）
public protocol JXRequestProtocol {
    /// 响应模型（Codable）
    associatedtype Response: Codable
    /// 接口路径
    var path: String { get }
    /// 请求方法
    var method: JXHTTPMethod { get }
    /// 请求参数
    var parameters: [String: Any]? { get }
    /// 请求头
    var headers: [String: String]? { get }
    /// 参数编码
    var encoding: JXParameterEncoding { get }
    /// 重试次数
    var retryCount: Int { get }
}

/// 默认实现（业务接口无需写冗余代码）
public extension JXRequestProtocol {
    var parameters: [String: Any]? { nil }
    var headers: [String: String]? { nil }
    var encoding: JXParameterEncoding { .jsonEncoding }
    var retryCount: Int { 0 }
}
