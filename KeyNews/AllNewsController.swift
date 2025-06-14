//
//  AllNewsController.swift
//  KeyNews
//
//  Created by ssem on 6/12/25.
//

import UIKit
import CoreData
class AllNewsController: UIViewController, NewsItemViewDelegate {

    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    
    @IBOutlet weak var categoryNewsStackView: UIStackView!
    @IBOutlet weak var categoryNewsScrollView: UIScrollView!
    
    var categories: [String] = ["정치", "사회", "금융", "증권", "부동산", "IT", "과학", "생활", "문화"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setUpNewsView()
        loadButtons()
        
        // 초깃값 불러오기
        NewsService.shared.fetchNews(keyword: "정치") { [weak self] items in
            DispatchQueue.main.async {
                self?.showNews(items)
            }
        }
      // categoryStackView.heightAnchor.constraint(equalTo:         categoryScrollView.heightAnchor).isActive = true
    }
    func didTapNews(link: String) {
            // 뷰컨트롤러 인스턴스 생성하고 url 넘기기
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let webVC = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
                webVC.urlString = link
                self.present(webVC, animated: true)
            }
        }
    func loadButtons() {
        for c in categories {
            let button = UIButton(type: .system)
            button.setTitle(c, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(hex: "7463FF")
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            button.titleLabel?.font = .boldSystemFont(ofSize: 15)
            // 액션 추가
            button.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)

            categoryStackView.addArrangedSubview(button)
        }
    }
    
    func setup() {
        // 카테고리 버튼
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.topAnchor),
                    categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.bottomAnchor),
                    categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.leadingAnchor),
                    categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.trailingAnchor),
                    //categoryStackView.widthAnchor.constraint(equalTo: categoryScrollView.frameLayoutGuide.widthAnchor)
                ])
    }
    func setUpNewsView(){
        // 뉴스 뷰
        //categoryNewsStackView.axis = .vertical
        categoryNewsStackView.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            categoryNewsStackView.topAnchor.constraint(equalTo: categoryNewsScrollView.contentLayoutGuide.topAnchor),
            categoryNewsStackView.bottomAnchor.constraint(equalTo: categoryNewsScrollView.contentLayoutGuide.bottomAnchor),
            categoryNewsStackView.leadingAnchor.constraint(equalTo: categoryNewsScrollView.contentLayoutGuide.leadingAnchor),
            categoryNewsStackView.trailingAnchor.constraint(equalTo: categoryNewsScrollView.contentLayoutGuide.trailingAnchor),
            categoryNewsStackView.widthAnchor.constraint(equalTo: categoryNewsScrollView.frameLayoutGuide.widthAnchor) // 세로 스크롤용
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
        categoryNewsStackView.spacing = 10
        clearNews()

        for item in newsItems {
            let view = NewsItemView(item: item)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 150).isActive = true
            // 패딩 추가
            view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 10)
            view.isLayoutMarginsRelativeArrangement = true
            // 모서리
            view.layer.cornerRadius = 10
            view.backgroundColor=UIColor(hex:"#fdfcff")
            view.delegate = self
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
        // 해당 카테고리 뉴스 불러오기
        NewsService.shared.fetchNews(keyword: category) { [weak self] items in
            DispatchQueue.main.async {
                self?.showNews(items)
            }
        }
    }
    /* // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
}
