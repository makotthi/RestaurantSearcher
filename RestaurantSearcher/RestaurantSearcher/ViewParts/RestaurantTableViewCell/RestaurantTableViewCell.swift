

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet private weak var thmbnailView: UIImageView!
    @IBOutlet private weak var storeNameLabel: UILabel!
    @IBOutlet private weak var rootLabel: UILabel!
    
    func setStoreData(_ storeData: KeywordSearchViewController.StoreData){
        // 店舗名称を設定
        storeNameLabel?.text = storeData.name
        
        // サムネイル画像を取得
        thmbnailView?.image = nil
        // 画像を非同期で読み込む
        thmbnailView?.loadImage(url: storeData.image_url?.shop_image1)
        
        // 店舗アクセスを設定
        var accessText = ""
        if let line = storeData.access?.line {
            accessText = accessText + "\(line) "
        }
        if let station = storeData.access?.station {
            accessText = accessText + "\(station) "
        }
        if let exit = storeData.access?.station_exit {
            accessText = accessText + "\(exit) "
        }
        if let walk = storeData.access?.walk {
            if walk != "" {
                accessText = accessText + "\(walk)分"
            }
        }
        rootLabel?.text = accessText
    }
    
    
    func setStoreData(_ storeData: LocationSearchViewController.StoreData){
        // 店舗名称を設定
        storeNameLabel?.text = storeData.name
        
        // サムネイル画像を取得
        thmbnailView?.image = nil
        // 画像を非同期で読み込む
        thmbnailView?.loadImage(url: storeData.image_url?.shop_image1)
        
        // 店舗アクセスを設定
        var accessText = ""
        if let line = storeData.access?.line {
            accessText = accessText + "\(line) "
        }
        if let station = storeData.access?.station {
            accessText = accessText + "\(station) "
        }
        if let exit = storeData.access?.station_exit {
            accessText = accessText + "\(exit) "
        }
        if let walk = storeData.access?.walk {
            if walk != "" {
                accessText = accessText + "\(walk)分"
            }
        }
        rootLabel?.text = accessText
    }
    
}
