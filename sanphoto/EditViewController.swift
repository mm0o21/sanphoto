//
//  EditViewController.swift
//  sanphoto
//
//  Created by Maoko Furuya on 2022/09/15.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var adrLabel: UILabel!
    @IBOutlet var dog1Button: UIButton!
    @IBOutlet var dog2Button: UIButton!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var updateButton: UIButton!
    var datePicker = UIDatePicker()
    
    
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
    }
    
    //日付のdoneボタン
    @objc func done() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        dateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
        
}
