import UIKit
import Foundation

class ViewController: UIViewController, NewsItemViewDelegate {
    
    @IBOutlet weak var newsStackView: UIStackView!
    @IBOutlet weak var newsScrollView: UIScrollView!
    @IBOutlet weak var keywordsScrollView: UIScrollView!
    @IBOutlet weak var keywordsStackView: UIStackView!
    
    @IBOutlet weak var summaryLabel: UITextView!
    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var summaryScrollView: UIScrollView!
    var myId: String?
    var mySecret: String?
    var keywords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDate()
        loadAPIKeys()
        setupStackViewConstraints()
        setupKeywordStackViewConstraints()
        setupSummaryLabel()
        
        // 초깃값 불러오기
        NewsService.shared.fetchNews(keyword: "바이오") { [weak self] items in
            DispatchQueue.main.async {
                self?.showNews(items)
            }
        }
    }
    func didTapNews(link: String) {
        // 뷰컨트롤러 인스턴스 생성하고 url 넘기기
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let webVC = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController {
            webVC.urlString = link
            self.present(webVC, animated: true)
        }
    }
    func setupSummaryLabel() {
        
        summaryLabel.font = .boldSystemFont(ofSize: 13)
        summaryLabel.backgroundColor = UIColor(hex: "#fdfcff")
        summaryLabel.isEditable = false
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: summaryScrollView.contentLayoutGuide.topAnchor),
            summaryLabel.bottomAnchor.constraint(equalTo: summaryScrollView.contentLayoutGuide.bottomAnchor),
            summaryLabel.leadingAnchor.constraint(equalTo: summaryScrollView.contentLayoutGuide.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: summaryScrollView.contentLayoutGuide.trailingAnchor),
            summaryLabel.widthAnchor.constraint(equalTo: summaryScrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    func loadDate(){
           let formatter = DateFormatter()
           formatter.locale = Locale(identifier: "ko_KR")
           formatter.dateFormat = "yyyy년 M월 d일 (E)"
           
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
        let urlString = "https://openapi.naver.com/v1/search/news.json?query=\(query)&display=15"
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
        keywordsStackView.distribution = .equalSpacing//.equalSpacing // .fill .fillProportionally
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
        newsStackView.spacing = 15
        for item in newsItems {
            let view = NewsItemView(item: item)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 150).isActive = true
            // 패딩 추가
            view.layoutMargins = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            view.isLayoutMarginsRelativeArrangement = true
            view.layer.cornerRadius = 10
            view.backgroundColor=UIColor(hex:"#fdfcff")
            view.delegate = self
            newsStackView.addArrangedSubview(view)
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
                self?.issueLabel.numberOfLines = 1
                self?.issueLabel.lineBreakMode = .byClipping
                self?.issueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                self?.issueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                self?.issueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
                self?.issueLabel.text = "🔎 \(keyword)"
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
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy.MM.dd E"
            let today = Calendar.current.startOfDay(for: Date())
            print("\n\n===date: \(today)===\n\n")
            let summaryObj = Summary(date: today, keyword: keyword, content: summary)
            CoreDataManager.shared.addOrUpdateSummary(summary: summaryObj)
            
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

