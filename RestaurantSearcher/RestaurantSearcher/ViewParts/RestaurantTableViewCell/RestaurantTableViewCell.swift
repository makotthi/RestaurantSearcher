import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet private weak var thmbnailView: UIImageView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var rootLabel: UILabel!

    func setStoreData(_ storeData: StoreData) {
        // 店舗名称を設定
        storeNameLabel?.text = storeData.name

        // サムネイル画像を取得
        thmbnailView?.image = nil
        // 画像を非同期で読み込む
        thmbnailView?.loadImage(url: storeData.image_url?.shop_image1)

        // 店舗アクセスを設定
        rootLabel?.text = storeData.routeText()
    }

}
