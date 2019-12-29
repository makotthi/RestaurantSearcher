

import UIKit

class DetailsViewController: UIViewController {
    
    // 選択したレストランのID
    var selectID: String?
    
    // 店の詳細データ
    var storeData: StoreData?
    
    // 店舗データを格納する配列
    struct StoreDataArray: Codable{
        let rest: [StoreData]?
    }
    // 店舗のデータを格納する
    struct StoreData: Codable{
        let id: String?
        let name: String?
        let address: String?
        let tel: String?
        let opentime: String?
        let image_url: StoreImageData?
        let access: StoreAccessData?
    }
    // 店舗画像のデータを格納する
    struct StoreImageData: Codable{
        let shop_image1: String?
        let shop_image2: String?
        let qrcode: String?
    }
    // 店舗アクセスのデータを格納する
    struct StoreAccessData: Codable{
        let line: String?
        let station: String?
        let station_exit: String?
        let walk: String?
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        receiveRestaurantData()
    }
    
    
    // レストランのデータを受け取る
    func receiveRestaurantData(){
        if let id = selectID {
            // リクエストURLの組み立て
            guard let requestURL = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=6cf2ac2af697b3358620582d34884f09&id=\(id)") else {
                return
            }
            
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
                    // JSONDecoderのインスタンスを生成
                    let decoder = JSONDecoder()
                    // 受け取ったjsonデータをパースして格納
                    let json = try decoder.decode(StoreDataArray.self, from: data!)
                    
                    if let items = json.rest {
                        // 取得したデータをdetailedDataに格納
                        self.storeData = items.first
                    }
                    
                } catch {
                    print("エラーが出ました")
                }
            })
            // ダウンロード開始
            task.resume()
        }
        
    }
    

}
