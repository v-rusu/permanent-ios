//
//  PasswordElementView.swift
//  Permanent
//
//  Created by Lucian Cerbu on 08.01.2021.
//

import UIKit

class PasswordElementView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var value: String? {
        return passwordTextField.text
    }
    
    var delegate: UITextFieldDelegate? {
        didSet {
            passwordTextField.delegate = delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        loadNib()
        setupView(contentView)
        contentView.backgroundColor = .blueGray
        
    }
    func configurePasswordElementUI(label: String, returnKey: UIReturnKeyType = UIReturnKeyType.default, passFieldContentType: UITextContentType = .password) {
        self.contentView.backgroundColor = .white
        self.valueLabel.text = label
        self.valueLabel.font = Text.style3.font
        self.passwordTextField.textColor = .middleGray
        self.passwordTextField.returnKeyType = returnKey
        self.passwordTextField.textContentType = passFieldContentType
        self.passwordTextField.isSecureTextEntry = true
    }
    func clearPasswordField() {
        self.passwordTextField.text = ""
    }
}
