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
    //@IBOutlet var imageView: UIImageView!
   // @IBOutlet var image2View: UIImageView!
    
//    let dog1 = UIImage(named: "dog1")!
//    let dog2 = UIImage(named: "dog2")!
//    let dog1Gray = UIImage(named: "pug-gray-128")!
//    let dog2Gray = UIImage(named: "golden-gray-128")
    var datePicker = UIDatePicker()
    var adr: String!
    var date: String!
    
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
        
        let _: Pin? = read()
        
    }
    
    func read() -> Pin?{
        return realm.objects(Pin.self).first
    }
    
    @IBAction func tapDog1(){
        dog1Button.layer.backgroundColor = UIColor(hex: "dcdcdc",alpha: 1.0).cgColor
        dog2Button.layer.backgroundColor = UIColor(hex: "ffffff",alpha: 1.0).cgColor
    }
    
    
    @IBAction func tapDog2(){
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
        
//                //realmクラスのインスタンスを作成
//                let realm = try! Realm()
//                //realmstudioみたい
//                print(Realm.Configuration.defaultConfiguration.fileURL!)
//                //保存するUIImageを設定
//                let image = UIImage(named: "dog1")!
//                //ファイル名を指定
//                let filename = UUID.init().uuidString + ".jpg"
//                //documentのパスを取得
//                let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                //documentのパスとファイル名を取得
//                let path = directoryURL.appendingPathExtension(filename)
//                //URL String
//                let pathString = path.path
//                //jpeg
//                try! image.jpegData(compressionQuality: 100)?.write(to:URL(fileURLWithPath: pathString))
//                //Pinクラスのインスタンスを生成
//                let photo = Pin()
//                //インスタンスののimageカラムに画像のパスを代入
//                photo.image = path.absoluteString
//
//        if let last = realm.objects(Pin.self).sorted(byKeyPath: "id",ascending: true).last{
//            photo.id = last.id + 1
//            try! realm.write{
//                realm.add(photo)
//            }
//        }
        
        //let realm = try! Realm()
        let diary = Pin()
        if let dates = dateField.text{
            diary.date = dates
        }
        try! realm.write {
            realm.add(diary, update:.modified) // Realmに追加
           }

        
        self.dismiss(animated: true)
        
    }

    //realm呼び出してる
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.beginAppearanceTransition(false, animated: animated)
            super.viewWillAppear(animated)
        self.adrLabel.text = adr
        print("わーーーー", adr)

            //adrLabel.text = adr

                let realm = try! Realm()
        
                if let pin = realm.object(ofType: Pin.self, forPrimaryKey: 1) {
                    self.dateField.text = pin.date
                    self.adrLabel.text = pin.address
                }

                if realm.objects(Pin.self).last != nil {
                    self.adrLabel.text = self.adr
                    self.dateField.text = self.date
                    //print("ここだよーーーーー", self.adr, self.date)
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
    

