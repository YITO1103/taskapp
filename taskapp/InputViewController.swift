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

        if bEdit {
                 
            let sInputN = getInputValues()
            if  !sInput.elementsEqual(sInputN) {
             
                 //
                 var sMsg = ""
                 if titleTextField.text == nil || titleTextField.text == "" {
                    sMsg = "タイトル"
                 }
                 if contentsTextView.text == nil || contentsTextView.text == "" {
                     if sMsg.count>0 {
                         sMsg += "、"
                     }
                     sMsg += "内容"
                 }
                if !sMsg.isEmpty {
                    let title = "エラー"
                    let message = sMsg + "は必須です。"
                    let okText = "OK"

                    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                    let okayButton = UIAlertAction(title: okText, style: UIAlertAction.Style.cancel, handler: nil)
                    alert.addAction(okayButton)
                    present(alert, animated: true, completion: nil)
                    return
                }
  
            }

            //--------------------------------
            // ① UIAlertControllerクラスのインスタンスを生成
            // タイトル, メッセージ, Alertのスタイルを指定する
            // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
            let alert: UIAlertController = UIAlertController(title: "確認", message: "登録します。よろしいですか？。\n登録後一覧画面に遷移します。", preferredStyle:  UIAlertController.Style.alert)

            // ② Actionの設定
            // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
            // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
            // OKボタン

            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                // 登録
                self.jobUpdate()
                // 一覧に遷移
                self.navigationController?.popViewController(animated: true)
            })

            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                return
            })

            // ③ UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            // ④ Alertを表示
            present(alert, animated: true, completion: nil)
            //---------------------------------
        }
        else {
            // 閲覧中
            bEdit = true
            setMode()
        }
 
    }

    var bEdit:Bool = false
    let realm = try! Realm()    // 追加する
    var task: Task!   //
    
    var sInput = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        categoryTextField.text = task.category
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date

        // 枠のカラー
        contentsTextView.layer.borderColor = UIColor.gray.cgColor
        // 枠の幅
        contentsTextView.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        contentsTextView.layer.cornerRadius = 0
        contentsTextView.layer.masksToBounds = true
        sInput = getInputValues()
        print(sInput)
        setMode()

        let barButton = UIBarButtonItem(title: "一覧",style: .plain, target: self, action: #selector(barLeftButtonTapped(_:)))

        navigationItem.leftBarButtonItem = barButton

    }
    
    @objc func barLeftButtonTapped(_ sender: UIBarButtonItem) {
        
        let sInputN = getInputValues()
        if !sInput.elementsEqual(sInputN) {
            //--------------------------------
            // ① UIAlertControllerクラスのインスタンスを生成
            // タイトル, メッセージ, Alertのスタイルを指定する
            // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
            let alert: UIAlertController = UIAlertController(title: "確認", message: "変更されてます。\n内容を破棄してもいいですか？", preferredStyle:  UIAlertController.Style.alert)

            // ② Actionの設定
            // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
            // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(title: "ハイ", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
                self.navigationController?.popViewController(animated: true)
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
                return
            })

            // ③ UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)

            // ④ Alertを表示
            present(alert, animated: true, completion: nil)
            //---------------------------------
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func setMode() {
        let bgColor =
            (bEdit ? UIColor.init(red: 235, green: 235, blue: 235, alpha: 0.3):UIColor.systemGroupedBackground)
        let sRegButtonCaption = (bEdit ? "登録する" : "編集する")
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
    func getInputValues() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: datePicker.date)

        let sStr =
        categoryTextField.text!
        + titleTextField.text!
        + self.contentsTextView.text
        + dateString
        
        return sStr
    }
    

    // メソッドは遷移する際に、画面が非表示になるとき呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        // 使わない
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
