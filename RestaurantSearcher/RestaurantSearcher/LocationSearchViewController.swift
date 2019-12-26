

import UIKit
import CoreLocation

class LocationSearchViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource {
    
    // 位置情報を受け取るクラスのインスタンス
    var myLocationManager:CLLocationManager!
    // 検索範囲を入力するPickerViewのインスタンス
    var rangePickerView: UIPickerView!
    let pickerItems = ["300m", "500m", "1000m", "2000m", "3000m"]
    
    // 店の一覧を表示するTableView
    @IBOutlet weak var storeTableView: UITableView!
    // 検索範囲を入力、表示するTextField
    @IBOutlet weak var rangeTextField: UITextField!
    
    
    // 店舗データを格納する配列
    struct StoreDataArray: Codable{
        let rest: [StoreData]?
    }
    // 店舗のデータを格納する
    struct StoreData: Codable{
        let name: String?
        let image_url: StoreImageData?
        let access: StoreAccessData?
    }
    // 店舗画像のデータを格納する
    struct StoreImageData: Codable{
        let shop_image1: String?
    }
    // 店舗アクセスのデータを格納する
    struct StoreAccessData: Codable{
        let line: String?
        let station: String?
        let station_exit: String?
        let walk: String?
    }
    
    
    // 緯度と経度
    var latitude: Double?
    var longitude: Double?
    
    // 受け取ったレストランのデータを格納する
    var restaurantList: [StoreData] = []
    
    
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
        
        // PickerViewの初期化
        rangePickerView = UIPickerView()
        rangePickerView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.selectRow(1, inComponent: 0, animated: true)
        
        // TableViewDataSourceを設定
        storeTableView.dataSource = self
        
        // textFieldのinputViewにpickeViewを設定
        rangeTextField.inputView = rangePickerView
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        rangeTextField.inputAccessoryView = toolbar
        
        // 検索範囲の初期値を500mに設定
        rangeTextField.text = pickerItems[1]
    }
    
    // 位置情報取得成功時に呼ばれます
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            searchRestaurant(range: 1)
        }
    }
    
    // 位置情報取得失敗時に呼ばれます
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
   
    
    // PickerViewの列数を設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // PickerViewの行数を設定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
    
    // PickerViewの要素を設定
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItems[row]
    }
    
    // PickerViewで選択したものをtextFieldに表示
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rangeTextField.text = pickerItems[row]
    }
    
    // Doneボタンを押した時の処理
    @objc func done() {
        rangeTextField.endEditing(true)
    }
 
    
    // tableViewCellの総数を返すdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 店舗リストの総数
        return restaurantList.count
    }
    
    // tableViewCellに値をセットするdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するCellオブジェクトを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath)
        // 店舗名称を設定
        cell.textLabel?.text = restaurantList[indexPath.row].name
        // サムネイル画像を取得
        if let thumbnail:String = restaurantList[indexPath.row].image_url?.shop_image1 {
            if let thumbnailURL = URL(string: thumbnail) {
                if let imageData = try? Data(contentsOf: thumbnailURL) {
                    // 取得できたら、サムネイル画像をCellに設定
                    cell.imageView?.image = UIImage(data: imageData)
                }
            }
        }
        // アクセスを設定
        var accessText = ""
        if let line = restaurantList[indexPath.row].access?.line {
            accessText = accessText + "\(line) "
        }
        if let station = restaurantList[indexPath.row].access?.station {
            accessText = accessText + "\(station) "
        }
        if let exit = restaurantList[indexPath.row].access?.station_exit {
            accessText = accessText + "\(exit) "
        }
        if let walk = restaurantList[indexPath.row].access?.walk {
            accessText = accessText + "\(walk)分"
        }
        cell.detailTextLabel?.text = accessText
        
        // 設定したCellオブジェクトを画面に反映
        return cell
    }
    
       
    // レストランを検索して、TableViewに表示
    func searchRestaurant(range: Int){
        if let latitude = latitude, let longitude = longitude {
            // リクエストURLの組み立て
            guard let requestURL = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=6cf2ac2af697b3358620582d34884f09&latitude=\(latitude)&longitude=\(longitude)&range=2") else {
                return
            }
            print(requestURL)
            
            // リクエストに必要な情報を生成
            let req = URLRequest(url: requestURL)
            // データ転送を管理するためのセッションを生成
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            // リクエストをタスクとして登録
            let task = session.dataTask(with: req, completionHandler: {
                (data, response, error) in
                // セッションを終了
                session.finishTasksAndInvalidate()
                // do try catch エラーハンドリング
                do {
                    // JSONDecoderのインスタンス取得
                    let decoder = JSONDecoder()
                    // 受け取ったJSONデータをパースして格納
                    let json = try decoder.decode(StoreDataArray.self, from: data!)
                    
                    // レストランデータのリストを初期化
                    self.restaurantList.removeAll()
                    if let items = json.rest {
                        for item in items{
                            self.restaurantList.append(item)
                        }
                    }
                    
                    // TableViewを更新
                    self.storeTableView.reloadData()
                } catch {
                    print("エラーが発生しました",error.localizedDescription)
                }
            })
            // ダウンロード開始
            task.resume()

        }
    }
       
    
}
