//
//  FileTableViewCell.swift
//  Permanent
//
//  Created by Adrian Creteanu on 13/10/2020.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var fileDateLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var fileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        initUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func initUI() {
        fileNameLabel.font = Text.style11.font
        fileNameLabel.textColor = .middleGrey
        fileDateLabel.font = Text.style12.font
        fileDateLabel.textColor = .middleGrey
        
        // Will be deleted
        fileNameLabel.text = "Profile photos"
        fileDateLabel.text = "02-23-2020"
    }
    
}
