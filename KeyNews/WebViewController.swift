//  WebViewController.swift
//  KeyNews
import UIKit
import WebKit

class WebViewController: UIViewController {

    var urlString: String?  // 외부에서 넘겨줄 URL

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlString = urlString,
           let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

}

