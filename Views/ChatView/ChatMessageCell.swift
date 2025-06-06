//
//  ChatMessageCell.swift
//  OpenAI_SideProject
//
//  Created by Willy Hsu on 2025/6/5.
//

import Foundation
import UIKit
import SnapKit

class ChatMessageCell: UITableViewCell {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .trailing
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(stackView)
        
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(statusLabel)
        
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.75)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let timestamp = message.timestamp {
            timeLabel.text = dateFormatter.string(from: timestamp)
        } else {
            timeLabel.text = "00:00"
        }
        
        switch message.status {
        case .sending:
            statusLabel.text = "傳送中..."
            statusLabel.textColor = .tertiaryLabel
        case .sent:
            statusLabel.text = "已傳送"
            statusLabel.textColor = .tertiaryLabel
        case .failed:
            statusLabel.text = "傳送失敗"
            statusLabel.textColor = .systemRed
        case .none:
            statusLabel.text = ""
        }
        
        if message.role == .user {
            bubbleView.backgroundColor = .quaternaryLabel
            bubbleView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.right.equalToSuperview().offset(-16)
                make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.75)
            }
            stackView.alignment = .trailing
        } else {
            bubbleView.backgroundColor = .systemBackground
            bubbleView.snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.left.equalToSuperview().offset(16)
                make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.75)
            }
            stackView.alignment = .leading
        }
    }
}

