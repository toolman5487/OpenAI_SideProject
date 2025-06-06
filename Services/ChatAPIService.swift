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
    
    private let session: Session
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        self.session = Session(configuration: configuration)
    }
    
    func sendMessage(request: ChatRequest, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(APIConfiguration.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": request.model,
            "messages": request.messages.map { [
                "role": $0.role.rawValue,
                "content": $0.content
            ]}
        ]

        session.request(
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
                completion(.success(chatResponse))
            case .failure(let error):
                if let data = response.data,
                   let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    completion(.failure(OpenAIError.apiError(errorResponse)))
                } else if let afError = error as? AFError {
                    completion(.failure(OpenAIError.networkError(afError)))
                } else {
                    completion(.failure(OpenAIError.networkError(error)))
                }
            }
        }
    }
}


struct OpenAIErrorResponse: Codable {
    let error: OpenAIErrorDetail
}

struct OpenAIErrorDetail: Codable {
    let message: String
    let type: String?
    let code: String?
}

enum OpenAIError: Error {
    case apiError(OpenAIErrorResponse)
    case invalidResponse
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .apiError(let response):
            return "API 錯誤：\(response.error.message)"
        case .invalidResponse:
            return "無效的回應格式"
        case .networkError(let error):
            if let afError = error as? AFError {
                switch afError {
                case .sessionTaskFailed(let underlyingError):
                    return "網路連接失敗：\(underlyingError.localizedDescription)"
                case .responseValidationFailed(let reason):
                    return "回應驗證失敗：\(reason)"
                case .responseSerializationFailed(let reason):
                    return "回應解析失敗：\(reason)"
                default:
                    return "網路錯誤：\(afError.localizedDescription)"
                }
            }
            return "網路錯誤：\(error.localizedDescription)"
        }
    }
}
