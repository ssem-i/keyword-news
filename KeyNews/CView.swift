import UIKit
import Foundation
struct HistoryItem: Decodable {
    let hdate: String
    let hkeyword: String
    let hcontent: String
}

class CView: UIStackView {
    
    let item: HistoryItem
    
    
    init(item: HistoryItem) {
        self.item = item
        super.init(frame: .zero)
        
        axis = .vertical
        spacing = 2 // 제목-글 간격
        translatesAutoresizingMaskIntoConstraints = false
        
        // 날짜
        let dateLabel = UILabel()
        dateLabel.numberOfLines = 1
        dateLabel.text=item.hdate
        dateLabel.font = .boldSystemFont(ofSize: 13)
        dateLabel.backgroundColor = UIColor(hex: "#cac4ff")
        dateLabel.layer.cornerRadius = 10
        dateLabel.clipsToBounds=true
        dateLabel.textAlignment = .center
        dateLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true//
        // 키워드
        let keywordLabel = UILabel()
        keywordLabel.numberOfLines = 1
        keywordLabel.text = "# \(item.hkeyword)"
        keywordLabel.font = .boldSystemFont(ofSize: 17)
        keywordLabel.textColor = UIColor(hex: "#4B4BFF")
        
        // 내용
        let contentLabel = UILabel()
        contentLabel.text = item.hcontent
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.textColor = UIColor(hex: "#00000")
        contentLabel.backgroundColor = UIColor(hex: "#fdfcff")
        contentLabel.layer.cornerRadius = 10
        contentLabel.clipsToBounds = true
        
        //contentLabel.setContentHuggingPriority(.required, for: .vertical)
        //contentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        
        addArrangedSubview(dateLabel)
        addArrangedSubview(keywordLabel)
        addArrangedSubview(contentLabel)
        
        heightAnchor.constraint(equalToConstant: 180).isActive = true
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        //self.isUserInteractionEnabled = true
        //self.addGestureRecognizer(tapGesture)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
