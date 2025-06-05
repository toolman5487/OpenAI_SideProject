//
//  ChatViewController.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import UIKit
import Combine
import SnapKit

class ChatViewController: UIViewController {
    
    private var chatViewModel: ChatViewModel!
    private var cancellables = Set<AnyCancellable>()
    override var inputAccessoryView: UIView? { inputBarView }
    override var canBecomeFirstResponder: Bool { true }
    
    private lazy var inputBarView: ChatInputBarView = {
        let view = ChatInputBarView()
        view.delegate = self
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private func scrollToBottom() {
        let row = tableView.numberOfRows(inSection: 0) - 1
        guard row >= 0 else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func bindingViewModel() {
        chatViewModel = ChatViewModel(chatService: ChatAPIService())
        chatViewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
            .store(in: &cancellables)
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureTableView()
        layout()
        bindingViewModel()
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let message = chatViewModel.messages[indexPath.row]
        cell.configure(with: message.content)
        return cell
    }
}

extension ChatViewController: ChatInputBarViewDelegate {
    func chatInputBar(_ inputBar: ChatInputBarView, didSend text: String) {
        chatViewModel.sendUserMessage(text)
    }
}
