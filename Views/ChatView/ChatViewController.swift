//
//  ChatViewController.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import UIKit
import Combine
import SnapKit
import Lottie

class ChatViewController: UIViewController {
    
    private var chatViewModel: ChatViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var inputBarBottomConstraint: Constraint?
    private var lottieTitleView: LottieAnimationView?
    
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
    
    private func scrollToBottom() {
        let row = tableView.numberOfRows(inSection: 0) - 1
        guard row >= 0 else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

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
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "錯誤",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        self.present(alert, animated: true)
    }
    
    private func showLottieTitle() {
        if lottieTitleView == nil {
            let lottieView = LottieAnimationView(name: "loadingPoint")
            lottieView.loopMode = .loop
            lottieView.contentMode = .scaleAspectFill
            lottieView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            lottieTitleView = lottieView
        }
        lottieTitleView?.isHidden = false
        lottieTitleView?.play()
        self.navigationItem.titleView = lottieTitleView
    }

    private func showTextTitle() {
        lottieTitleView?.stop()
        lottieTitleView?.isHidden = true
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Chat OpenAI"
    }
    
    private func bindingViewModel() {
        chatViewModel = ChatViewModel(chatService: ChatAPIService())
        
        chatViewModel.$messages
            .receive(on: DispatchQueue.main)
            .scan(([], [])) { ($0.1, $1) }
            .sink { [weak self] oldAndNew in
                let (oldMessages, newMessages) = oldAndNew
                self?.tableView.reloadData()
                self?.updateTableFooter()
                if newMessages.count > oldMessages.count {
                    self?.scrollToBottom()
                }
            }
            .store(in: &cancellables)
        
        chatViewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showError(errorMessage)
                }
            }
            .store(in: &cancellables)
        
        chatViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.showLottieTitle()
                } else {
                    self.showTextTitle()
                }
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
    
    private func setupNavigationTitle() {
        self.navigationItem.title = "Chat AI"
        if let navBar = self.navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.boldSystemFont(ofSize: 20)
            ]
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.tintColor = .label
        }
    }
    
    private func setupTableViewTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    private func setupKeyboardObservers() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        view.backgroundColor = .systemBackground
        configureTableView()
        layout()
        bindingViewModel()
        setupTableViewTapToDismissKeyboard()
        setupKeyboardObservers()
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
        tableView.contentInset.bottom = keyboardHeight
        tableView.scrollIndicatorInsets.bottom = keyboardHeight
        updateTableFooter()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        inputBarBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        tableView.contentInset.bottom = 0
        tableView.scrollIndicatorInsets.bottom = 0
        updateTableFooter()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        cell.configure(with: message)
        return cell
    }
}

extension ChatViewController: ChatInputBarViewDelegate {
    func chatInputBar(_ inputBar: ChatInputBarView, didSend text: String) {
        chatViewModel.sendUserMessage(text)
    }
}
