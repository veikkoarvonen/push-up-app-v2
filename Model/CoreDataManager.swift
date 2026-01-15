//
//  CoreDataManager.swift
//  Push Up App V2
//
//  Created by Veikko Arvonen on 13.1.2026.
//
//

import Foundation
import CoreData

final class CoreDataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    
    // MARK: - Properties
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Init
    init(modelName: String = "Push_Up_App_V2") {
        // IMPORTANT: Replace "YourModelName" with the .xcdatamodeld filename (without extension)
        container = NSPersistentContainer(name: modelName)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        // Recommended defaults
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    //MARK: - Create workout
    func createWorkout(reps: Int16, date: Date) {
        let workout = Workout(context: viewContext)
        workout.reps = reps
        workout.date = date
        saveContext()
    }
    
    //MARK: - Fetch workouts
    func fetchAllWorkouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch all workouts error: \(error)")
            return []
        }
    }
    
    func fetchWorkouts(from startDate: Date, to endDate: Date) -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K >= %@ AND %K < %@",
            #keyPath(Workout.date), startDate as NSDate,
            #keyPath(Workout.date), endDate as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Workout.date), ascending: true)
        ]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Fetch workouts range error:", error)
            return []
        }
    }

    
    //MARK: - Delete all
    func deleteAllWorkouts() {
        let request: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try container.persistentStoreCoordinator.execute(deleteRequest, with: viewContext) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContext])
            }
        } catch {
            print("Batch delete error: \(error)")
        }
    }
    
    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
    
    func logAllWorkouts() {
        let workouts = fetchAllWorkouts()
        for workout in workouts {
            let date = workout.date ?? Date()
            let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let formattedDateString = "\(comps.day!)/\(comps.month!)/\(comps.year!)"
            print("Workout: \(formattedDateString), push ups: \(workout.reps), exact logTime: \(date)")
        }
    }
    
    
    func generateTestDataForThisWeek(mon: Int16, tue: Int16, wed: Int16, thu: Int16, fri: Int16, sat: Int16, sun: Int16) {
        
        let cal = Calendar.current
        let now = Date()

        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: now)

        let year = comps.yearForWeekOfYear!
        let week = comps.weekOfYear!
        var weekday = 2  // 1 = Sunday, 2 = Monday, ... 7 = Saturday
        
        for _ in 0..<7 {
            let dateToLog = cal.date(from: DateComponents(year: year, weekday: weekday, weekOfYear: week))!
            //let roundedDate = Calendar.current.startOfDay(for: dateToLog)
            
            var reps: Int16 {
                switch weekday {
                case 1: return sun
                case 2: return mon
                case 3: return tue
                case 4: return wed
                case 5: return thu
                case 6: return fri
                case 7: return sat
                default: return 0
                }
            }
            
            createWorkout(reps: reps, date: dateToLog)
            
            if weekday == 7 {
                weekday = 1
                //week += 1
            } else {
                weekday += 1
            }
        }
        
        
        
    }
    
    func getDatesForThisWeek() -> [Date] {
        let cal = Calendar.current
        let now = Date()
        
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: now)
        
        let year = comps.yearForWeekOfYear!
        let week = comps.weekOfYear!
        var weekday: Int = 2
        
        var datesToReturn: [Date] = []
        
        for _ in 0..<7 {
            let dateToLog = cal.date(from: DateComponents(year: year, weekday: weekday, weekOfYear: week))!
            datesToReturn.append(dateToLog)
            
            if weekday == 7 {
                weekday = 1
                //week += 1
            } else {
                weekday += 1
            }
        }
        
        return datesToReturn
        
    }
    
    
}

