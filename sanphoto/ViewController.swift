//
//  ViewController.swift
//  sanphoto
//
//  Created by Maoko Furuya on 2022/09/13.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

//ピンを継承したクラス
class mapAnnotationSetting: MKPointAnnotation{
    var pinImage: UIImage?
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    @IBOutlet var mapButton: UIButton!
    let realm = try! Realm()
    @IBOutlet var adrLabel : UILabel!
    var adr: String!
    
    //座標の配列
    var coordinatesArray = [["name":"",    "lat":35.68124,  "lon": 139.76672]]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let results = realm.objects(Pin.self)
        for result in results {
            print(result)
        }
        
        
        //locationManagerのセットアップ
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        // 0.01が距離の倍率
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        // 表示する中心の緯度、経度を指定
        let coordinate = mapView.userLocation.coordinate
        
        //現在地の情報取得(centerで設定)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.region = region
        mapView.userTrackingMode = .follow
        mapButton.layer.cornerRadius = 10
        mapView.delegate = self
        
        makeMap()
    }
    
    @IBAction func addPin(_ sender: UIButton){
        
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
        
        coordinatesArray.append(["name":"ピン", "lat": mapView.userLocation.coordinate.latitude, "lon": mapView.userLocation.coordinate.longitude])
        
//        print(coordinatesArray)
        
        makeMap()
        
        let location:CGPoint = CGPoint(x: self.mapView.frame.width / 2, y: self.mapView.frame.height / 2)
        let center = mapView.convert(location, toCoordinateFrom: mapView)
//        let lati:String = center.latitude.description
//        let long:String = center.longitude.description
        
        //savePin(latitude: lati, longitude: long)
        self.performSegue(withIdentifier: "next", sender: nil)
        
        
        let coordinates = mapView.userLocation.coordinate
        let locations = CLLocation(latitude:coordinates.latitude, longitude: coordinates.longitude)
        
//        let pins = Pin()
        
        getAddress(locations: locations){
            self.adrLabel.text = self.adr
//            pins.address = self.adr
            
//            try! self.realm.write {
//                self.realm.add(pins, update:.modified)
//            }
//            let results = self.realm.objects(Pin.self)
//            for result in results {
//                print(result)
//            }
        }
    
    }
    

    
    
    //許可を求める
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus, didUpdateLocations locations: [CLLocation]) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        default:
            break
        }
        // 最後に収集したlocationを取得
        if let location = locations.last {
            // 経度と緯度を取得
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
           
        }
    }
    
    
    //経由地点つなげるやつ
    func makeMap() {
        //マップの表示域を設定
        let coordinate = CLLocationCoordinate2DMake(coordinatesArray[0]["lat"] as! CLLocationDegrees, coordinatesArray[0]["lon"] as! CLLocationDegrees)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        var routeCoordinates: [CLLocationCoordinate2D] = []
        
        for i in 0..<coordinatesArray.count {
            let annotation = MKPointAnnotation()
            //経路
            let annotationCoordinate = CLLocationCoordinate2DMake(coordinatesArray[i]["lat"] as! CLLocationDegrees, coordinatesArray[i]["lon"] as! CLLocationDegrees)
            //ピンの吹き出しに名前が出るように
            annotation.title = coordinatesArray[i]["name"] as? String
            
            annotation.coordinate = annotationCoordinate
            routeCoordinates.append(annotationCoordinate)
            self.mapView.addAnnotation(annotation)
        }
        
        var myRoute: MKRoute!
        let directionsRequest = MKDirections.Request()
        //routeCoordinatesの配列からMKMapItemの配列にに変換
        var placemarks = [MKMapItem]()
        for item in routeCoordinates{
            let placemark = MKPlacemark(coordinate: item, addressDictionary: nil)
            placemarks.append(MKMapItem(placemark: placemark))
            
        }
        //移動手段徒歩
        directionsRequest.transportType = .walking
        for (k, item) in placemarks.enumerated(){
            if k < (placemarks.count - 1){
                //スタート地点
                directionsRequest.source = item
                //目標地点
                directionsRequest.destination = placemarks[k + 1]
                let direction = MKDirections(request: directionsRequest)
                direction.calculate(completionHandler: {(response, error) in
                    
                    if error == nil {
                        myRoute = response?.routes[0]
                        //mapViewに絵画
                        self.mapView.addOverlay(myRoute.polyline, level: .aboveRoads)
                    }
                })
            }
        }
    }
    
    
    //つなげるやつの詳細設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer = MKPolylineRenderer(polyline: route)
        routeRenderer.strokeColor = UIColor(hex: "ff1493",alpha: 1.0)
        routeRenderer.lineWidth = 5.0
        return routeRenderer
    }
    
    func getAddress(locations: CLLocation, completion: @escaping () -> ()){
    
        CLGeocoder().reverseGeocodeLocation(locations) {(placemarks,error) in
            if let placemark = placemarks?.first, error == nil {
                let administrativeArea = placemark.administrativeArea! //都道府県
                let locality = placemark.locality! //市区町村
                let thoroughfare = placemark.thoroughfare! //丁目
                let subThoroughfare = placemark.subThoroughfare! //番地
                self.adr = subThoroughfare + "," + thoroughfare + "," + locality + "," + administrativeArea
                print(self.adr)
            }
            completion()
        }
    }
        
        //ピンをRealmに保存
        func savePin(latitude: String, longitude: String){
            let pin = Pin()
            pin.latitude = latitude
            pin.longitude = longitude
            
            CLGeocoder().reverseGeocodeLocation(locationManager.location!) { placemarks, error in
                guard
                    let placemark = placemarks?.first, error == nil,
                    let administrativeArea = placemark.administrativeArea, //都道府県
                    let locality = placemark.locality, //市区町村
                    let thoroughfare = placemark.thoroughfare, //丁目
                    let subThoroughfare = placemark.subThoroughfare //番地
                        
                else {
                    //self.adrLabel.text = "---"
                    return
                }
                pin.address = "\(administrativeArea)\(locality)\(thoroughfare)\(subThoroughfare)"
                //                    self.adrLabel.text = """
                //                        \(administrativeArea)\(locality)\(thoroughfare)\(subThoroughfare)
                //                    """
            }
            
            
            try! realm.write {
                realm.add(pin)
            }
        }
        
        
        //Realmからピンの位置情報を取得
        func getAllPins() -> [Pin] {
            let realm = try! Realm()
            var results: [Pin] = []
            //Pinテーブルに存在する全てのデータを取得
            for pin in realm.objects(Pin.self) {
                results.append(pin)
            }
            return results
        }
        
        //座標をAnnotationに変換する
        func getAnnotations() -> [MKPointAnnotation]  {
            let pins = getAllPins()
            var results:[MKPointAnnotation] = []
            
            pins.forEach { pin in
                let annotation = MKPointAnnotation()
                let centerCoordinate = CLLocationCoordinate2D(latitude: (pin.latitude as NSString).doubleValue, longitude:(pin.longitude as NSString).doubleValue)
                annotation.coordinate = centerCoordinate
                results.append(annotation)
            }
            return results
        }
        
        // マップのロードが終わった時に呼ばれる
        // Map上にAnnotationを追加
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            //Pinを取得してMap上に表示する
            let annotations = getAnnotations()
            annotations.forEach { annotation in
                mapView.addAnnotation(annotation)
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let next = segue.destination as! EditViewController
            if let sheet = next.sheetPresentationController{
                sheet.detents = [.medium(), .large()]
            }
            next.adr = adrLabel.text!
        }
    
        //ピンがタップされた時の処理
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation{
                self.performSegue(withIdentifier: "next", sender: nil)
            }
        }
        
    }

