

import UIKit


// MARK: -vars and initialize
class KeywordSearchViewController: UIViewController {
    
    // 店の一覧を表示するTableView
    @IBOutlet private weak var storeTableView: UITableView!
    // 検索キーワードを入力するsearchBar
    @IBOutlet private weak var keywordSearchBar: UISearchBar!

    
    // pagingView
    @IBOutlet private weak var pagingViewContainer: PagingView!
    
    
    // pagingViewクラスのインスタンスを生成
    private let pagingView = PagingView.fromXib()
  
    // 受け取ったレストランのデータを格納する配列
    private var restaurantList: [StoreData] = []
    // 選択したレストランのID
    private var selectID: String?
    // 現在表示しているページの番号と全ページの数
    private var currentPage = 1
    private var totalPage = 1
    // 現在検索しているキーワード
    private var searchingKeyword: String?
    
    // APIクライアント
    private var apiClient = APIClient()


    // 初回の画面遷移した時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期設定
        initialSetting()
    }
    
}


// MARK: -InitialSettings
extension KeywordSearchViewController{
    private func initialSetting(){
        // TableViewDataSourceを設定
        storeTableView.dataSource = self
        
        // RestaurantTableViewCellの登録
        storeTableView.register(UINib(nibName: "RestaurantTableViewCell", bundle: nil), forCellReuseIdentifier: "storeCell")
        
        // TableViewnDelegateを設定
        storeTableView.delegate = self

        // searchBardelegateを設定
        keywordSearchBar.delegate = self
        // プレースホルダーを設定
        keywordSearchBar.placeholder = "キーワードを入力してください"

        
        // ツールバーの生成
        makeToolbar()
        
        
        // ページ移動のボタンを無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        
        
        // pagingViewを画面に表示する
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
        
        
        // 画面遷移時にキーボードを表示
        keywordSearchBar.becomeFirstResponder()
        
        // TableViewをスクロールすると、キーボードを閉じるように設定
        storeTableView.keyboardDismissMode = .onDrag
    }
}


// MARK: -UIToolbar
extension KeywordSearchViewController{
    // toolBar関連のメソッド
    
    // ツールバーの生成
    private func makeToolbar(){
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        keywordSearchBar.inputAccessoryView = toolbar
    }
    
    // Doneボタンを押した時の処理
    @objc private func done() {
        keywordSearchBar.endEditing(true)
    }
}


// MARK: -UITableViewDataSource
extension KeywordSearchViewController: UITableViewDataSource{
    // tableViewCellの総数を返すdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 店舗リストの総数
        return restaurantList.count
    }

    // tableViewCellに値をセットするdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示するCellオブジェクトを取得
        // キャストする
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! RestaurantTableViewCell
        
        // 店のデータ
        let storeData = restaurantList[indexPath.row]
        
        // tableViewCellに読み込んだ店のデータを表示させる
        cell.setStoreData(storeData)
        
        
        // 設定したCellオブジェクトを画面に反映
        return cell
    }
}


// MARK: -UITableViewDelegate
extension KeywordSearchViewController: UITableViewDelegate{
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
}


// MARK: -API
extension KeywordSearchViewController{
    // API通信を行うメソッド
    // レストランを検索して、TableViewに表示
    private func searchRestaurant(keyword: String){
        // 検索キーワードをsearchingKeywordに代入
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
                        // 各店舗のデータを配列に追加
                        self.restaurantList.append(item)
                    }
                } else {
                    // 該当するデータがなかった時に表示
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
                // searchBarのテキストを更新
                self.keywordSearchBar.text = self.searchingKeyword

            } catch {
                print("エラーが発生しました",error.localizedDescription)
                self.pagingView.setPageLabelText(text: "通信に失敗しました")
            }
        })
        // ダウンロード開始
        task.resume()
    }
}


// MARK: -UISearchBarDelegate
extension KeywordSearchViewController: UISearchBarDelegate{
    // 検索ボタンをクリックした時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンを無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        // 現在の状態を表示
        pagingView.setPageLabelText(text: "通信中")

        // 現在のページ位置を1に
        currentPage = 1
        
        if let searchWord = keywordSearchBar.text {
            // 検索をする
            searchRestaurant(keyword: searchWord)
        }
    }
}


// MARK: -Action
extension KeywordSearchViewController{
    // 前のページボタンが押された時の処理
    private func backPageButtonAction() {
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンを無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        // 現在の状態を表示
        pagingView.setPageLabelText(text: "通信中")
        keywordSearchBar.text = searchingKeyword

        // 前のページの検索結果を表示
        currentPage -= 1
        if let searchWord = searchingKeyword {
            searchRestaurant(keyword: searchWord)
        }
    }
    
    // 次のページボタンが押された時の処理
    private func nextPageButtonAction() {
        // tableViewのデータを一旦消去
        restaurantList.removeAll()
        storeTableView.reloadData()
        // ボタンを無効化
        pagingView.setBackPageButtonEnabled(isEnabled: false)
        pagingView.setNextPageButtonEnabled(isEnabled: false)
        // 現在の状態を表示
        pagingView.setPageLabelText(text: "通信中")
        keywordSearchBar.text = searchingKeyword

        // 前のページの検索結果を表示
        currentPage += 1
        if let searchWord = searchingKeyword {
            searchRestaurant(keyword: searchWord)
        }
    }
}
