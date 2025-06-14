//
//  NewsService.swift
//  KeyNews
//
//  Created by ssem on 6/12/25.
//
import UIKit
import Foundation

struct NewsItem: Decodable {
    let title: String
    let link: String
    let description: String
}

struct NewsResponse: Decodable {
    let items: [NewsItem]
}

class NewsService {
    static let shared = NewsService()
    
    private var myId: String?
    private var mySecret: String?
    
    private init() {
        loadAPIKeys()
    }
    
    private func loadAPIKeys(){
        if let url = Bundle.main.url(forResource: "Property List", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] {

            myId = dict["myId"]
            mySecret = dict["mySecret"]
            //print("id: \(myId ?? "nil"), secret: \(mySecret ?? "nil")")
        }
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
    
}

