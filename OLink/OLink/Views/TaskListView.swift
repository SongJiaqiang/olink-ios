//
//  TaskListView.swift
//  OLink
//
//  Created by SJQ on 2021/1/5.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var taskListVM = TaskListViewModel()
    @State var presentAddNewItem = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, content: {
                List {
                    ForEach (taskListVM.taskCellViewModels) { taskCellVM in
                        TaskCell(taskCellVM: taskCellVM)
                    }
                    .onDelete(perform: { indexSet in
                        self.taskListVM.removeTask(atOffset: indexSet)
                    })
                    
                    if presentAddNewItem {
                        TaskCell(taskCellVM: TaskCellViewModel.newTask()) { result in
                            switch result {
                            case .success(let task):
                                self.taskListVM.addTask(task: task)
                                break
                            case .failure(let error):
                                print("Add task failed: \(error)")
                                break
                            }
                            self.presentAddNewItem.toggle()
                        }
                    }
                }
                Button(action: {
                    self.presentAddNewItem.toggle()
                }) {
                    HStack(
                        content: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("New Task")
                        }
                    )
                }
                .padding()
                .accentColor(Color(UIColor.systemRed))
            })
            .navigationTitle("Tasks")
        }
        
    }
    
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}

struct TaskCell: View {
    @ObservedObject var taskCellVM: TaskCellViewModel
    var onCommit: (Result<Task, InputError>) -> Void = {result in
        print("on commit: \(result)")
    }
    
    var body: some View {
        HStack {
            Image(systemName: taskCellVM.completionStateIconName)
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    self.taskCellVM.task.completed.toggle()
                }
            TextField("Enter task title", text: $taskCellVM.task.title, onCommit: {
                if !self.taskCellVM.task.title.isEmpty {
                    self.onCommit(.success(self.taskCellVM.task))
                } else {
                    self.onCommit(.failure(.empty))
                }
            }).id(taskCellVM.id)
        }
    }
}

enum InputError: Error {
    case empty
}

