//
//  NetworkError.swift
//  JXNetwork
//
//  Created by jikuan zhang on 2026/4/29.
//
// 统一错误
import Foundation

public enum JXNetworkError: LocalizedError, Equatable {
    case invalidURL
    case parsingFailed(String)
    case serverError(code: Int, msg: String)
    case networkOffline
    case sslInvalid
    case tokenExpired
    case custom(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL 格式错误"
        case .parsingFailed(let info): return "数据解析失败：\(info)"
        case .serverError(let code, let msg): return "服务器错误[\(code)]：\(msg)"
        case .networkOffline: return "网络连接异常"
        case .sslInvalid: return "证书验证失败，请求被拦截"
        case .tokenExpired: return "登录已过期，请重新登录"
        case .custom(let msg): return msg
        }
    }
}
