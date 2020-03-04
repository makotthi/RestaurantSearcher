

import CoreLocation

class CurrentLocationReader: NSObject{
    
    // CLLocationManagerのインスタンスを生成
    private let locationManager = CLLocationManager()
    
    // 位置情報を読み取って、緯度経度を返す
    func readCurrentLocation(_ handler: @escaping (Result<(Double, Double), Error>) -> Void) {
        // 位置情報を取得する
        locationManager.requestLocation()
    }
}

extension CurrentLocationReader: CLLocationManagerDelegate{
    // Delegateメソッド
    
    // 位置情報取得に成功した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    // 位置情報取得に失敗した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
