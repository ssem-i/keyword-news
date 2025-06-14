
import UIKit



class HistoryController: UIViewController {

    @IBOutlet weak var historyStackView: UIStackView!
    @IBOutlet weak var historyScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UserDefaults.standard.bool(forKey: "didInsertSampleData") {
            // 처음 실행일 때만 실행
            loadSampleData()
            UserDefaults.standard.set(true, forKey: "didInsertSampleData") // 실행됨 표시 저장
        }
        setupStackViewConstraints()
        //loadInitialData()
    }
    func buildUI(with entities: [SummaryEntity]) {
        // 날짜 기준으로 정렬 후 그룹핑
        //let groupedByDate = Dictionary(grouping: entities) { $0.date ?? "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")

        let groupedByDate = Dictionary(grouping: entities) {
            formatter.string(from: $0.date ?? Date.distantPast)
        }
        let sortedDates = groupedByDate.keys.sorted(by: >)

        for date in sortedDates {
            guard let summariesForDate = groupedByDate[date] else { continue }
            // 날짜 Label
            let dateLabel = UILabel()
            dateLabel.text = date
            dateLabel.font = .boldSystemFont(ofSize: 14)
            dateLabel.textColor = .black

            // 날짜별 컨테이너
            let dateContainer = UIStackView()
            dateContainer.axis = .vertical
            dateContainer.spacing = 8
            dateContainer.alignment = .fill
            dateContainer.translatesAutoresizingMaskIntoConstraints = false
            dateContainer.addArrangedSubview(dateLabel)

            // 키워드로 그룹화
            let groupedByKeyword = Dictionary(grouping: summariesForDate) { $0.keyword ?? "" }
            let sortedKeywords = groupedByKeyword.keys.sorted()
            for keyword in sortedKeywords {
                guard let summaries = groupedByKeyword[keyword] else { continue }

                // 키워드 Label
                let keywordLabel = UILabel()
                keywordLabel.text = "# \(keyword)"
                keywordLabel.font = .systemFont(ofSize: 13, weight: .semibold)
                keywordLabel.textColor = UIColor(hex: "#4B4BFF")
                //historyStackView.addArrangedSubview(keywordLabel) 를 수정
                dateContainer.addArrangedSubview(keywordLabel)
                
                for summary in summaries {
                    //let contentView = UITextView()
                    let contentView = UILabel()
                    contentView.text = summary.content ?? ""
                    contentView.numberOfLines = 0
                    contentView.font = .systemFont(ofSize: 11)
                    contentView.textColor = .darkGray
                    contentView.backgroundColor = UIColor(hex: "e6e3ff")
                    contentView.layer.cornerRadius = 10
                    contentView.clipsToBounds = true
                    //contentView.isEditable = false
                    //contentView.isScrollEnabled = false
                 //   contentView.translatesAutoresizingMaskIntoConstraints = false
                    
                    
                    //let estimatedHeight = contentView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: .greatestFiniteMagnitude)).height
                    //contentView.heightAnchor.constraint(equalToConstant: estimatedHeight).isActive = true
                    contentView.setContentHuggingPriority(.required, for: .vertical)
                    contentView.setContentCompressionResistancePriority(.required, for: .vertical)

                    // StackView로 감싸기 (마진용)
                    let wrapper = UIStackView(arrangedSubviews: [contentView])
                    wrapper.axis = .vertical
                    wrapper.isLayoutMarginsRelativeArrangement = true
                    wrapper.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
                    
                    //wrapper.translatesAutoresizingMaskIntoConstraints = false
                    
                    dateContainer.addArrangedSubview(wrapper)
                }
            }
            //날짜별 컨테이너를 스택뷰에 추가
            historyStackView.addArrangedSubview(dateContainer)
        }
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 1).isActive = true
        historyStackView.addArrangedSubview(spacer)
    }
    func loadInitialData() {
        DispatchQueue.global().async {
            let entities = CoreDataManager.shared.fetchAllSummaries()
            //print(entities.map { "!!! \($0.date ?? "nil") - \($0.keyword ?? "nil")" })
            DispatchQueue.main.async {
                self.buildUI(with: entities)
            }
        }
    }
    func setupStackViewConstraints() {
        historyStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            historyStackView.topAnchor.constraint(equalTo: historyScrollView.contentLayoutGuide.topAnchor),
            historyStackView.bottomAnchor.constraint(equalTo: historyScrollView.contentLayoutGuide.bottomAnchor),
            historyStackView.leadingAnchor.constraint(equalTo: historyScrollView.contentLayoutGuide.leadingAnchor),
            historyStackView.trailingAnchor.constraint(equalTo: historyScrollView.contentLayoutGuide.trailingAnchor),
            historyStackView.widthAnchor.constraint(equalTo: historyScrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    func addSummaryView(summary: Summary) {
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")

        dateLabel.text = formatter.string(from: summary.date)
        dateLabel.font = .boldSystemFont(ofSize: 12)
        
        let contentLabel = UITextView()
        contentLabel.text = summary.content
        //contentLabel.numberOfLines = 7
        //contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.isScrollEnabled = false
        contentLabel.isEditable = false
        
        contentLabel.font = .systemFont(ofSize: 11)
        contentLabel.backgroundColor = UIColor(hex: "e6e3ff")
        contentLabel.layer.cornerRadius = 10
        contentLabel.clipsToBounds = true
       // contentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
       // contentLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        // 너비 제약 추가
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.widthAnchor.constraint(equalTo: historyScrollView.frameLayoutGuide.widthAnchor, constant: -20).isActive = true
        
        let container = UIStackView(arrangedSubviews: [dateLabel, contentLabel])
        container.axis = .vertical
        container.spacing = 5
        // 마진
        container.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        container.isLayoutMarginsRelativeArrangement = true
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //container.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        //container.setContentHuggingPriority(.defaultLow, for: .vertical)

        historyStackView.addArrangedSubview(container)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearHistoryStackView()
    }
    func clearHistoryStackView() {
        for subview in historyStackView.arrangedSubviews {
            historyStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearHistoryStackView()
        loadInitialData()
    }
}
