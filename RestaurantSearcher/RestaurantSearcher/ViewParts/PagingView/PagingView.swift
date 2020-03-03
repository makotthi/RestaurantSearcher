
import UIKit

class PagingView: UIView {

    @IBOutlet private weak var backPageButton: UIButton!
    @IBOutlet private weak var nextPageButton: UIButton!
    @IBOutlet private weak var pageLabel: UILabel!
    
    
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
