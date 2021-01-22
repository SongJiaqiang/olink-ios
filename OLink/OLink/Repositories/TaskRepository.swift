//
//  TaskRepository.swift
//  OLink
//
//  Created by SJQ on 2021/1/21.
//

import Foundation
import Combine
import Resolver
import Disk
import FirebaseFirestore
import FirebaseFirestoreSwift

class BaseTaskRepository {
    @Published var tasks = [Task]()
}

protocol TaskRepository: BaseTaskRepository {
    func addTask(_ task: Task)
    func removeTask(_ task: Task)
    func updateTask(_ task: Task)
}

class TestDataTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    override init() {
        super.init()
        self.tasks = testDataTasks
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            tasks.remove(at: index)
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            self.tasks[index] = task
        }
    }
}

class LocalTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    
    override init() {
        super.init()
        loadData()
    }
    
    func addTask(_ task: Task) {
        self.tasks.append(task)
        saveData()
    }
    
    func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            tasks.remove(at: index)
            saveData()
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            self.tasks[index] = task
            saveData()
        }
    }
    
    private func loadData() {
        if let retrievedTasks = try? Disk.retrieve("tasks.json", from: .documents, as: [Task].self) {
            self.tasks = retrievedTasks
        }
    }
    
    private func saveData() {
        do {
            try Disk.save(self.tasks, to: .documents, as: "tasks.json")
        } catch let error as NSError {
            fatalError("""
            Domain: \(error.domain)
            Code: \(error.code)
            Description: \(error.localizedDescription)
            Failure Reason: \(error.localizedFailureReason ?? "")
            Suggestions: \(error.localizedRecoverySuggestion ?? "")
            """)
        }
    }
}

class FirestoreTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
    var db = Firestore.firestore()

    @Injected var authenticationService: AuthenticationService
    var tasksPath: String = "tasks"
    var userId: String = "unknown"
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        
        authenticationService.$user
            .compactMap { (user) -> String? in
                user?.uid
            }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { (user) in
                self.loadData()
            }
            .store(in: &cancellables)
    }
    
    func addTask(_ task: Task) {
        do {
            var userTask = task
            userTask.userId = self.userId
            let _ = try db.collection("tasks").addDocument(from: userTask)
        } catch let error as NSError {
            print("There was an error while trying to save a task: \(error.localizedDescription)")
        }
    }
    
    func removeTask(_ task: Task) {
        if let taskId = task.id {
            db.collection("tasks").document(taskId).delete { (error) in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateTask(_ task: Task) {
        if let taskId = task.id {
            do {
                try db.collection("tasks").document(taskId).setData(from: task)
            } catch let error as NSError {
                print("There was an error while trying to update a task: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func loadData() {
        db.collection(tasksPath)
            .whereField("userId", isEqualTo: self.userId)
            .order(by: "createdTime")
            .addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.tasks = querySnapshot.documents.compactMap({ (document) -> Task? in
                    try? document.data(as: Task.self)
                })
            }
        }
    }
}

