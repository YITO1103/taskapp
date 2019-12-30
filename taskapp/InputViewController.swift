//
//  InputViewController.swift
//  taskapp
//
//  Created by user1 on 2019/12/29.
//  Copyright © 2019 yutaka.ito4. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    let realm = try! Realm()    // 追加する
    var task: Task!   //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
    }
    
    
    // メソッドは遷移する際に、画面が非表示になるとき呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }

        super.viewWillDisappear(animated)
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
}
