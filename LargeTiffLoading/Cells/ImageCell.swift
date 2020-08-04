//
//  ImageCell.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 17.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet weak var largeImageView: UIImageView!
    var imageVm: ImageViewModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        self.largeImageView.image = nil
        self.imageVm = nil
    }
    
    /// Cell setup method
    /// - Parameter viewModel: model for cell
    func setup(viewModel:ImageViewModel) {
        self.imageVm = viewModel
        if let image = self.imageVm?.image {
            DispatchQueue.main.async  {
                UIView.transition(with: self.largeImageView,
                                duration: 1.0,
                                options: [.curveEaseOut, .transitionCrossDissolve],
                                animations: {
                                    self.largeImageView.image = image
                                })
            }
        }
    }
}
