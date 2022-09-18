//
//  ViewController.swift
//  sanphoto
//
//  Created by Maoko Furuya on 2022/09/13.
//

import UIKit
import MapKit
import CoreLocation

//ピンを継承したクラス
class mapAnnotationSetting: MKPointAnnotation{
    var pinImage: UIImage?
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    @IBOutlet var mapButton: UIButton!
   // var mapImages = [UIImage?] = [UIImage(named: "map-red"), UIImage(named: "map-pink""), UIImage(named: "map-orangek"), UIImage(named: "map-yellow"), UIImage(named: "map-green"), UIImage(named: "map-lightblue"), UIImage(named: "map-blue"), UIImage(named: "map-gray"), UIImage(named: "map1")]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //locationManagerのセットアップ
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        // 0.01が距離の倍率
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // 表示する中心の緯度、経度を指定
        let coordinate = CLLocationCoordinate2D(latitude: 35.6431, longitude: 139.7342)
        //現在地の情報取得(centerで設定)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.region = region
        mapButton.layer.cornerRadius = 10
        
        mapView.delegate = self
    }
    

    @IBAction func addPin(){
        //現在地
        let coordinate = mapView.userLocation.coordinate
        //ピンを生成
        let pin = MKPointAnnotation()
//        pin.title = "タイトル"
//        pin.subtitle = "サブタイトル"
        //ピンに現在地を設定
        pin.coordinate = coordinate
        //mapにピンを表示
        mapView.addAnnotation(pin)
        
        let viewController = EditViewController()
        if let sheet = viewController.sheetPresentationController{
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 10.0
        }
        present(viewController, animated: true)
        
    }
    

    //許可を求める
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            manager.startUpdatingLocation()
            break
        }
    }
    
    

}

