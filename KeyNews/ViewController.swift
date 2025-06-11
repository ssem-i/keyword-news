import UIKit
import Foundation

class ViewController: UIViewController {

    
    @IBOutlet weak var newsStackView: UIStackView!
    @IBOutlet weak var newsScrollView: UIScrollView!
    
    @IBOutlet weak var keywordsStackView: UIStackView!
    var myId: String?
    var mySecret: String?
    var keywords: [String] = ["미래에셋"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAPIKeys()
        setupStackViewConstraints()
        fetchNews(keyword: keywords[0]) { [weak self] newsItems in
                DispatchQueue.main.async {
                    self?.showNews(newsItems)
                    
                }
            }
        /*
        fetchNews(keyword: keywords[0]) { [weak self] newsItems in
                DispatchQueue.main.async {
                    for item in newsItems {
                        let title = UILabel()
                        title.text = item.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                            .replacingOccurrences(of: "\n", with: " ")
                            .htmlDecoded  // html 태그 제거
                        title.numberOfLines = 1 // 표시할 줄 수
                        title.font = UIFont.systemFont(ofSize: 16)  // 글자 크기
                        
                        
                        let description = UILabel()
                        description.text = item.description.htmlDecoded
                        description.numberOfLines = 3
                        description.font = UIFont.systemFont(ofSize: 13)
                        
                        let container = UIStackView()
                        container.axis = .vertical
                        container.spacing = 5
                        container.addArrangedSubview(title)
                        container.addArrangedSubview(description)
                        title.backgroundColor = .red.withAlphaComponent(0.3)
                        description.backgroundColor = .blue.withAlphaComponent(0.3)
                    
                        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
                        self?.newsStackView.spacing = 15
                        self?.newsStackView.addArrangedSubview(container)
                    }
                }
            }
        
        newsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // 스택뷰를 스크롤뷰의 contentLayoutGuide에 꽉 차게 연결
            newsStackView.topAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.topAnchor),
            newsStackView.bottomAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.bottomAnchor),
            newsStackView.leadingAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.leadingAnchor),
            newsStackView.trailingAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.trailingAnchor),

            // 스택뷰의 너비를 스크롤뷰 프레임과 동일하게 (가로 스크롤 방지)
            newsStackView.widthAnchor.constraint(equalTo: newsScrollView.frameLayoutGuide.widthAnchor)
        ])
         */
    }

    func loadAPIKeys(){
        if let url = Bundle.main.url(forResource: "Property List", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] {

            myId = dict["myId"]
            mySecret = dict["mySecret"]
            //print("id: \(myId ?? "nil"), secret: \(mySecret ?? "nil")")
        }
    }

    
    struct NewsItem : Decodable {
        let title: String
        let link : String
        let description : String
    }
    
    struct NewsResponse: Decodable {
        let items: [NewsItem]
    }
    
    func fetchNews(keyword: String, completion: @escaping ([NewsItem]) -> Void) {
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openapi.naver.com/v1/search/news.json?query=\(query)&display=5"
            guard let url = URL(string: urlString) else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(myId, forHTTPHeaderField: "X-Naver-Client-Id")
            request.setValue(mySecret, forHTTPHeaderField: "X-Naver-Client-Secret")

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                do {
                    let news = try JSONDecoder().decode(NewsResponse.self, from: data)
                    completion(news.items)
                } catch {
                    print("Parsing error: \(error)")
                }
            }.resume()
    }
    func setupStackViewConstraints() {
        newsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newsStackView.topAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.topAnchor),
            newsStackView.bottomAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.bottomAnchor),
            newsStackView.leadingAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.leadingAnchor),
            newsStackView.trailingAnchor.constraint(equalTo: newsScrollView.contentLayoutGuide.trailingAnchor),
            newsStackView.widthAnchor.constraint(equalTo: newsScrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func showNews(_ newsItems: [NewsItem]) {
        newsStackView.spacing = 15
        
        for item in newsItems {
            let title = UILabel()
            title.text = item.title
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\n", with: " ")
                .htmlDecoded
            title.numberOfLines = 1
            title.font = .systemFont(ofSize: 16)
            title.backgroundColor = .red.withAlphaComponent(0.3)
            
            let description = UILabel()
            description.text = item.description.htmlDecoded
            description.numberOfLines = 3
            description.font = .systemFont(ofSize: 13)
            description.backgroundColor = .blue.withAlphaComponent(0.3)

            let container = UIStackView(arrangedSubviews: [title, description])
            container.axis = .vertical
            container.spacing = 5
            container.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            newsStackView.addArrangedSubview(container)
        }
    }

    func clearNews() {
        for view in newsStackView.arrangedSubviews {
            newsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    @objc func keywordTapped(_ sender: UIButton) {
        guard let keyword = sender.titleLabel?.text else { return }
        fetchNews(keyword: keyword) { [weak self] newsItems in
            DispatchQueue.main.async {
                self?.clearNews()
                self?.showNews(newsItems)
            }
        }
    }
    @IBAction func addKeywordButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "키워드 추가", message: "뉴스 키워드를 입력하세요", preferredStyle: .alert)
        
        // 텍스트필드 추가
        alert.addTextField { textField in
            textField.placeholder = "예: 삼성, 현대건설"
        }
        
        // 확인 버튼
        let addAction = UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let keyword = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !keyword.isEmpty else { return }
            
            self?.addKeyword(keyword)
        }
        
        // 취소 버튼
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func addKeywordButton(title: String) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(self, action: #selector(keywordTapped(_:)), for: .touchUpInside)
        keywordsStackView.addArrangedSubview(button)
    }
    
    func addKeyword(_ keyword: String) {
        guard !keyword.isEmpty else { return }
        guard !keywords.contains(keyword) else { return }

        keywords.append(keyword)
        addKeywordButton(title: keyword)
    }
}

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}

