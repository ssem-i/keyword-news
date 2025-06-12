//
//  AllNewsController.swift
//  KeyNews
//
//  Created by ssem on 6/12/25.
//

import UIKit

class AllNewsController: UIViewController {

    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var testLabel: UILabel!
    
    @IBOutlet weak var categoryNewsStackView: UIStackView!
    @IBOutlet weak var categoryNewsScrollView: UIScrollView!
    
    var categories: [String] = ["정치", "사회", "금융", "증권", "부동산", "IT", "과학", "생활", "문화"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadKeywords()
      //  categoryStackView.heightAnchor.constraint(equalTo:         categoryScrollView.heightAnchor).isActive = true
    }
    
    func loadKeywords() {
        for c in categories {
            let button = UIButton(type: .system)
            button.setTitle(c, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            
            // 액션 추가
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)

            categoryStackView.addArrangedSubview(button)
        }
    }
    
    func setup() {
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.topAnchor),
                    categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.bottomAnchor),
                    categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.leadingAnchor),
                    categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.trailingAnchor),
                    //categoryStackView.widthAnchor.constraint(equalTo: categoryScrollView.frameLayoutGuide.widthAnchor)
                ])
    }

    func loadNews() {
        NewsService.shared.fetchNews(keyword: "정치") { [weak self] items in
            DispatchQueue.main.async {
                self?.showNews(items)
            }
        }
    }
    
    func showNews(_ newsItems: [NewsItem]) {
        categoryNewsStackView.spacing = 15
        clearNews()

        for item in newsItems {
            let view = NewsItemView(item: item)
            categoryNewsStackView.addArrangedSubview(view)
        }
    }
    func clearNews() {
        for view in categoryNewsStackView.arrangedSubviews {
            categoryNewsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    @objc func categoryTapped(_ sender: UIButton) {
        guard let category = sender.titleLabel?.text else { return }

        // 예시: 해당 카테고리 뉴스 불러오기
        NewsService.shared.fetchNews(keyword: category) { [weak self] items in
            DispatchQueue.main.async {
                self?.showNews(items)
            }
        }
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
