import UIKit
protocol NewsItemViewDelegate: AnyObject {
    func didTapNews(link: String)
}

class NewsItemView: UIStackView {
    weak var delegate: NewsItemViewDelegate?
    let item: NewsItem
    init(item: NewsItem) {
        self.item = item
        super.init(frame: .zero)
        
        axis = .vertical
        spacing = 2 // 제목-글 간격
        translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.title.cleanedHTML
        titleLabel.numberOfLines = 1
        titleLabel.layer.cornerRadius = 8
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.backgroundColor = UIColor(hex: "#cac4ff")
        //titleLabel.backgroundColor = UIColor(hex: "#000000")
        titleLabel.clipsToBounds = true
        let descriptionLabel = UILabel()
        descriptionLabel.text = item.description.cleanedHTML
        descriptionLabel.numberOfLines = 3
        descriptionLabel.font = .systemFont(ofSize: 15)
        // //  색상변경
        descriptionLabel.backgroundColor = UIColor(hex: "fdfcff")
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(descriptionLabel)
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap() {
        delegate?.didTapNews(link: item.link)  // 위임자에게 전달
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
