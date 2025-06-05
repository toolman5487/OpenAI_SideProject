//
//  ChatRequestModel.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
}
