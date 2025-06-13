import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var newsStackView: UIStackView!
    @IBOutlet weak var newsScrollView: UIScrollView!
    @IBOutlet weak var keywordsScrollView: UIScrollView!
    @IBOutlet weak var keywordsStackView: UIStackView!
    
    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var myId: String?
    var mySecret: String?
    var keywords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        loadAPIKeys()
        setupStackViewConstraints()
        setupKeywordStackViewConstraints()
        
        summaryLabel.numberOfLines = 0
        summaryLabel.lineBreakMode = .byWordWrapping // 단어 단위 줄바꿈 // .byTruncatingTail
        summaryLabel.backgroundColor = UIColor(hex: "#e6e3ff")
        
    }
        
    func loadDate(){
           let formatter = DateFormatter()
           formatter.locale = Locale(identifier: "ko_KR")
           formatter.dateFormat = "yyyy년 M월 d일 EEEE"
           
           let today = Date()
           dateLabel.text = formatter.string(from: today)
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
    
    func setupKeywordStackViewConstraints(){
        
        
        keywordsStackView.translatesAutoresizingMaskIntoConstraints = false
        keywordsStackView.axis = .horizontal
        keywordsStackView.alignment = .center       // 또는 .fill
        keywordsStackView.distribution = .equalSpacing // .fill .fillProportionally
        keywordsStackView.spacing = 10
        NSLayoutConstraint.activate([
            keywordsStackView.topAnchor.constraint(equalTo: keywordsScrollView.contentLayoutGuide.topAnchor),
            keywordsStackView.bottomAnchor.constraint(equalTo: keywordsScrollView.contentLayoutGuide.bottomAnchor),
            keywordsStackView.leadingAnchor.constraint(equalTo: keywordsScrollView.contentLayoutGuide.leadingAnchor),
            keywordsStackView.trailingAnchor.constraint(equalTo: keywordsScrollView.contentLayoutGuide.trailingAnchor),
            keywordsStackView.heightAnchor.constraint(equalTo: keywordsScrollView.frameLayoutGuide.heightAnchor)
        ])
        keywordsScrollView.alwaysBounceHorizontal = true
        keywordsScrollView.showsHorizontalScrollIndicator = true
        keywordsScrollView.isScrollEnabled = true
    }

    func showNews(_ newsItems: [NewsItem]) {
        newsStackView.spacing = 10
        
        for item in newsItems {
            let title = UILabel()
            title.text = item.title
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\n", with: " ")
                .htmlDecoded
            title.numberOfLines = 1
            title.font = .systemFont(ofSize: 16)
            title.backgroundColor = UIColor(hex: "#fcfce1")
            
            let description = UILabel()
            description.text = item.description.htmlDecoded
            description.numberOfLines = 3
            description.font = .systemFont(ofSize: 13)
            description.backgroundColor = UIColor(hex: "#dfdfeb")
            description.layer.cornerRadius = 10

            let container = UIStackView(arrangedSubviews: [title, description])
            container.axis = .vertical
            container.spacing = 5
            container.heightAnchor.constraint(equalToConstant: 100).isActive = true
            container.backgroundColor = UIColor(hex: "#a9a6ff")
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
                self?.issueLabel.text = "# \(keyword) 이슈 요약"
                self?.loadSummary(keyword, newsItems)
            }
        }
    }
    func loadSummary(_ keyword: String, _ newsItems: [NewsItem]) {
        // 키워드 이슈 요약 표시
        SummaryService.shared.summarizeNews(word: keyword, articles: newsItems) {
            [weak self] summary in
            print("요약결과도착\n")
            DispatchQueue.main.async {
                self?.summaryLabel.text = summary
                print("🟢summary : \(self?.summaryLabel.text ?? "nil")")
            }
        }
    }
    @IBAction func addKeywordButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "키워드 추가",
        message: "뉴스 키워드를 입력하세요", preferredStyle: .alert)
        // 텍스트필드 추가
        alert.addTextField { textField in
            textField.placeholder = "예: 현대건설"
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
        /*
        var config = UIButton.Configuration.filled()
            config.title = title
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12) // 내부 여백
            
            let button = UIButton(configuration: config)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
            button.addTarget(self, action: #selector(keywordTapped(_:)), for: .touchUpInside)
       
        keywordsStackView.addArrangedSubview(button)
         */
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#7452ff")
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left:12, bottom : 8, right: 12)
        
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 액션 추가
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

