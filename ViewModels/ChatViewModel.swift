//
//  ChatViewModel.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation
import Combine

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
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        isLoading = true
        errorMessage = nil
        
        let request = ChatRequest(model: "gpt-3.5-turbo", messages: messages)
        
        chatService.sendMessage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if let reply = response.choices.first?.message {
                           self?.messages.append(reply)
                           print("API Response: \(response)")
                           print("First choice: \(reply.content)")
                       } else {
                           print("No AI reply in response: \(response)")
                           self?.errorMessage = "AI No Response"
                       }
                case .failure(let error):
                    print("API failure: \(error)")
                }
            }
        }
    }
}

