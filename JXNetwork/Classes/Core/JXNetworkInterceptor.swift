
//
//  NetworkIntercept.swift
//  JXNetwork
//
//  Created by jikuan zhang on 2026/4/29.
//

// 拦截/适配器

import Foundation
import Alamofire

/// 全局请求拦截器（Token注入 + 重试 + 日志）
public final class JXNetworkInterceptor: RequestInterceptor {
    private let config = JXNetworkConfig.shared
    
    // 1. 请求前适配器：自动注入Token、签名
    func adapt(_ urlRequest: URLRequest, for session: Session) async throws -> URLRequest {
        var request = urlRequest
        // 注入全局Token
        let token = UserDefaults.standard.string(forKey: "user_token") ?? ""
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    // 2. 重试策略：Token过期/网络异常自动重试
    func retry(_ request: Request, for session: Session, dueTo error: Error) async -> RetryResult {
        // 仅重试业务配置的次数
        guard let retryCount = request.request?.retryCount, retryCount > 0 else {
            return .doNotRetry
        }
        // Token过期：触发刷新逻辑
        if let afError = error as? AFError, afError.responseCode == 401 {
            await refreshToken()
            return .retry
        }
        // 网络异常：重试
        return .retryWithDelay(1)
    }
    
    /// 模拟Token自动刷新
    private func refreshToken() async {
        // 实现刷新Token逻辑，刷新后重新请求
    }
}

// 为URLRequest扩展重试次数属性
fileprivate extension URLRequest {
    var retryCount: Int {
        
        let count = value(forHTTPHeaderField: "X-Retry-Count")
//        return value(forHTTPHeaderField: "X-Retry-Count") ?? 0
        return 0
    }
}
