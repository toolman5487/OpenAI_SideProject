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
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.13, alpha: 1)
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let textView: UITextView = {
        let textview = UITextView()
        textview.backgroundColor = .clear
        textview.textColor = .white
        textview.font = .systemFont(ofSize: 18)
        textview.textContainerInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        textview.isScrollEnabled = false
        textview.returnKeyType = .send
        return textview
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "詢問任何問題"
        label.textColor = UIColor(white: 0.7, alpha: 1)
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(bgView)
        bgView.addSubview(textView)
        bgView.addSubview(placeholderLabel)
        
        bgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(24)
            make.height.lessThanOrEqualTo(100)
        }
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(textView).offset(6)
            make.centerY.equalTo(textView)
        }
        
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension ChatInputBarView:UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let trimmed = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                delegate?.chatInputBar(self, didSend: trimmed)
                textView.text = ""
                placeholderLabel.isHidden = false
                return false
            }
        }
        return true
    }
}
