

import UIKit

class KeywordSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // 店の一覧を表示するTableView
    @IBOutlet weak var storeTableView: UITableView!
    // 検索キーワードを入力するsearchBar
    @IBOutlet weak var keywordSearchBar: UISearchBar!
    // 現在のページ数を表示するLabel
    @IBOutlet weak var pageLabel: UILabel!
    // 前のページボタン
    @IBOutlet weak var backPageButton: UIButton!
    // 次のページボタン
    @IBOutlet weak var nextPageButton: UIButton!
   
       
       
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


    // 受け取ったレストランのデータを格納する
    var restaurantList: [StoreData] = []
    // 選択したレストランのID
    var selectID: String?
    // 現在表示しているページの番号と全ページの数
    var currentPage = 1
    var totalPage = 1
    // 現在検索しているキーワード
    var searchingKeyword: String?


    // 初回の画面遷移した時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableViewDataSourceを設定
        storeTableView.dataSource = self
        // TableViewnDelegateを設定
        storeTableView.delegate = self

        // searchBarのdelegateを設定
        keywordSearchBar.delegate = self
        // プレースホルダーを設定
        keywordSearchBar.placeholder = "キーワードを入力してください"

        // ツールバーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        keywordSearchBar.inputAccessoryView = toolbar

        // ページ移動のボタンなどを無効化
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        //searchButton.isEnabled = false

    }
    
    // Doneボタンを押した時の処理
    @objc func done() {
        keywordSearchBar.endEditing(true)
    }

    // 位置情報取得成功時に呼ばれます
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            // 緯度と経度を受け取る
//            latitude = location.coordinate.latitude
//            longitude = location.coordinate.longitude
//            // 受け取った位置情報を使って店舗を検索する
//            if let text = rangeTextField.text {
//                searchRestaurant(rangeWord: text)
//            }
//        }
//    }

    // 位置情報取得失敗時に呼ばれます
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("error")
//        pageLabel.text = "位置情報の取得に失敗しました"
//        searchButton.isEnabled = true
//    }

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
        performSegue(withIdentifier: "detailsFromKeyword", sender: self.selectID)
    }

    // 遷移先に値を渡す処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsFromKeyword" {
            let next = segue.destination as! DetailsViewController
            next.selectID = self.selectID
        }
    }

      
    // レストランを検索して、TableViewに表示
    func searchRestaurant(keyword: String){
        searchingKeyword = keyword
        
        // キーワードをURLエンコードする
        guard let keywordEncode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        // リクエストURLの組み立て
        guard let requestURL = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=6cf2ac2af697b3358620582d34884f09&freeword=\(keywordEncode)&hit_per_page=100&offset_page=\(currentPage)") else {
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
                // 再検索ボタンを有効にする
                //self.searchButton.isEnabled = true

            } catch {
                print("エラーが発生しました",error.localizedDescription)
                self.pageLabel.text = "通信に失敗しました"
                //self.searchButton.isEnabled = true
            }
        })
        // ダウンロード開始
        task.resume()

        
    }


//    @IBAction func searchButtonAction(_ sender: Any) {
//        // レストランリストの初期化とボタンの無効化
//        restaurantList.removeAll()
//        storeTableView.reloadData()
//        backPageButton.isEnabled = false
//        nextPageButton.isEnabled = false
//        searchButton.isEnabled = false
//        pageLabel.text = "通信中"
//
//        // 現在のページ位置を1に
//        currentPage = 1
//        // 位置情報を検索して表示
//        myLocationManager.requestLocation()
//    }
    
    // 検索ボタンをクリックした時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        
        // レストランリストの初期化とボタンの無効化
        restaurantList.removeAll()
        storeTableView.reloadData()
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        pageLabel.text = "通信中"

        // 現在のページ位置を1に
        currentPage = 1
        
        if let searchWord = keywordSearchBar.text {
            print(searchWord)
            // 検索をする
            searchRestaurant(keyword: searchWord)
        }
    }


//    @IBAction func backPageButtonAction(_ sender: Any) {
//        // レストランリストの初期化とボタンの無効化
//        restaurantList.removeAll()
//        storeTableView.reloadData()
//        backPageButton.isEnabled = false
//        nextPageButton.isEnabled = false
//        searchButton.isEnabled = false
//        pageLabel.text = "通信中"
//
//        // 次のページの検索結果を表示
//        currentPage -= 1
//        searchRestaurant(rangeWord: searchRange)
//    }

    @IBAction func backPageButtonAction(_ sender: Any) {
        // レストランリストの初期化とボタンの無効化
        restaurantList.removeAll()
        storeTableView.reloadData()
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        pageLabel.text = "通信中"

        // 次のページの検索結果を表示
        currentPage -= 1
        if let searchWord = searchingKeyword {
            searchRestaurant(keyword: searchWord)
        }
    }
    
//    @IBAction func nextPageButtonAction(_ sender: Any) {
//        // レストランリストの初期化とボタンの無効化
//        restaurantList.removeAll()
//        storeTableView.reloadData()
//        backPageButton.isEnabled = false
//        nextPageButton.isEnabled = false
//        searchButton.isEnabled = false
//        pageLabel.text = "通信中"
//
//        // 前のページの検索結果を表示
//        currentPage += 1
//        searchRestaurant(rangeWord: searchRange)
//    }
    
    @IBAction func nextPageButtonAction(_ sender: Any) {
        // レストランリストの初期化とボタンの無効化
        restaurantList.removeAll()
        storeTableView.reloadData()
        backPageButton.isEnabled = false
        nextPageButton.isEnabled = false
        pageLabel.text = "通信中"

        // 前のページの検索結果を表示
        currentPage += 1
        if let searchWord = searchingKeyword {
            searchRestaurant(keyword: searchWord)
        }
    }
    

}
