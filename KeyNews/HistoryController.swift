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
    }
  
    func loadHistories() {
        let items = CoreDataManager.shared.fetchHistoryItems()
            showContents(items)
    }
    func showContents(_ historyItems: [HistoryItem]) {
        historyStackView.spacing = 15
        for item in historyItems {
            let view = CView(item: item)
            view.translatesAutoresizingMaskIntoConstraints = false
            //view.heightAnchor.constraint(equalToConstant: 200).isActive = true
            //view.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
            view.setContentHuggingPriority(.required, for: .vertical)
            view.setContentCompressionResistancePriority(.required, for: .vertical)

            // 패딩 추가
            view.backgroundColor = UIColor(hex: "fdfcff")
            
            view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            view.isLayoutMarginsRelativeArrangement = true
            // 모서리
            view.layer.cornerRadius = 10
            historyStackView.addArrangedSubview(view)
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
        loadHistories()
    }
}
