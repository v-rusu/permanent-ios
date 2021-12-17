//
//  ProfilePagePersonInfoCollectionViewCell.swift
//  Permanent
//
//  Created by Lucian Cerbu on 16.11.2021.
//

import UIKit

class ProfilePagePersonInfoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fullNameTitleLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var nicknameTitleLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var genderTitleLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var birthDateTitleLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    
    @IBOutlet weak var birthLocationTitleLabel: UILabel!
    @IBOutlet weak var birthLocationLabel: UILabel!
    
    
    static let identifier = "ProfilePagePersonInfoCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        fullNameTitleLabel.text = "Full Name".localized()
        fullNameTitleLabel.textColor = .darkGray
        fullNameTitleLabel.font = Text.style12.font
        
        nicknameTitleLabel.text = "Nickname".localized()
        nicknameTitleLabel.textColor = .darkGray
        nicknameTitleLabel.font = Text.style12.font
        
        genderTitleLabel.text = "Gender".localized()
        genderTitleLabel.textColor = .darkGray
        genderTitleLabel.font = Text.style12.font
        
        birthDateTitleLabel.text = "Birth Date".localized()
        birthDateTitleLabel.textColor = .darkGray
        birthDateTitleLabel.font = Text.style12.font
        
        birthLocationTitleLabel.text = "Birth Location".localized()
        birthLocationTitleLabel.textColor = .darkGray
        birthLocationTitleLabel.font = Text.style12.font
        
        fullNameLabel.textColor = .primary
        fullNameLabel.font = Text.style13.font
        
        nicknameLabel.textColor = .primary
        nicknameLabel.font = Text.style13.font
        
        genderLabel.textColor = .primary
        genderLabel.font = Text.style13.font
        
        birthDateLabel.textColor = .primary
        birthDateLabel.font = Text.style13.font
        
        birthLocationLabel.textColor = .primary
        birthLocationLabel.font = Text.style13.font
    }
    
    func configure(fullName: String?, nickname: String?, gender: String?, birthDate: String?, birthLocation: String?) {
        
        if let fullName = fullName {
            fullNameLabel.text = fullName
        } else {
            fullNameLabel.text = "Full name".localized()
        }
        
        if let nickname = nickname,
           !nickname.isEmpty {
            nicknameLabel.text = nickname
        } else {
            nicknameLabel.text = "Aliases or nicknames".localized()
        }
        
        if let gender = gender {
            genderLabel.text = gender
        } else {
            genderLabel.text = "Gender "
        }
        
        if let birthDate = birthDate {
            birthDateLabel.text = birthDate
        } else {
            birthDateLabel.text = "YYYY-MM-DD"
        }
        
        if let birthLocation = birthLocation {
            birthLocationLabel.text = birthLocation
        } else {
            birthLocationLabel.text = "Choose a location".localized()
        }
    }

    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
