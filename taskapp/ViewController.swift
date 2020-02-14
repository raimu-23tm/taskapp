//
//  ViewController.swift
//  taskapp
//
//  Created by apple on 2020/02/11.
//  Copyright © 2020 yo.sato. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    //Realmインスタンスを取得する
    let realm = try! Realm()
      
    //検索テキストフィールド
    @IBOutlet weak var categoryTextField: UITextField!
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //初期処理
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
                
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //タイトル設定
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        //日付設定
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

        return cell
    }
    
    //「＋」ボタンを押下
    @IBAction func newItemButton(_ sender: Any) {
        
        //遷移先画面のインスタンス作成
        let next = storyboard!.instantiateViewController(withIdentifier: "InputView") as! InputViewController
        
        let task = Task()

        //新規IDを設定
        let allTasks = realm.objects(Task.self)
        if allTasks.count != 0 {
            task.id = allTasks.max(ofProperty: "id")! + 1
        }
        next.task = task
        
        //遷移先画面表示
        next.modalPresentationStyle = .fullScreen
        self.present(next,animated: true, completion: nil)
        
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //segueで遷移
        //performSegue(withIdentifier: "cellSegue",sender: nil)
        
        //遷移先画面のインスタンス作成
        let next = storyboard!.instantiateViewController(withIdentifier: "InputView") as! InputViewController
        
        //セルの値を遷移先画面に設定
        let indexPath = self.tableView.indexPathForSelectedRow
        next.task = taskArray[indexPath!.row]
        
        //遷移先画面表示
        next.modalPresentationStyle = .fullScreen
        self.present(next,animated: true, completion: nil)
                
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
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
    
//    // segue で画面遷移する時に呼ばれる
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        let inputViewController:InputViewController = segue.destination as! InputViewController
//
//        if segue.identifier == "cellSegue" {
//            let indexPath = self.tableView.indexPathForSelectedRow
//            inputViewController.task = taskArray[indexPath!.row]
//        } else {
//            let task = Task()
//
//            let allTasks = realm.objects(Task.self)
//            if allTasks.count != 0 {
//                task.id = allTasks.max(ofProperty: "id")! + 1
//            }
//
//            inputViewController.task = task
//        }
//    }
    
    //検索ボタン
    @IBAction func categorySearch(_ sender: Any) {

        let filterText = categoryTextField.text!
        
        if categoryTextField.text! != "" {
            //カテゴリーでフィルターをかけて情報を取得
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true).filter("category LIKE '*\(filterText)*' ")
        }
        else
        {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        }
        tableView.reloadData()

    }
    
}

