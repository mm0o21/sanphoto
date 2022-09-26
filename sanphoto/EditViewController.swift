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
    let dog1 = UIImage(named: "dog1")!
    let dog2 = UIImage(named: "dog2")!
    var datePicker = UIDatePicker()
    
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
        
        // adrLabel.text =
    }
    
    
    @IBAction func tapDog1(){
        dog1Button.setImage(dog1, for: .normal)
        dog1Button.layer.backgroundColor = UIColor(hex: "dcdcdc",alpha: 1.0).cgColor
        dog2Button.layer.backgroundColor = UIColor(hex: "ffffff",alpha: 1.0).cgColor
    }
    
    
    @IBAction func tapDog2(){
        dog1Button.setImage(dog2, for: .normal)
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
        //let coordinate =
        //let location = CLLocation(latitude://ピンの緯度, longitude://ピンの経度)
        
//        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//                    guard
//                        let placemark = placemarks?.first, error == nil,
//                        let administrativeArea = placemark.administrativeArea, //都道府県
//                        let locality = placemark.locality, //市区町村
//                        let thoroughfare = placemark.thoroughfare, //丁目
//                        let subThoroughfare = placemark.subThoroughfare //番地
//
//                        else {
//                            self.adrLabel.text = "---"
//                            return
//                    }
//
//                    self.adrLabel.text = """
//                        \(administrativeArea)\(locality)\(thoroughfare)\(subThoroughfare)
//                    """
//                }
        
        //Realmのテーブルをインスタンス化
                let table = Pin()
                do{
                    try table.imageURL = documentDirectoryFileURL.absoluteString
                }catch{
                    print("画像の保存に失敗しました")
                }
                try! realm.write{realm.add(table)}
        
        saveImage()
    }
    
    //保存するためのパスを作成する
    func createLocalDataFile() {
        // 作成するテキストファイルの名前
        let fileName = "\(NSUUID().uuidString).png"

        // DocumentディレクトリのfileURLを取得
        if documentDirectoryFileURL != nil {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let path = documentDirectoryFileURL.appendingPathComponent(fileName)
            documentDirectoryFileURL = path
        }
    }
    
    //画像を保存
    func saveImage() {
        createLocalDataFile()
        //保存
        let ImageData = dog1Button.image(for: .normal)
        do {
            try ImageData?.write(to: documentDirectoryFileURL)
        } catch {
            //エラー処理
            print("エラー")
        }
    }

}
    

