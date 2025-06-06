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
            ChatMessage(role: .system, content: "You are a helpful assistant.")
        ]
    }
    
    func sendUserMessage(_ content: String) {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        
        let request = ChatRequest(model: "gpt-3.5-turbo", messages: messages)
        
        chatService.sendMessage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if let reply = response.choices.first?.message {
                        self?.messages.append(reply)
                    } else {
                        self?.errorMessage = "AI No Response"
                    }
                case .failure(let error):
                    if let afError = error as? AFError,
                       case let .responseValidationFailed(reason) = afError,
                       case let .unacceptableStatusCode(code) = reason,
                       code == 429 {
                        self?.errorMessage = "請求過於頻繁，請稍後再試"
                    } else {
                        self?.errorMessage = "API 錯誤：\(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

