// APIレスポンスを格納する構造体を定義

// 店舗データを格納する配列
struct StoreDataArray: Codable {
    let total_hit_count: Int?
    let rest: [StoreData]?
}
// 店舗のデータを格納する
struct StoreData: Codable {
    let id: String?
    let name: String?
    let image_url: StoreImageData?
    let access: StoreAccessData?
    let address: String?
    let tel: String?
    let opentime: String?
    let url: String?

    // 店舗アクセスを設定
    func routeText() -> String {
        var accessText = ""
        if let line = access?.line {
            accessText = accessText + "\(line) "
        }
        if let station = access?.station {
            accessText = accessText + "\(station) "
        }
        if let exit = access?.station_exit {
            accessText = accessText + "\(exit) "
        }
        if let walk = access?.walk, !walk.isEmpty {
            accessText = accessText + "\(walk)分"

        }
        return accessText
    }
}
// 店舗画像のデータを格納する
struct StoreImageData: Codable {
    let shop_image1: String?
    let shop_image2: String?
}
// 店舗アクセスのデータを格納する
struct StoreAccessData: Codable {
    let line: String?
    let station: String?
    let station_exit: String?
    let walk: String?
}
