//
//  ChatRoomManager.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/6.
//

import Foundation

class ChatRoomManager {
    
    static let shared = ChatRoomManager()
    private let userDefaultsKey = "chatRooms"

    private(set) var chatRooms: [ChatRoom] = []

    private init() {
        loadChatRooms()
    }

    func addChatRoom(_ room: ChatRoom) {
        chatRooms.append(room)
        saveChatRooms()
    }

    func updateChatRoom(_ room: ChatRoom) {
        if let index = chatRooms.firstIndex(where: { $0.id == room.id }) {
            chatRooms[index] = room
            saveChatRooms()
        }
    }

    func deleteChatRoom(_ room: ChatRoom) {
        chatRooms.removeAll { $0.id == room.id }
        saveChatRooms()
    }

    func saveChatRooms() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(chatRooms) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func loadChatRooms() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let rooms = try? decoder.decode([ChatRoom].self, from: data) {
            chatRooms = rooms
        } else {
            chatRooms = []
        }
    }
}
