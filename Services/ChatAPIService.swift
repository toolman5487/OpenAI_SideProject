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

        AF.request(
            APIConfiguration.baseURL,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        .validate()
        .responseDecodable(of: ChatResponse.self) { response in
            switch response.result {
            case .success(let chatResponse):
                completion(.success(chatResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
