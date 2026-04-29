//
//  ViewController.swift
//  JXNetwork
//
//  Created by 8746235 on 04/28/2026.
//  Copyright (c) 2026 8746235. All rights reserved.
//

import UIKit
import JXNetwork

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 3. 发起请求
        // 修复后写法
        Task {
            do {
                let user = try await JXNetworkManager.shared.request(GetUserInfoAPI())
                print("获取用户信息：", user)
            } catch {
                let netError = error as! JXNetworkError
                print("错误：", netError.errorDescription)
            }
        }
        
        // MARK: 2. 调用：外部动态传参
        Task {
            do {
                // 🔥 动态传入用户ID 1001
                let user = try await JXNetworkManager.shared.request(GetUserInfoAPI2(userId: 1001))
                print("用户信息：", user)
            } catch {
                print(error.localizedDescription)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

struct UserModel: Codable {
    let id: Int
       
    let nickname: String
}

/// 获取用户信息接口
struct GetUserInfoAPI: JXRequestProtocol {
    typealias Response = UserModel
    var path: String = "/user/info"
    var method: JXHTTPMethod = .get
    var parameters: [String: Any]? = ["user_id": 1001]
    var retryCount: Int = 2
}

import JXNetwork

// MARK: 1. 动态传参接口：遵循协议，自定义动态属性
struct GetUserInfoAPI2: JXRequestProtocol {
    // 🔥 动态入参：外部调用时传入
    let userId: Int
    
    // 协议固定规范
    typealias Response = UserModel
    let path: String = "/user/info"
    let method: JXHTTPMethod = .get
    
    // 🔥 核心：计算属性 → 动态生成入参
    var parameters: [String : Any]? {
        return [
            "user_id": userId, // 动态参数
            "platform": "ios"  // 固定参数（可选）
        ]
    }
}

struct ListModel: Codable {
    
}

struct GetListAPI: JXRequestProtocol {

    // 多个动态参数
    let page: Int
    let pageSize: Int
    let keyword: String? // 可选参数
    
    typealias Response = [ListModel]
    let path: String = "/goods/list"
    let method: JXHTTPMethod = .post
    
    // 动态拼接参数
    var parameters: [String : Any]? {
        var params: [String: Any] = [
            "page": page,
            "size": pageSize
        ]
        // 可选参数判空
        if let keyword = keyword {
            params["keyword"] = keyword
        }
        return params
    }
}

// 调用
let api = GetListAPI(page: 1, pageSize: 20, keyword: "手机")
