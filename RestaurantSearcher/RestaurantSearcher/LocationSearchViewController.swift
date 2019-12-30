

import UIKit
import CoreLocation

class LocationSearchViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    // 位置情報を受け取るクラスのインスタンス
    var myLocationManager:CLLocationManager!
    // 検索範囲を入力するPickerViewのインスタンス
    var rangePickerView: UIPickerView!
    let pickerItems = ["300m", "500m", "1000m", "2000m", "3000m"]
    
    // 店の一覧を表示するTableView
    @IBOutlet weak var storeTableView: UITableView!
    // 検索範囲を入力、表示するTextField
    @IBOutlet weak var rangeTextField: UITextField!
    // 現在のページ数を表示するLabel
    @IBOutlet weak var pageLabel: UILabel!
    // ページ移動のボタン
    @IBOutlet weak var backPageButton: UIButton!
    @IBOutlet weak var nextPageButton: UIButton!
    // 再検索ボタン
    @IBOutlet weak var searchButton: UIButton!
    
    
    // 店舗データを格納する配列
    struct StoreDataArray: Codable{
        let total_hit_count: Int?
        let rest: [StoreData]?
    }
    // 店舗のデータを格納する
    struct StoreData: Codable{
        let id: String?
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
    // 検索範囲
    var searchRange = "500m"
    
    // 受け取ったレストランのデータを格納する配列
    var restaurantList: [StoreData] = []
    // 選択したレストランのID
    var selectID: String?
    // 現在表示しているページの番号と全ページの数
    var currentPage = 1
    var totalPage = 1
    
    
    
    // 初回の画面遷移した時に呼ばれる
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
        myLocationManager.distanceFilter = kCLDistanceFilterNone
        
        
        // PickerViewの初期化
        rangePickerView = UIPickerView()
        rangePickerView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.selectRow(1, inComponent: 0, animated: true)
        
        // TableViewDataSourceを設定
        storeTableView.dataSource = self
        // TableViewnDelegateを設定
        storeTableView.delegate = self
        
        // textFieldのinputViewにpickeViewを設定
        rangeTextField.inputView = rangePickerView
        // ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        rangeTextField.inputAccessoryView = toolbar
        
        // 検索範囲の初期値を500mに設定
        rangeTextField.text = pickerItems[1]
        
        // ページ移動のボタンなどを無効化
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        searchButton.isEnabled = false
        
        // 現在地を取得
        myLocationManager.requestLocation()
    }
    
    
    
    // locationManager関連のメソッド
    // 位置情報取得成功時に呼ばれます
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // 緯度と経度を受け取る
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            
            // 店舗を検索する
            searchRestaurant(rangeWord: searchRange)
        }
    }
    
    // 位置情報取得失敗時に呼ばれます
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        pageLabel.text = "位置情報の取得に失敗しました"
        searchButton.isEnabled = true
    }
    
   
    
    // pickerView関連のメソッド
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
    
    
    // toolBar関連のメソッド
    // Doneボタンを押した時の処理
    @objc func done() {
        rangeTextField.endEditing(true)
    }
 
    
    
    
    // tableView関連のメソッド
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
        cell.imageView?.image = nil
        if let thumbnail:String = restaurantList[indexPath.row].image_url?.shop_image1 {
            if let thumbnailURL = URL(string: thumbnail) {
                if let imageData = try? Data(contentsOf: thumbnailURL) {
                    // 取得できたら、サムネイル画像をCellに設定
                    cell.imageView?.image = UIImage(data: imageData)
                }
            }
        }
        // 店舗アクセスを設定
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
            if walk != "" {
                accessText = accessText + "\(walk)分"
            }
        }
        cell.detailTextLabel?.text = accessText
        
        // 設定したCellオブジェクトを画面に反映
        return cell
    }
    
    
    // Cellが選択された際に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 初期化
        selectID = nil
        // ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 選択された店のIDを設定
        selectID = restaurantList[indexPath.row].id
        // 画面遷移
        performSegue(withIdentifier: "detailsFromLocation", sender: self.selectID)
    }
    
    // 遷移先に値を渡す処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsFromLocation" {
            let next = segue.destination as! DetailsViewController
            next.selectID = self.selectID
        }
    }
    
       
    
    // API通信を行うメソッド
    // レストランを検索して、TableViewに表示
    func searchRestaurant(rangeWord: String){
        var range = 2
        // rangeTextFieldの値をリクエストパラメータの値に直す
        switch rangeWord {
        case "300m":
            range = 1
        case "500m":
            range = 2
        case "1000m":
            range = 3
        case "2000m":
            range = 4
        case "3000m":
            range = 5
        default:
            break
        }
        searchRange = rangeWord
        
        if let latitude = latitude, let longitude = longitude {
            // リクエストURLの組み立て
            guard let requestURL = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=6cf2ac2af697b3358620582d34884f09&latitude=\(latitude)&longitude=\(longitude)&range=\(range)&hit_per_page=100&offset_page=\(currentPage)") else {
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
                    print("ヒット件数:\(String(describing: json.total_hit_count))")
                    
                    // レストランデータのリストを初期化
                    self.restaurantList.removeAll()
                    if let items = json.rest {
                        for item in items{
                            // 各店舗のデータを配列に追加
                            self.restaurantList.append(item)
                        }
                    }
                    
                    // TableViewを更新
                    self.storeTableView.reloadData()
                    // pageLabelを更新
                    if let total = json.total_hit_count {
                        self.totalPage = Int(ceil(Double(total) / 100.0))
                        self.pageLabel.text = "\(self.currentPage) /\(self.totalPage) ページ"
                        if self.currentPage != 1 {
                            self.backPageButton.isEnabled = true
                        }
                        if self.currentPage != self.totalPage {
                            self.nextPageButton.isEnabled = true
                        }
                    }
                    // textFieldのテキストを更新
                    self.rangeTextField.text = self.searchRange
                    // 再検索ボタンを有効にする
                    self.searchButton.isEnabled = true
                    
                } catch {
                    print("エラーが発生しました",error.localizedDescription)
                    self.pageLabel.text = "通信に失敗しました"
                    self.searchButton.isEnabled = true
                }
            })
            // ダウンロード開始
            task.resume()

        }
    }
    
    
    
    // 再検索ボタンが押された時の処理
    @IBAction func searchButtonAction(_ sender: Any) {
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンの無効化
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        searchButton.isEnabled = false
        // 現在の状態を表示
        pageLabel.text = "通信中"
        
        // 検索する範囲をsearchRangeに代入
        if let range = rangeTextField.text {
            searchRange = range
        }
        // 現在のページ位置を1に
        currentPage = 1
        // 位置情報を検索して表示
        myLocationManager.requestLocation()
    }
    
    // 前のページボタンが押された時の処理
    @IBAction func backPageButtonAction(_ sender: Any) {
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンの無効化
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        searchButton.isEnabled = false
        // 現在の状態を表示
        pageLabel.text = "通信中"
        rangeTextField.text = searchRange
        
        // 前のページの検索結果を表示
        currentPage -= 1
        searchRestaurant(rangeWord: searchRange)
    }
    
    // 次のページボタンが押された時の処理
    @IBAction func nextPageButtonAction(_ sender: Any) {
        // tableViewのデータを一旦消す
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンの無効化
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        searchButton.isEnabled = false
        // 現在の状態を表示
        pageLabel.text = "通信中"
        rangeTextField.text = searchRange
        
        // 次のページの検索結果を表示
        currentPage += 1
        searchRestaurant(rangeWord: searchRange)
    }
    
    
}
