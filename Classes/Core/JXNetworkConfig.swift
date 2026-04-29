//
//  NetworkConfig.swift
//  JXNetwork
//
//  Created by jikuan zhang on 2026/4/29.
//

// 全局配置
import Foundation
import Alamofire

public final class JXNetworkConfig {
    static let shared = JXNetworkConfig()
    private init() {}
    
    // 基础配置
    var baseURL: String = "https://api.xxx.com"
    var timeout: TimeInterval = 30
    var enableLog: Bool = true
    
    // 安全配置 - SSL Pinning（企业级必备）
    var sslPinningEnabled: Bool = true
    var pinnedCertificates: [SecCertificate] = []
    
    // 全局请求头
    var defaultHeaders: HTTPHeaders = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
}
