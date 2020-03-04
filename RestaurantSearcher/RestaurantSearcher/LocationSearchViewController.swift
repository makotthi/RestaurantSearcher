

import UIKit
import CoreLocation

// MARK: -vars and initialize
class LocationSearchViewController: UIViewController {
    
    // 位置情報を受け取るクラスのインスタンス
    private let currentLocationReader = CurrentLocationReader()
    // 検索範囲を入力するPickerViewのインスタンス
    private var rangePickerView: UIPickerView!
    private let pickerItems = ["300m", "500m", "1000m", "2000m", "3000m"]
    
    // 店の一覧を表示するTableView
    @IBOutlet private weak var storeTableView: UITableView!
    // 検索範囲を入力、表示するTextField
    @IBOutlet private weak var rangeTextField: UITextField!

    // 再検索ボタン
    @IBOutlet private weak var searchButton: UIButton!
    
    // pagingView
    @IBOutlet private weak var pagingViewContainer: UIView!
    
    
    // pagingViewクラスのインスタンスを生成
    private let pagingView = PagingView.fromXib()
    
    
    // 緯度と経度
    private var latitude: Double?
    private var longitude: Double?
    // 検索範囲
    private var searchRange = "500m"
    
    // 受け取ったレストランのデータを格納する配列
    private var restaurantList: [StoreData] = []
    // 選択したレストランのID
    private var selectID: String?
    // 現在表示しているページの番号と全ページの数
    private var currentPage = 1
    private var totalPage = 1
    
    // APIクライアント
    private var apiClient = APIClient()
    
    
    // 初回の画面遷移した時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期設定
        initialSetting()
        
        // 現在地周辺のレストランを検索
        searchRestaurantAround()
    }
    
}


// MARK: -InitialSettings
extension LocationSearchViewController{
    private func initialSetting(){
        // PickerViewの初期化
        rangePickerView = UIPickerView()
        rangePickerView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.selectRow(1, inComponent: 0, animated: true)
        
        // TableViewDataSourceを設定
        storeTableView.dataSource = self
        
        // RestaurantTableViewCellの登録
        storeTableView.register(UINib(nibName: "RestaurantTableViewCell", bundle: nil), forCellReuseIdentifier: "storeCell")
        
        // TableViewnDelegateを設定
        storeTableView.delegate = self
        
        // textFieldのinputViewにpickeViewを設定
        rangeTextField.inputView = rangePickerView
        // ツールバーの生成
        makeToolBar()
        
        // 検索範囲の初期値を500mに設定
        rangeTextField.text = pickerItems[1]
        
        // ページ移動のボタンなどを無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        searchButton.isEnabled = false

        
        // 画面に表示する
        pagingViewContainer.addSubview(pagingView)
        
        // AutoLayoutの誓約をつける
        // 上下左右の誓約を追加
        NSLayoutConstraint.activate([
            pagingView.leadingAnchor.constraint(equalTo: pagingViewContainer.leadingAnchor), //言語の初めの方角
            pagingView.trailingAnchor.constraint(equalTo: pagingViewContainer.trailingAnchor), //言語の終わり
            pagingView.topAnchor.constraint(equalTo: pagingViewContainer.topAnchor), //上
            pagingView.bottomAnchor.constraint(equalTo: pagingViewContainer.bottomAnchor) //下
        ])
        // AutoresizingMaskを無効にする
        pagingView.translatesAutoresizingMaskIntoConstraints = false
        
        // クロージャの設定
        pagingView.onTapBackPageButton = { [weak self] in
            self?.backPageButtonAction()
        }
        pagingView.onTapNextPageButton = { [weak self] in
            self?.nextPageButtonAction()
        }
        
        
        // TableViewをスクロールすると、キーボードを閉じるように設定
        storeTableView.keyboardDismissMode = .onDrag
    }
}


// MARK: -UIPickerViewDataSource
extension LocationSearchViewController: UIPickerViewDataSource{
    // PickerViewの列数を設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // PickerViewの行数を設定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
}


// MARK: -UIPickerViewDelegate
extension LocationSearchViewController: UIPickerViewDelegate{
    // PickerViewの要素を設定
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItems[row]
    }
    
    // PickerViewで選択したものをtextFieldに表示
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rangeTextField.text = pickerItems[row]
    }
}


// MARK: -UIToolbar
extension LocationSearchViewController{
    // toolBarを生成
    private func makeToolBar(){
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        rangeTextField.inputAccessoryView = toolbar
    }
    
    // toolBar関連のメソッド
    // Doneボタンを押した時の処理
    @objc private func done() {
        rangeTextField.endEditing(true)
    }
}


// MARK: -UITableViewDataSource
extension LocationSearchViewController: UITableViewDataSource{
    // tableViewCellの総数を返すdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 店舗リストの総数
        return restaurantList.count
    }
    
    // tableViewCellに値をセットするdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するCellオブジェクトを取得
        // cellをRestaurantTableViewCell型にキャストする
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! RestaurantTableViewCell
        
        // 表示する店のデータ
        let storeData = restaurantList[indexPath.row]
        
        // cellに店のデータを表示させる
        cell.setStoreData(storeData)
        
        
        // 設定したCellオブジェクトを画面に反映
        return cell
    }
}


// MARK: -UITableViewDelegate
extension LocationSearchViewController: UITableViewDelegate{
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
}


// MARK: -FindRestaurantAround
extension LocationSearchViewController{
    // 現在地周辺のレストランを検索する
    private func searchRestaurantAround(){
        // 位置情報を取得する
        currentLocationReader.readCurrentLocation {[unowned self] result in
            switch result{
            // 位置情報の取得に成功した時
            case .success(let latitude, let longitude):
                // 緯度と経度を受け取る
                self.latitude = latitude
                self.longitude = longitude
                // 店舗を検索する
                self.searchRestaurant(rangeWord: self.searchRange)
            
            // 位置情報の取得に失敗した時
            case .failure(let error):
                print(error)
                self.pagingView.setPageLabelText(text: "位置情報の取得に失敗しました")
                self.searchButton.isEnabled = true
            }
        }
    }
}



// MARK: -API
extension LocationSearchViewController{
    // API通信を行うメソッド
    // レストランを検索して、TableViewに表示
    private func searchRestaurant(rangeWord: String){
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
                    } else {
                        self.pagingView.setPageLabelText(text: "検索結果なし")
                    }
                    
                    // TableViewを更新
                    self.storeTableView.reloadData()
                    // pageLabelを更新
                    if let total = json.total_hit_count {
                        self.totalPage = Int(ceil(Double(total) / 100.0))
                        self.pagingView.setPageLabelText(text: "\(self.currentPage) /\(self.totalPage) ページ")
                        if self.currentPage != 1 {
                            self.pagingView.setBackPageButtonEnabled(isEnabled: true)
                        }
                        if self.currentPage != self.totalPage {
                            self.pagingView.setNextPageButtonEnabled(isEnabled: true)
                        }
                    }
                    // textFieldのテキストを更新
                    self.rangeTextField.text = self.searchRange
                    // 再検索ボタンを有効にする
                    self.searchButton.isEnabled = true
                    
                } catch {
                    print("エラーが発生しました",error.localizedDescription)
                    self.pagingView.setPageLabelText(text: "通信に失敗しました")
                    self.searchButton.isEnabled = true
                }
            })
            // ダウンロード開始
            task.resume()

        }
    }
}


// MARK: -Action
extension LocationSearchViewController{
    // 再検索ボタンが押された時の処理
    @IBAction private func searchButtonAction(_ sender: Any) {
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンの無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        searchButton.isEnabled = false
        // 現在の状態を表示
        pagingView.setPageLabelText(text: "通信中")
        
        // pickerViewを閉じる
        done()
        
        // 検索する範囲をsearchRangeに代入
        if let range = rangeTextField.text {
            searchRange = range
        }
        // 現在のページ位置を1に
        currentPage = 1
        // 現在地周辺のレストランを検索
        searchRestaurantAround()
    }
    
    // 前のページボタンが押された時の処理
    private func backPageButtonAction() {
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンの無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        searchButton.isEnabled = false
        // 現在の状態を表示
        pagingView.setPageLabelText(text: "通信中")
        rangeTextField.text = searchRange
        
        // 前のページの検索結果を表示
        currentPage -= 1
        searchRestaurant(rangeWord: searchRange)
    }
    
    // 次のページボタンが押された時の処理
    private func nextPageButtonAction() {
        // tableViewのデータを一旦消す
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンの無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        searchButton.isEnabled = false
        // 現在の状態を表示
        pagingView.setPageLabelText(text: "通信中")
        rangeTextField.text = searchRange
        
        // 次のページの検索結果を表示
        currentPage += 1
        searchRestaurant(rangeWord: searchRange)
    }
}
