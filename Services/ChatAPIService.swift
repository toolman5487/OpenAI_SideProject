//
//  ChatAPIService.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation
import Alamofire

protocol ChatServiceProtocol {
    func sendMessage(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void)
}

final class ChatAPIService: ChatServiceProtocol {
    
    func sendMessage(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(APIConfiguration.apiKey)",
            "Content-Type": "application/json"
        ]

        print("發送請求到 OpenAI API...")
        
        let parameters: [String: Any] = [
            "model": request.model,
            "messages": request.messages.map { [
                "role": $0.role.rawValue,
                "content": $0.content
            ]}
        ]
        
        print("請求內容：\(parameters)")

        AF.request(
            APIConfiguration.baseURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate()
        .responseDecodable(of: ChatResponse.self) { response in
            switch response.result {
            case .success(let chatResponse):
                print("收到成功回應：\(chatResponse)")
                completion(.success(chatResponse))
            case .failure(let error):
                print("API 錯誤：\(error)")
                if let data = response.data,
                   let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("錯誤詳情：\(errorJson)")
                }
                completion(.failure(error))
            }
        }
    }
}
