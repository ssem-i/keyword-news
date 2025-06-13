//
//  SummaryService.swift
//  KeyNews
//
//  Created by ssem on 6/12/25.
//

import Foundation

class SummaryService {
    
    private var myId: String?
    private var mySecret: String?
    private var myOpenai: String?
    
    static let shared = SummaryService()
    private init() {
        loadAPIKeys()
    }
    
    private func loadAPIKeys(){
        if let url = Bundle.main.url(forResource: "Property List", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] {
 
            myId = dict["myId"]
            mySecret = dict["mySecret"]
            myOpenai = dict["myOpenai"]
            //print("id: \(myId ?? "nil"), secret: \(mySecret ?? "nil")")
        }
    }
    
    func summarizeNews(word: String, articles: [NewsItem], completion: @escaping (String) -> Void) {
        let combinedText = articles.prefix(5).map {
            "• \($0.title.cleanedHTML)\n\($0.description.cleanedHTML)"
        }.joined(separator: "\n\n")
        
        print("=======================\n")
        print(combinedText)
        let prompt = """
        당신의 임무는 사용자가 관심있는 키워드의 뉴스를 요약하는 것입니다.
        아래는 사용자가 선택한 키워드 "\(word)"에 대한 뉴스입니다. 핵심 이슈를 4개 이하로 선정하여 3줄 이내로 요약하세요.

        \(combinedText)
        """
        
        callGPT(prompt: prompt, completion: completion)
    }
    
    private func callGPT(prompt: String, completion: @escaping (String) -> Void) {
        guard let key = myOpenai else {
            completion("⚠️ OpenAI API 키가 없습니다.")
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        // 인증 헤더, JSON 형식 명시
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // GPT 메시지 포맷
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "뉴스 요약 전문가입니다."], // GPT 성격 지정
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.5
        ]
        // JSON 형태로 BODY를 직렬화
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        // 비동기로 API 요청 보냄. 동기로 보내면 응답올 때까지 UI 반응이 없음
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 바이너리 형태를 JSON으로 변환
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]], // 여러 응답 중 1번째 결과
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion("요약 실패")
                return
            }
            // 불필요한 공백 제거
            completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
        }.resume()
    }
}
