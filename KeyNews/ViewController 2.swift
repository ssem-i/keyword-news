import UIKit

class TotalNewsController: UIViewController {

    
    var themes = ["사과", "바나나", "초코", "커피", "라면", "영화", "여행", "날씨", "게임", "책"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
   //     keywordsStackView.heightAnchor.constraint(equalTo: keywordsScrollView.heightAnchor).isActive = true
       // loadKeywords()

    }
    
    
    func loadKeywords() {
        for i in themes {
                let button = UIButton(type: .system)
                button.setTitle(i, for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .systemBlue
                button.layer.cornerRadius = 8
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
              //  keywordsStackView.addArrangedSubview(button)
            }
    }
}
