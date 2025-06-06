//
//  ChatRoomModel.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/6.
//

import Foundation

struct ChatRoom: Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var createdAt: Date

    init(title: String, messages: [ChatMessage] = []) {
        self.id = UUID()
        self.title = title
        self.messages = messages
        self.createdAt = Date()
    }
}
