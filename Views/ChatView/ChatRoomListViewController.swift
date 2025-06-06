//
//  ChatRoomListViewController.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/6.
//

import UIKit

class ChatRoomListViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "聊天室列表"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChatRoom))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatRoomManager.shared.chatRooms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let room = ChatRoomManager.shared.chatRooms[indexPath.row]
        cell.textLabel?.text = room.title
        cell.detailTextLabel?.text = "建立於 \(room.createdAt)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = ChatRoomManager.shared.chatRooms[indexPath.row]
        let chatVC = ChatViewController(chatRoom: room)
        navigationController?.pushViewController(chatVC, animated: true)
    }

    @objc private func addChatRoom() {
        let newRoom = ChatRoom(title: "")
        ChatRoomManager.shared.addChatRoom(newRoom)
        tableView.reloadData()
        let chatVC = ChatViewController(chatRoom: newRoom)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let room = ChatRoomManager.shared.chatRooms[indexPath.row]
            ChatRoomManager.shared.deleteChatRoom(room)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
