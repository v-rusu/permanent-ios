//
//  PublicGalleryCellCollectionViewCell.swift
//  Permanent
//
//  Created by Lucian Cerbu on 04.04.2022.
//

import UIKit

class PublicGalleryCellCollectionViewCell: UICollectionViewCell {
    static let identifier = "PublicGalleryCellCollectionViewCell"
    @IBOutlet weak var archiveImage: UIImageView!
    @IBOutlet weak var archiveTitleLabel: UILabel!
    @IBOutlet weak var archiveUserRole: UILabel!
    @IBOutlet weak var linkIconButton: UIButton!
    @IBOutlet weak var rightSideBackgroundView: UIView!
    
    var buttonAction: ButtonAction?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(archive: ArchiveVOData?, section: PublicGalleryCellType) {
        if let name = archive?.fullName {
            archiveTitleLabel.text = "The \(name) Archive"
        } else {
            archiveTitleLabel.text = "The Archive"
        }
        
        guard let thumbnail = archive?.thumbURL1000 else { return }
        let role = archive?.accessRole ?? ""
        
        archiveImage.sd_setImage(with: URL(string: thumbnail))

        archiveUserRole.text = AccessRole.roleForValue(role).groupName
        
        switch section {
        case .onlineArchives:
            initUIforLocalArchive()
            
        case .popularPublicArchives, .searchResultArchives:
            initUIforPublicArchive()
        }
    }
    
    private func initUIforLocalArchive() {
        rightSideBackgroundView.backgroundColor = .primary
        
        archiveTitleLabel.textColor = .white
        archiveTitleLabel.font = Text.style9.font
        archiveUserRole.textColor = .white
        archiveUserRole.font = Text.style12.font
        linkIconButton.tintColor = .white
    }
    
    private func initUIforPublicArchive() {
        rightSideBackgroundView.backgroundColor = .galleryGray
        
        archiveTitleLabel.textColor = .primary
        archiveTitleLabel.font = Text.style9.font
        archiveUserRole.isHidden = true
        linkIconButton.tintColor = .primary
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        archiveTitleLabel.text = "The Archive"
        archiveImage.image = .placeholder
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        buttonAction?()
    }
}
