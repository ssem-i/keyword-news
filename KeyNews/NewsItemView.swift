//
//  NewsItemView.swift
//  KeyNews
//
//  Created by ssem on 6/12/25.
//

import UIKit

class NewsItemView: UIStackView {

    init(item: NewsItem) {
            super.init(frame: .zero)
            
            axis = .vertical
            spacing = 5
            translatesAutoresizingMaskIntoConstraints = false
            
            let titleLabel = UILabel()
            titleLabel.text = item.title.cleanedHTML
            titleLabel.numberOfLines = 1
            titleLabel.font = .systemFont(ofSize: 16)
            titleLabel.backgroundColor = .red.withAlphaComponent(0.3)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = item.description.cleanedHTML
            descriptionLabel.numberOfLines = 3
            descriptionLabel.font = .systemFont(ofSize: 13)
            descriptionLabel.backgroundColor = .blue.withAlphaComponent(0.3)
            
            addArrangedSubview(titleLabel)
            addArrangedSubview(descriptionLabel)
            
            heightAnchor.constraint(equalToConstant: 100).isActive = true
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    
}
extension String {
    var cleanedHTML: String {
        self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\n", with: " ")
            .htmlDecoded
    }
}
