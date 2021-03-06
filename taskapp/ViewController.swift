//
//  ViewController.swift
//  taskapp
//
//  Created by user1 on 2019/12/29.
//  Copyright © 2019 yutaka.ito4. All rights reserved.
//

import UIKit
import RealmSwift   // ◆
import UserNotifications



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンス
    let realm = try! Realm()   // ◆
        
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        
        //print(taskArray)
        
    }

    // データの数（＝セルの数）を返すメソッド
    // データの配列であるtaskArrayの要素数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 一つのsectionの中に入れるCellの数を決める。
        return taskArray.count
    }

    // 各セルの内容を返すメソッド
    // データの配列であるtaskArrayから該当するデータを取り出してセルに設定します。
    // ここで登場するDateFormatterクラスは日付を表すDateクラスを任意の形の文字列に変換する機能を持ちます
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- ここまで追加 ---

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    // UITableViewDelegateプロトコルのメソッドで、セルをタップした時にタスク入力画面に遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }

    // セルが削除が可能なことを伝えるメソッド
    // UITableViewDelegateプロトコルのメソッドで、セルが削除可能なことを伝える
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            // セルをタップした時
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            print(taskArray[indexPath!.row])
        } else {
            // +ボタンをタップした時
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
                print(task)
            }

            inputViewController.task = task
        }
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print(taskArray)
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    // UITableViewDataSourceプロトコルのメソッドで、Deleteボタンが押されたときにローカル通知をキャンセルし、
    // データベースからタスクを削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {


        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
}

