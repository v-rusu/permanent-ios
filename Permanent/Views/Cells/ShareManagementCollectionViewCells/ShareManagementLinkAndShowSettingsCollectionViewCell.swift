//
//  ShareManagementLinkAndShowSettingsCollectionViewCell.swift
//  Permanent
//
//  Created by Lucian Cerbu on 11.11.2022.

import UIKit

class ShareManagementLinkAndShowSettingsCollectionViewCell: UICollectionViewCell {
    static let identifier = "ShareManagementLinkAndShowSettingsCollectionViewCell"
    
    @IBOutlet weak var elementNameLabel: UILabel!
    @IBOutlet weak var leftElementButton: UIButton!
    @IBOutlet weak var rightElementButton: UIButton!
    @IBOutlet weak var button: UIButton!
    
    var buttonAction: (() -> Void)?
    
    var linkAddress: String?
    var isMenuExpanded: Bool = false
    var cellType: ShareManagementCellType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        leftElementButton.setTitle("", for: .normal)
        rightElementButton.setTitle("", for: .normal)
    }
    
    func configure(linkLocation: String? = nil, linkWasGeneratedNow: Bool = false, cellType: ShareManagementCellType) {
        self.cellType = cellType
        
        if let linkLocation = linkLocation {
            linkAddress = linkLocation
            leftElementButton.setImage(UIImage(named: "Get Link")?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftElementButton.tintColor = .lightGray
            rightElementButton.setImage(UIImage(named: "Share Other")?.withRenderingMode(.alwaysTemplate), for: .normal)
            rightElementButton.tintColor = .darkBlue
            elementNameLabel.font = Text.style7.font
            elementNameLabel.textColor = .barneyPurple
            elementNameLabel.text = linkLocation.replacingOccurrences(of: "https://www.", with: "")
        } else {
            leftElementButton.setImage(UIImage(named: "expand")?.withRenderingMode(.alwaysTemplate), for: .normal)
            leftElementButton.tintColor = .darkBlue
            rightElementButton.isHidden = true
            elementNameLabel.font = Text.style7.font
            elementNameLabel.textColor = .darkBlue
            elementNameLabel.text = linkWasGeneratedNow ? "Hide link settings".localized() : "Show link settings".localized()
            isMenuExpanded = linkWasGeneratedNow
        }
    }
    
    override func prepareForReuse() {
        rightElementButton.isHidden = false
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if cellType == .linkSettings {
            isMenuExpanded.toggle()
            elementNameLabel.text = isMenuExpanded ? "Hide link settings".localized() : "Show link settings".localized()
        }
        
        buttonAction?()
    }

    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
