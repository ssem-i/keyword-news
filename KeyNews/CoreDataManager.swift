//
//  CoreDataManager.swift
//  KeyNews
//
//  Created by ssem on 6/13/25.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager() // 싱글톤
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).context
        
    
    
    
    func addSummary(summary : Summary) {
        let summaryEntity = Summaries(context: context)
        summaryEntity.date = summary.date
        summaryEntity.content = summary.content
        do {
            try context.save()
            print("저장 성공!")
        } catch {
            print("저장 실패: \(error)")
        }
    }
    
    
    
    func updateSummary(summary : Summary) {
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        let fetchRequest: NSFetchRequest<Summaries> = Summaries.fetchRequest ()
        fetchRequest.predicate = NSPredicate(format: "date == %@", summary.date)
        do {
            if let summaryEntity = try context.fetch(fetchRequest) .first {
                summaryEntity.content = summary.content
                try context.save()
                print("수정 성공!")
            } else {
                print ("해당 날짜의 데이터가 없습니다. ")
            }
        }
        catch {
            print("수정 실패 \(error)")
        }
    }
    
    func deleteSummary(summary : Summary) {
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        let fetchRequest: NSFetchRequest<Summaries> = Summaries.fetchRequest ()
        fetchRequest.predicate = NSPredicate (format: "date == %@", summary.date)
        do {
            let summaries = try context.fetch(fetchRequest)
            for summary in summaries {
                context.delete(summary)
            }
            try context.save ()
            print("삭제 성공!")
        } catch {
            print("삭제 실패 V(error)")
        }
    }
    
    func fetchAllSummaries() -> [Summaries] {
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        let fetchRequest: NSFetchRequest<Summaries> = Summaries.fetchRequest ()
        do {
            return try context.fetch (fetchRequest)
        } catch {
            print ("조회 실패 \(error)")
            return []
        }
    }
}
