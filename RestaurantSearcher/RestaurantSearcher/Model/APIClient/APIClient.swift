import UIKit

class APIClient{
    // レストランのデータをぐるなびAPIから受け取る
    func receiveRestaurants(_ url: URL, _ handler: @escaping (Result<StoreDataArray, Error>) -> Void){
        // リクエストに必要な情報を生成
        let req = URLRequest(url: url)
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
                
                
            } catch {
                print("エラーが出ました")
            }
        })
        // ダウンロード開始
        task.resume()
    }
}
