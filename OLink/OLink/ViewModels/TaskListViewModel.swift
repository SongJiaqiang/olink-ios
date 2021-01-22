//
//  TaskListViewModel.swift
//  OLink
//
//  Created by SJQ on 2021/1/19.
//

import Foundation
import Combine
import Resolver

class TaskListViewModel: ObservableObject {
    @Published var taskCellViewModels = [TaskCellViewModel]()
    @Published var taskRepository: TaskRepository = Resolver.resolve()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        taskRepository.$tasks.map { tasks in
            tasks.map{ task in
                TaskCellViewModel(task: task)
            }
        }
        .assign(to: \.taskCellViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func removeTask(atOffset indexSet: IndexSet) {
        let viewModels = indexSet.lazy.map{self.taskCellViewModels[$0]}
        viewModels.forEach { taskCellViewModel in
            taskRepository.removeTask(taskCellViewModel.task)
        }
    }
    
    func addTask(task: Task) {
        taskRepository.addTask(task)
    }
    
    
}




