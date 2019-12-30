

import UIKit
import SafariServices

class DetailsViewController: UIViewController, SFSafariViewControllerDelegate {
    
    // 店の画像を表示するimageView
    @IBOutlet weak var storeImageView1: UIImageView!
    @IBOutlet weak var storeImageView2: UIImageView!
    // 店舗名称、住所、電話番号、営業時間を表示するlabel
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var opentimeLabel: UILabel!
    
    
    
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
        let url: String?
        let image_url: StoreImageData?
    }
    // 店舗画像のデータを格納する
    struct StoreImageData: Codable{
        let shop_image1: String?
        let shop_image2: String?
    }
    
    
    // 画面遷移をした時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // レストランのデータを受け取る
        receiveRestaurantData()
    }
    
    
    
    // API通信を行うメソッド
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
                        // 画面上に店舗のデータを表示する
                        self.showStoreData()
                    }
                    
                } catch {
                    print("エラーが出ました")
                }
            })
            // ダウンロード開始
            task.resume()
        }
        
    }
    

    
    // 取得したデータを画面に表示する
    func showStoreData(){
        // 店舗画像を表示
        if let urlStr = storeData?.image_url?.shop_image1 {
            if let imageURL = URL(string: urlStr){
                if let imageData = try? Data(contentsOf: imageURL) {
                    storeImageView1.image = UIImage(data: imageData)
                }
            }
        }
        if let urlStr = storeData?.image_url?.shop_image2 {
            if let imageURL = URL(string: urlStr){
                if let imageData = try? Data(contentsOf: imageURL) {
                    storeImageView2.image = UIImage(data: imageData)
                }
            }
        }
        
        // 店舗名称を表示
        nameLabel.text = storeData?.name
        nameLabel.sizeToFit()
        
        // 住所を表示
        addressLabel.text = storeData?.address
        addressLabel.sizeToFit()
        
        // 電話番号を表示
        if let phoneNumber = storeData?.tel {
            phoneNumberLabel.text = "TEL: " + phoneNumber
        }
        phoneNumberLabel.sizeToFit()
        
        // 営業時間
        if let openTime = storeData?.opentime {
            opentimeLabel.text = "営業時間:\n" + openTime
        }
        opentimeLabel.sizeToFit()
    }
    
    
    
    // もっと詳しくボタンが押された時の処理
    // レストランのWebページを表示する
    @IBAction func showWebPageButtonAction(_ sender: Any) {
        // SFSafariViewを開く
        guard let urlStr = storeData?.url else {
            return
        }
        guard let url = URL(string: urlStr) else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        
        // delegateの通知先を設定
        safariViewController.delegate = self
        
        // safariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    // safariViewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // safariViewを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
}
