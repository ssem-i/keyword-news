
import UIKit



class HistoryController: UIViewController {

    @IBOutlet weak var historyStackView: UIStackView!
    @IBOutlet weak var historyScrollView: UIScrollView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackViewConstraints()
        loadInitialData()
        
        // Do any additional setup after loading the view.
    }
    
    func loadInitialData() {
        for summary in summaries {
            CoreDataManager.shared.addSummary(summary: summary)
            addSummaryView(summary: summary)   
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
        dateLabel.text = summary.date
        dateLabel.font = .boldSystemFont(ofSize: 12)
        
        let contentLabel = UILabel()
        contentLabel.text = summary.content
        contentLabel.numberOfLines = 7
        contentLabel.lineBreakMode = .byWordWrapping

        contentLabel.font = .systemFont(ofSize: 11)
        contentLabel.backgroundColor = UIColor.systemGray6
        contentLabel.layer.cornerRadius = 10
        contentLabel.clipsToBounds = true
       // contentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
       // contentLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let container = UIStackView(arrangedSubviews: [dateLabel, contentLabel])
        container.axis = .vertical
        container.spacing = 5
        container.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        container.isLayoutMarginsRelativeArrangement = true
        container.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //container.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        //container.setContentHuggingPriority(.defaultLow, for: .vertical)

        historyStackView.addArrangedSubview(container)
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
