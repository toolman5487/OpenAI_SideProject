//
//  ChatInputBarView.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import UIKit
import SnapKit

protocol ChatInputBarViewDelegate: AnyObject {
    func chatInputBar(_ inputBar: ChatInputBarView, didSend text: String)
}

class ChatInputBarView: UIView {
    
    weak var delegate: ChatInputBarViewDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(sendButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.height.greaterThanOrEqualTo(44)
        }
        
        textView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.equalTo(sendButton.snp.left).offset(-8)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        delegate?.chatInputBar(self, didSend: text)
        textView.text = ""
        textView.resignFirstResponder()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 60)
    }
}
