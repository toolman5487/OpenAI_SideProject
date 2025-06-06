//
//  ChatViewModel.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation
import Combine
import Alamofire

final class ChatViewModel: ObservableObject {
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private let chatService: ChatServiceProtocol
    
    init(chatService: ChatServiceProtocol) {
        self.chatService = chatService
        self.messages = [
            ChatMessage(role: .system, content: "你是一個有用的助手。")
        ]
    }
    
    func sendUserMessage(_ content: String) {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        
        let request = ChatRequest(model: "gpt-3.5-turbo", messages: messages)
        
        print("準備發送訊息：\(content)")
        
        chatService.sendMessage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    print("收到回應：\(response)")
                    if let reply = response.choices.first?.message {
                        self?.messages.append(reply)
                    } else {
                        self?.errorMessage = "AI 沒有回應"
                        print("錯誤：AI 沒有回應")
                    }
                case .failure(let error):
                    print("發生錯誤：\(error)")
                    if let afError = error as? AFError {
                        switch afError {
                        case .responseValidationFailed(let reason):
                            switch reason {
                            case .unacceptableStatusCode(let code):
                                switch code {
                                case 401:
                                    self?.errorMessage = "API 金鑰無效"
                                case 429:
                                    self?.errorMessage = "請求過於頻繁，請稍後再試"
                                case 500:
                                    self?.errorMessage = "OpenAI 伺服器錯誤"
                                default:
                                    self?.errorMessage = "API 錯誤 (狀態碼: \(code))"
                                }
                            default:
                                self?.errorMessage = "回應驗證失敗：\(reason)"
                            }
                        case .responseSerializationFailed:
                            self?.errorMessage = "無法解析回應"
                        case .sessionTaskFailed(let error):
                            if let urlError = error as? URLError {
                                switch urlError.code {
                                case .notConnectedToInternet:
                                    self?.errorMessage = "無網路連線"
                                case .timedOut:
                                    self?.errorMessage = "連線超時"
                                default:
                                    self?.errorMessage = "網路錯誤：\(urlError.localizedDescription)"
                                }
                            } else {
                                self?.errorMessage = "網路錯誤：\(error.localizedDescription)"
                            }
                        default:
                            self?.errorMessage = "API 錯誤：\(afError.localizedDescription)"
                        }
                    } else {
                        self?.errorMessage = "未知錯誤：\(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

