

import UIKit
import CoreLocation

class LocationSearchViewController: UIViewController, CLLocationManagerDelegate {
    
    // 位置情報を受け取るクラスのインスタンス
    var myLocationManager:CLLocationManager!
    
    @IBOutlet weak var testLabel: UILabel!
    
    // 緯度と経度
    var latitude: Double?
    var longitude: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 位置情報を受け取る処理の初期設定
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        
         // 承認されていない場合はここで認証ダイアログを表示します.
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined) {
            print("didChangeAuthorizationStatus:\(status)")
            self.myLocationManager.requestWhenInUseAuthorization()
        }
        
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = 100
        
        // 現在地を取得
        myLocationManager.requestLocation()
    }
    
    // 位置情報取得成功時に呼ばれます
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
    
    // 位置情報取得失敗時に呼ばれます
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
 
    @IBAction func testButtonClicked(_ sender: Any) {
        testLabel.text = "緯度:\(latitude!), 経度:\(longitude!)"
        
    }
    
}
