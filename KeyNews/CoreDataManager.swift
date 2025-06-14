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
    static let shared = CoreDataManager()
    
    
    lazy var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).context
    }()
    //let context = (UIApplication.shared.delegate as! AppDelegate).context
    func saveContext() {
        let context = self.context
        if context.hasChanges {
            do {
                try context.save()
                print("Context 저장 완료")
            } catch {
                print("Context 저장 실패: \(error)")
            }
        }
    }
    func addOrUpdateSummary(summary: Summary) {
        let dateOnly = Calendar.current.startOfDay(for: summary.date)
        let fetchRequest: NSFetchRequest<SummaryEntity> = SummaryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@ AND keyword == %@", dateOnly as CVarArg, summary.keyword)
        
        do {
            if let existing = try context.fetch(fetchRequest).first {
                // 이미 존재하면 내용만 업데이트
                existing.content = summary.content
                print("!!! 기존 요약 업데이트 완료")
            } else {
                // 없으면 새로 추가
                let newSummary = SummaryEntity(context: context)
                newSummary.date = dateOnly //summary.date
                newSummary.keyword = summary.keyword
                newSummary.content = summary.content
                print("!!! 새로운 요약 저장 완료")
            }
            try context.save()
        } catch {
            print("저장/업데이트 실패: \(error)")
        }
    }
    
    
    func addSummary(summary : Summary) {
        
        let summaryEntity = SummaryEntity(context: context)
        let dateOnly = Calendar.current.startOfDay(for: summary.date)
        
        summaryEntity.date = dateOnly // summary.date
        summaryEntity.keyword = summary.keyword
        summaryEntity.content = summary.content
        do {
            try context.save()
            print("저장 성공!")
        } catch {
            print("저장 실패: \(error)")
        }
    }
    
    
    
    func updateSummary(summary : Summary) {
        let dateOnly = Calendar.current.startOfDay(for: summary.date)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        let fetchRequest: NSFetchRequest<SummaryEntity> = SummaryEntity.fetchRequest ()
        fetchRequest.predicate = NSPredicate(format: "date == %@", dateOnly as CVarArg)
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
        let dateOnly = Calendar.current.startOfDay(for: summary.date)
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        let fetchRequest: NSFetchRequest<SummaryEntity> = SummaryEntity.fetchRequest ()
        fetchRequest.predicate = NSPredicate (format: "date == %@", dateOnly as CVarArg)
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
    
    func fetchAllSummaries() -> [SummaryEntity] {
        
        /*
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        let fetchRequest: NSFetchRequest<SummaryEntity> = SummaryEntity.fetchRequest ()
        do {
            return try context.fetch (fetchRequest)
        } catch {
            print ("조회 실패 \(error)")
            return []
        }*/
        
        // 경고 수정 후 >
        var results: [SummaryEntity] = []
        DispatchQueue.main.sync {
            let context = (UIApplication.shared.delegate as! AppDelegate).context
            let fetchRequest: NSFetchRequest<SummaryEntity> = SummaryEntity.fetchRequest()
            do {
                results = try context.fetch(fetchRequest)
            } catch {
                print("조회 실패 \(error)")
            }
        }
        return results
    }
    
        
    
}
