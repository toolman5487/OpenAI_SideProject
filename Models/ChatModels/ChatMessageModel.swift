//
//  ChatMessageModel.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation

enum ChatRole: String, Codable {
    case user
    case assistant
    case system
}

enum MessageStatus: String, Codable {
    case sending
    case sent
    case failed
}

struct ChatMessage: Codable {
    let role: ChatRole
    let content: String
    var timestamp: Date?
    var status: MessageStatus?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(ChatRole.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        timestamp = nil
        status = nil
    }

    init(role: ChatRole, content: String, timestamp: Date? = Date(), status: MessageStatus? = .sent) {
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.status = status
    }
}
