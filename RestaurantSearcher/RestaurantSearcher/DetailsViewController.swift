

import UIKit
import SafariServices

// MARK: -vars and initialize
class DetailsViewController: UIViewController {
    
    // 店の画像を表示するimageView
    @IBOutlet private weak var storeImageView1: UIImageView!
    @IBOutlet private weak var storeImageView2: UIImageView!
    // 店舗名称、住所、電話番号、営業時間を表示するlabel
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var opentimeLabel: UILabel!
    
    
    // 選択したレストランのID
    var selectID: String?
    
    // 店の詳細データ
    private var storeData: StoreData?
    
    // APIクライアント
    private let apiClient = APIClient()
    
    
    // 画面遷移をした時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // レストランのデータを受け取る
        receiveRestaurantData()
    }
    

}


// MARK: -API
extension DetailsViewController{
    // API通信を行うメソッド
    // レストランのデータを受け取る
    private func receiveRestaurantData(){
        if let id = selectID {
            // リクエストURLの組み立て
            guard let requestURL = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=6cf2ac2af697b3358620582d34884f09&id=\(id)") else {
                return
            }
            
            // レストランのデータを受け取る
            apiClient.receiveRestaurants(requestURL, {[unowned self]  result in
                switch result {
                // データを受け取れた時
                case .success(let storeDataArray):
                    if let items = storeDataArray.rest {
                        // 取得したデータをdetailedDataに格納
                        self.storeData = items.first
                        // 画面上に店舗のデータを表示する
                        self.showStoreData()
                    }
                    
                // エラーが発生した時
                case .failure(let error):
                    print(error)
                }
            })
            
        }
        
    }
}


// MARK: -UI
extension DetailsViewController{
    // 取得したデータを画面に表示する
    private func showStoreData(){
        // 店舗画像を表示
        storeImageView1.loadImage(url: storeData?.image_url?.shop_image1)
        storeImageView2.loadImage(url: storeData?.image_url?.shop_image2, noImage: .ver2)
        
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
}


// MARK: -Action
extension DetailsViewController{
    // もっと詳しくボタンが押された時の処理
    // レストランのWebページを表示する
    @IBAction private func showWebPageButtonAction(_ sender: Any) {
        // SFSafariViewを開く
        guard let urlStr = storeData?.url else {
            return
        }
        guard let url = URL(string: urlStr) else {
            return
        }
        openSafariView(url: url)
    }
}


// MARK: -SFSafariViewControllerDelegate
extension DetailsViewController: SFSafariViewControllerDelegate{
    // SFSafariViewを開く
    private func openSafariView(url: URL){
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
