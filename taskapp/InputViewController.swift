//
//  InputViewController.swift
//  taskapp
//
//  Created by apple on 2020/02/12.
//  Copyright © 2020 yo.sato. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
    
    //タスクModelインスタンス
    var task: Task!
    
    //コントローラー各種
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!    
    @IBOutlet weak var categoryTextView: UITextField!
    
    //アラート用コントローラー
    var alertController: UIAlertController!
    
    //初期処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
         let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
         self.view.addGestureRecognizer(tapGesture)
        
        self.navigationItem.hidesBackButton = true

        //データをコントロールに設定
         titleTextField.text = task.title
         contentsTextView.text = task.contents
         datePicker.date = task.date
         categoryTextView.text = task.category
    }
    
    //背景タップでキーボードを閉じる
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // タスクのローカル通知を登録する
     func setNotification(task: Task) {
         let content = UNMutableNotificationContent()
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
    
    //保存ボタンを押下
    @IBAction func saveButtonAction(_ sender: Any) {

        //タイトルが空欄の場合はアラートを表示
        if (self.titleTextField.text! == "")
        {
            alert(message: "タイトルを入力してください")
            return
        }
        
        //タスク情報の保存
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextView.text!
            self.realm.add(self.task, update: .modified)
        }
        
        //通知の設定
        setNotification(task: task)
        
        //元の画面に遷移
        self.dismiss(animated: true, completion: nil)
        
    }
        
    //キャンセルボタンを押下
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        //元の画面に遷移
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //アラートを表示
    func alert(message:String) {
        alertController = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
        present(alertController, animated: true)
    }
    
}
