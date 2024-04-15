import UIKit

extension UITableView {
    
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsSizeUpdate = header.frame.height != size.height
        if needsSizeUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
