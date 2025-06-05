//
//  ChatInputBarView.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation
import UIKit
import SnapKit

protocol ChatInputBarViewDelegate: AnyObject {
    func chatInputBar(_ inputBar: ChatInputBarView, didSend text: String)
}

class ChatInputBarView: UIView {
    
    weak var delegate: ChatInputBarViewDelegate?
    private let textView: UITextView = {
        let textview = UITextView()
        textview.font = .systemFont(ofSize: 16)
        textview.isScrollEnabled = false
        textview.layer.cornerRadius = 18
        textview.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        textview.backgroundColor = .secondarySystemBackground
        return textview
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "詢問任何問題"
        label.textColor = .placeholderText
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送出", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private func layout(){
        addSubview(sendButton)
        addSubview(textView)
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(48)
            make.height.equalTo(36)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(8)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.bottom.equalToSuperview().inset(8).priority(.low)
            make.height.greaterThanOrEqualTo(36)
        }
        
        textView.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(textView).offset(10)
            make.left.equalTo(textView).offset(16)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 4
        layer.shadowOffset = .init(width: 0, height: -2)
        
        textView.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        layout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func sendTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        delegate?.chatInputBar(self, didSend: text)
        textView.text = ""
        textViewDidChange(textView)
        textView.resignFirstResponder()
    }
    
    override var intrinsicContentSize: CGSize {
        let tvSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let minHeight: CGFloat = 52
        let height = max(tvSize.height + 16, minHeight)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

extension ChatInputBarView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

