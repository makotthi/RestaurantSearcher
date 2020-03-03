
import UIKit

class PagingView: UIView {

    @IBOutlet private weak var backPageButton: UIButton!
    @IBOutlet private weak var nextPageButton: UIButton!
    @IBOutlet private weak var pageLabel: UILabel!
    

    // MARK: -Static Method
    static func fromXib() -> PagingView {
        // PagingViewのxibファイルをオブジェクト化
        let nib = UINib(nibName: "PagingView", bundle: nil)
        // nibをインスタンス化
        let pagingView = nib.instantiate(withOwner: nil, options: nil).first as! PagingView
        
        return pagingView
    }
    
    
    // MARK: -Closure
    // クロージャを定義
    var onTapBackPageButton: (() -> Void)?
    var onTapNextPageButton: (() -> Void)?
    
    
    // MARK: -Action
    @IBAction private func backPageButtonTapped(_ sender: Any) {
        onTapBackPageButton?()
    }
    
    @IBAction private func nextPageButtonTapped(_ sender: Any) {
        onTapNextPageButton?()
    }
    
    
    
    // MARK: -Setter
    
    // Buttonの有効状態のセッター
    // backPageButton
    func setBackPageButtonEnabled(isEnabled: Bool){
        backPageButton.isEnabled = isEnabled
    }
    // nextPageButton
    func setNextPageButtonEnabled(isEnabled: Bool){
        nextPageButton.isEnabled = isEnabled
    }
    
    // pageLabelのテキストをセット
    func setPageLabelText(text: String){
        pageLabel.text = text
    }
    
    
}
