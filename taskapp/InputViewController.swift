//
//  InputViewController.swift
//  taskapp
//
//  Created by user1 on 2019/12/29.
//  Copyright © 2019 yutaka.ito4. All rights reserved.
//

import UIKit
import RealmSwift

import UserNotifications


class InputViewController: UIViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var navigationItemButtonBack: UINavigationItem!
    
    @IBOutlet var inputViewSafeArea: UIView!
    
    @IBOutlet weak var registButton: UIButton!
    
    
    @IBAction func registButton(_ sender: Any) {
        
        print("registButton")
        
        if bEdit {
            // 編集中
            print("navigationItemButtonBack")
            // 更新
            jobUpdate()
            // 一覧に遷移
            self.navigationController?.popViewController(animated: true)
        }
        else{
            // 閲覧中
            bEdit = true
            setMode()
        }

    }
    
    var bEdit:Bool = false

    let realm = try! Realm()    // 追加する
    var task: Task!   //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        
        categoryTextField.text = task.category
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        //print(bEdit)
        setMode()
        
    }
    func setMode() {

        let bgColor =
            (bEdit ? UIColor.init(red: 235, green: 235, blue: 235, alpha: 0.3):UIColor.systemGroupedBackground)
        let sRegButtonCaption = (bEdit ? "登録して一覧に戻る" : "編集する")
        categoryTextField.isEnabled = bEdit
        titleTextField.isEnabled = bEdit
        contentsTextView.isEditable = bEdit
        datePicker.isEnabled = bEdit
        datePicker.isSelected = bEdit
                
        inputViewSafeArea.backgroundColor = bgColor
        inputViewSafeArea.isOpaque = bEdit

        categoryTextField.backgroundColor = inputViewSafeArea.backgroundColor
        titleTextField.backgroundColor = inputViewSafeArea.backgroundColor
        registButton.setTitle(sRegButtonCaption, for: .normal)
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    func jobUpdate() {
        if self.titleTextField.text! != "" {
            try! realm.write {
                self.task.category = self.categoryTextField.text!
                self.task.title = self.titleTextField.text!
                self.task.contents = self.contentsTextView.text
                self.task.date = self.datePicker.date
                self.realm.add(self.task, update: .modified)
            }
            setNotification(task: task)   // 追加
        }



    }

    
    // メソッドは遷移する際に、画面が非表示になるとき呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        /*
        if bEdit {
            if self.titleTextField.text! != "" {
                try! realm.write {
                    self.task.category = self.categoryTextField.text!
                    self.task.title = self.titleTextField.text!
                    self.task.contents = self.contentsTextView.text
                    self.task.date = self.datePicker.date
                    self.realm.add(self.task, update: .modified)
                }
                setNotification(task: task)   // 追加
            }
         }
        */
        
        super.viewWillDisappear(animated)
    }

    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()


        if task.category == "" {
           content.categoryIdentifier = "(カテゴリなし)"
        } else {
            content.categoryIdentifier = task.category
        }

        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
