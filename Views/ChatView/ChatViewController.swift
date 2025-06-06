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
    
    private lazy var inputBarView: ChatInputBarView = {
        let view = ChatInputBarView()
        view.delegate = self
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return tableView
    }()
    
    private var inputBarBottomConstraint: Constraint?
    
    private func scrollToBottom() {
        let row = tableView.numberOfRows(inSection: 0) - 1
        guard row >= 0 else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        // 如果內容高度不足以填滿tableView，強制讓內容貼底
        let contentHeight = tableView.contentSize.height
        let tableHeight = tableView.bounds.height
        if contentHeight < tableHeight {
            let offsetY = max(contentHeight - tableHeight, 0)
            tableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }
    
    private func updateTableFooter() {
        let contentHeight = tableView.contentSize.height
        let tableHeight = tableView.bounds.height
        let bottomInset = tableView.contentInset.bottom
        let footerHeight = max(tableHeight - contentHeight - bottomInset, 0)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: footerHeight))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
    }
    
    private func bindingViewModel() {
        chatViewModel = ChatViewModel(chatService: ChatAPIService())
        chatViewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateTableFooter()
                self?.scrollToBottom()
            }
            .store(in: &cancellables)
    }
    
    private func layout() {
        view.addSubview(tableView)
        view.addSubview(inputBarView)
        
        inputBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.bottom = inputBarView.frame.height
        tableView.scrollIndicatorInsets.bottom = inputBarView.frame.height
        tableView.alwaysBounceVertical = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureTableView()
        layout()
        bindingViewModel()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableFooter()
        scrollToBottom()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputBarBottomConstraint?.update(offset: -keyboardHeight)
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
       
        let bottomInset = keyboardHeight + inputBarView.frame.height
        tableView.contentInset.bottom = bottomInset
        tableView.scrollIndicatorInsets.bottom = bottomInset
        updateTableFooter()
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        inputBarBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        tableView.contentInset.bottom = inputBarView.frame.height
        tableView.scrollIndicatorInsets.bottom = inputBarView.frame.height
        updateTableFooter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableFooter()
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let reversedIndex = chatViewModel.messages.count - 1 - indexPath.row
        let message = chatViewModel.messages[reversedIndex]
        cell.configure(with: message.content)
        return cell
    }
}

extension ChatViewController: ChatInputBarViewDelegate {
    func chatInputBar(_ inputBar: ChatInputBarView, didSend text: String) {
        chatViewModel.sendUserMessage(text)
    }
}
