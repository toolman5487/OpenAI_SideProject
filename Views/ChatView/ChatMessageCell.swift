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
       return label
   }()
   
   private let bubbleView: UIView = {
       let view = UIView()
       view.backgroundColor = .secondaryLabel
       view.layer.cornerRadius = 12
       return view
   }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        bubbleView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        bubbleView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    func configure(with message: String) {
        messageLabel.text = message
    }
}

