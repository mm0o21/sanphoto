//
//  EditViewController.swift
//  sanphoto
//
//  Created by Maoko Furuya on 2022/09/15.
//

import UIKit
import CoreLocation
import RealmSwift

class EditViewController: UIViewController, UITextFieldDelegate , CLLocationManagerDelegate{
    
    @IBOutlet var adrLabel: UILabel!
    @IBOutlet var dog1Button: UIButton!
    @IBOutlet var dog2Button: UIButton!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var updateButton: UIButton!
    let imageView = UIImageView?(<#UIImageView#>)
//    let imageView2 = UIImageView?(<#UIImageView#>)
    let dog1 = UIImage(named: "dog1")!
    let dog2 = UIImage(named: "dog2")!
    var datePicker = UIDatePicker()
    var adr: String!
    
    let realm = try! Realm()
    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    // ドキュメントディレクトリの「パス」（String型）定義
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //日付のやつ関連
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        dateField.inputView = datePicker
        dateField.inputAccessoryView = toolbar
        
        dateField.delegate = self
        
        adrLabel.layer.cornerRadius = 10
        adrLabel.clipsToBounds = true
        dog1Button.layer.cornerRadius = 10
        dog2Button.layer.cornerRadius = 10
        updateButton.layer.cornerRadius = 10
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    
    @IBAction func tapDog1(){
        dog1Button.setImage(dog1, for: .normal)
        dog1Button.layer.backgroundColor = UIColor(hex: "dcdcdc",alpha: 1.0).cgColor
        dog2Button.layer.backgroundColor = UIColor(hex: "ffffff",alpha: 1.0).cgColor
    }
    
    
    @IBAction func tapDog2(){
        dog2Button.setImage(dog2, for: .normal)
        dog1Button.layer.backgroundColor = UIColor(hex: "ffffff",alpha: 1.0).cgColor
        dog2Button.layer.backgroundColor = UIColor(hex: "dcdcdc",alpha: 1.0).cgColor
    }
    
    
    //日付のdoneボタン
    @objc func done() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        dateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    
    @IBAction func update(){
        //Realmに保存
        //1.realmに保存する画像を用意
        let image = UIImage(named: "dog1")!
        //2.画像のファイル名を生成
        let filename = UUID.init().uuidString + ".jpg"
        //3.画像をdocumentDirectoryに保存
        image.saveToDocuments(filename: filename)
        
        //4.realmに画像のファイル名(```filename```)を保存する
        let photo = Pin()
        photo.image = filename

        //Realmからの呼び込み
        //1.Realmから保存した画像のファイル名をとってくる
        //ここは自分で頑張ってみて！変数```newfilename```を新しくつくってそこに保存しよう！

        //2.documentDirectoryから画像を読み込む
        //let newImage = UIImage.getFromDocuments(filename: newfilename)
        //imageView.image = newImage

        
        self.dismiss(animated: true)
        
    }
    

        

    


    //realm呼び出してる
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            adrLabel.text = adr

            DispatchQueue(label: "background").async {
                let realm = try! Realm()

                if realm.objects(Pin.self).last != nil {
                    DispatchQueue.main.async {
                        self.adrLabel.text = self.adr
                    }
                }
            }

        }

}


extension UIImage {
    func saveToDocuments(filename:String){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = self.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }
    static func getFromDocuments(filename: String) -> UIImage {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let data = try! Data(contentsOf: documentsDirectory.appendingPathComponent(filename))
        let image = UIImage(data: data)
        return image!
    }

}
    

