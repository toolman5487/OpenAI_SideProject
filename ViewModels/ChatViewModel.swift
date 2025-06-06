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
    private var chatRoom: ChatRoom
    
    init(chatRoom: ChatRoom, chatService: ChatServiceProtocol) {
        self.chatRoom = chatRoom
        self.chatService = chatService
        self.messages = chatRoom.messages.isEmpty ? [ChatMessage(role: .system, content: "你是一個有用的助手。")] : chatRoom.messages
    }
    
    func sendUserMessage(_ content: String) {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        let userMessage = ChatMessage(role: .user, content: content, status: .sending)
        messages.append(userMessage)
        
        if chatRoom.title.isEmpty {
            chatRoom.title = content
            ChatRoomManager.shared.updateChatRoom(chatRoom)
        }
        
        let request = ChatRequest(model: "gpt-3.5-turbo", messages: messages)
        
        chatService.sendMessage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if var reply = response.choices.first?.message {
                        if let lastIndex = self?.messages.lastIndex(where: { $0.role == .user }) {
                            self?.messages[lastIndex].status = .sent
                        }
                        reply.timestamp = Date()
                        self?.messages.append(reply)
                    } else {
                        self?.errorMessage = "AI No Response"
                        if let lastIndex = self?.messages.lastIndex(where: { $0.role == .user }) {
                            self?.messages[lastIndex].status = .failed
                        }
                    }
                case .failure(let error):
                    if let lastIndex = self?.messages.lastIndex(where: { $0.role == .user }) {
                        self?.messages[lastIndex].status = .failed
                    }
                    if let openAIError = error as? OpenAIError {
                        self?.errorMessage = openAIError.localizedDescription
                    } else {
                        self?.errorMessage = "Error：\(error.localizedDescription)"
                    }
                }
                self?.chatRoom.messages = self?.messages ?? []
                ChatRoomManager.shared.updateChatRoom(self?.chatRoom ?? ChatRoom(title: ""))
            }
        }
    }
}

