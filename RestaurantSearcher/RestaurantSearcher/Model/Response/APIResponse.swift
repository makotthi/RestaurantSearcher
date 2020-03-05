import  Foundation

// APIレスポンスを格納する構造体を定義

// 店舗データを格納する配列
struct StoreDataArray: Codable {
    let total_hit_count: Int?
    let rest: [StoreData]?

    // レスポンスのページ数を返す
    var totalPage: Int {
        guard let total = total_hit_count else {
            return 0
        }
        return Int(ceil(Double(total) / 100.0))
    }

    // total_hit_countが値を持っているかどうかを判断
    var hasResult: Bool {
        totalPage > 0
    }

    // ページの文字列を作る
    func pageString(currentPage: Int) -> String {
        if hasResult {
            return "\(currentPage) /\(totalPage) ページ"
        } else {
            return "検索結果なし"
        }
    }

    // 次のページがあるかどうかを返す
    func hasNextPage(of page: Int) -> Bool {
        page < totalPage
    }

    // 前のページがあるかどうかを返す
    func hasPreviousPage(of page: Int) -> Bool {
        page > 1
    }
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
