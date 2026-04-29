//
//  NetworkManager.swift
//  JXNetwork
//
//  Created by jikuan zhang on 2026/4/29.
//
//   核心请求管理者
import Foundation
// NetworkManager.swift
import Alamofire

@available(iOS 16.0, *)
public final class JXNetworkManager {
    public static let shared = JXNetworkManager()
    private init() {}
    
    // 核心：Alamofire Session（单例，配置SSL+拦截器）
    private let session: Session = {
        let config = JXNetworkConfig.shared
            // 1. 自定义 Session 配置（超时/缓存，替代默认 .default）
            let sessionConfig = URLSessionConfiguration.af.default
            sessionConfig.timeoutIntervalForRequest = 30 // 请求超时30s
            sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData // 禁用缓存
            
            // 2. 安全解析【纯主机名】（修复核心报错！）
            guard let host = URL(string: config.baseURL)?.host else {
                // 主机名解析失败，创建无SSL验证的Session
                return Session(configuration: sessionConfig, interceptor: JXNetworkInterceptor())
            }
            
            // 3. SSL证书校验：仅在开启+证书非空时配置
            var serverTrustManager: ServerTrustManager?
            if config.sslPinningEnabled, !config.pinnedCertificates.isEmpty {
                serverTrustManager = ServerTrustManager(
                    allHostsMustBeEvaluated: false, // 关闭强制验证所有域名（修复bug）
                    evaluators: [host: PinnedCertificatesTrustEvaluator(certificates: config.pinnedCertificates)]
                )
            }
            
            // 4. 初始化最终 Session
            return Session(
                configuration: sessionConfig,
                interceptor: JXNetworkInterceptor(),
                serverTrustManager: serverTrustManager
            )
    }()
    
    // MARK: 对外唯一请求方法（一行代码调用）
   public func request<T: JXRequestProtocol>(_ api: T) async throws -> T.Response {
        // 1. 构建请求
        let request = try buildRequest(api)
        
        // 2. 发送请求（Alamofire 原生 async/await）
        let response = await session.request(request)
            .validate() // 自动校验状态码 200..<300
            .serializingData()
            .response
        
        // 3. 统一错误处理
        switch response.result {
        case .success(let data):
            do {
                // 4. 自动解析 Codable 模型
                return try JSONDecoder().decode(T.Response.self, from: data)
            } catch {
                throw JXNetworkError.parsingFailed(error.localizedDescription)
            }
        case .failure(let error):
            throw handleAFError(error)
        }
    }
    
    // MARK: 私有方法：构建请求
    private func buildRequest<T: JXRequestProtocol>(_ api: T) throws -> URLRequest {
        guard let url = URL(string: JXNetworkConfig.shared.baseURL + api.path) else {
            throw JXNetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = api.method.rawValue
        request.allHTTPHeaderFields = api.headers
        // 参数编码
        switch api.encoding {
        case .urlEncoding:
            request = try URLEncoding.default.encode(request, with: api.parameters)
        case .jsonEncoding:
            request = try JSONEncoding.default.encode(request, with: api.parameters)
        }
        return request
    }
    
    // MARK: 私有方法：转换 Alamofire 错误为自定义错误
    private func handleAFError(_ error: AFError) -> JXNetworkError {
        // 1. 服务器信任/SSL错误（旧 isServerTrustError → 新 isServerTrustEvaluationError）
           if error.isServerTrustEvaluationError {
               return .sslInvalid
           }
           
           // 2. 会话任务/网络错误（旧 isSessionTaskError → 需判断底层URLError）
           if let underlyingError = error.underlyingError as? URLError {
               switch underlyingError.code {
               case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                   return .networkOffline
               default: break
               }
           }
           
           // 3. 响应码错误（旧 responseCode → 需从响应验证或response中获取）
           if let responseCode = error.responseCode {
               return .serverError(code: responseCode, msg: error.localizedDescription)
           }
           
           // 兜底：自定义错误
           return .custom(error.localizedDescription)
    }
}
