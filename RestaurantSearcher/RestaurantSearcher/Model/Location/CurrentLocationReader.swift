import CoreLocation

class CurrentLocationReader: NSObject {

    // CLLocationManagerのインスタンスを生成
    private let locationManager = CLLocationManager()

    private var onCompleteReadCurrentLocation: ((Result<(Double, Double), Error>) -> Void)?

    // イニシャライザ
    override init() {
        super.init()

        // LocationManagerDelegateを設定
        locationManager.delegate = self

        // locationManagerの精度などの初期設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }

    // 位置情報を読み取って、緯度経度を返す
    func readCurrentLocation(_ handler: @escaping (Result<(Double, Double), Error>) -> Void) {
        // 承認されていない場合はここで認証ダイアログを表示します.
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            print("didChangeAuthorizationStatus:\(status)")
            self.locationManager.requestWhenInUseAuthorization()
        }

        // onCompleteReadCurrentLocationに、受け取ったhandlerを設定
        onCompleteReadCurrentLocation = handler

        // 位置情報を取得する
        locationManager.requestLocation()
    }
}

extension CurrentLocationReader: CLLocationManagerDelegate {
    // Delegateメソッド

    // 位置情報取得に成功した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        // 緯度と経度を受け取る
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        // 位置情報が取得できたことを伝える
        // デリゲートからクロージャへ変換
        onCompleteReadCurrentLocation?(.success((latitude, longitude)))
    }

    // 位置情報取得に失敗した時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 位置情報が取得できなかったことを伝える
        onCompleteReadCurrentLocation?(.failure(error))
    }
}
