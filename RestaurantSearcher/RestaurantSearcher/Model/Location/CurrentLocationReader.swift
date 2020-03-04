

import CoreLocation

class CurrentLocationReader: NSObject{
    // 位置情報を読み取って、緯度経度を返す
    func readCurrentLocation(_ handler: @escaping (Result<(Double, Double), Error>) -> Void) {
        
    }
}

extension CurrentLocationReader: CLLocationManagerDelegate{
    // デリゲードメソッド
    
    // 位置情報取得に成功した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    // 位置情報取得に失敗した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}
