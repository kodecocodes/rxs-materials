/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import RealmSwift
import RxSwift
import RxRealm

struct TaskService: TaskServiceType {

  init() {
    // create a few default tasks
    do {
      let realm = try Realm()
      if realm.objects(TaskItem.self).count == 0 {
        ["Chapter 5: Filtering operators",
         "Chapter 4: Observables and Subjects in practice",
         "Chapter 3: Subjects",
         "Chapter 2: Observables",
         "Chapter 1: Hello, RxSwift"].forEach {
          self.createTask(title: $0)
        }
      }
    } catch _ {
    }
  }

  private func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
    do {
      let realm = try Realm()
      return try action(realm)
    } catch let err {
      print("Failed \(operation) realm with error: \(err)")
      return nil
    }
  }

  @discardableResult
  func createTask(title: String) -> Observable<TaskItem> {
    let result = withRealm("creating") { realm -> Observable<TaskItem> in
      let task = TaskItem()
      task.title = title
      try realm.write {
        task.uid = (realm.objects(TaskItem.self).max(ofProperty: "uid") ?? 0) + 1
        realm.add(task)
      }
      return .just(task)
    }
    return result ?? .error(TaskServiceError.creationFailed)
  }

  @discardableResult
  func delete(task: TaskItem) -> Observable<Void> {
    let result = withRealm("deleting") { realm-> Observable<Void> in
      try realm.write {
        realm.delete(task)
      }
      return .empty()
    }
    return result ?? .error(TaskServiceError.deletionFailed(task))
  }

  @discardableResult
  func update(task: TaskItem, title: String) -> Observable<TaskItem> {
    let result = withRealm("updating title") { realm -> Observable<TaskItem> in
      try realm.write {
        task.title = title
      }
      return .just(task)
    }
    return result ?? .error(TaskServiceError.updateFailed(task))
  }

  @discardableResult
  func toggle(task: TaskItem) -> Observable<TaskItem> {
    let result = withRealm("toggling") { realm -> Observable<TaskItem> in
      try realm.write {
        if task.checked == nil {
          task.checked = Date()
        } else {
          task.checked = nil
        }
      }
      return .just(task)
    }
    return result ?? .error(TaskServiceError.toggleFailed(task))
  }

  func tasks() -> Observable<Results<TaskItem>> {
    let result = withRealm("getting tasks") { realm -> Observable<Results<TaskItem>> in
      let realm = try Realm()
      let tasks = realm.objects(TaskItem.self)
      return Observable.collection(from: tasks)
    }
    return result ?? .empty()
  }

  // Challenge 2
  func numberOfTasks() -> Observable<Int> {
    let result = withRealm("number of tasks") { realm -> Observable<Int> in
      let tasks = realm.objects(TaskItem.self)
      return Observable.collection(from: tasks)
        .map(\.count)
    }
    return result ?? .empty()
  }

  // Challenge2
  func statistics() -> Observable<TaskStatistics> {
    let result = withRealm("getting statistics") { realm -> Observable<TaskStatistics> in
      let tasks = realm.objects(TaskItem.self)
      let todoTasks = tasks.filter("checked != nil")
      return .combineLatest(
        Observable.collection(from: tasks)
          .map(\.count),
        Observable.collection(from: todoTasks)
          .map(\.count)) { all, done in
            (todo: all - done, done: done)
          }
    }
    return result ?? .empty()
  }
}
