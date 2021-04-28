//
//  TagsNamesCollectionViewCell.swift
//  Permanent
//
//  Created by Lucian Cerbu on 13.04.2021.
//

import UIKit

class TagsNamesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TagsNamesCollectionViewCell"
    var tagNames: [String]?
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var tagsNameCollectionView: UICollectionView!
    @IBOutlet weak var cellNoItemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagsNameCollectionView.register(UINib(nibName: TagCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
        
        let layout = UICollectionViewFlowLayout()
        tagsNameCollectionView?.collectionViewLayout = layout
        
        self.tagsNameCollectionView.dataSource = self
        self.tagsNameCollectionView.delegate = self
        
        tagsNameCollectionView.backgroundColor = .clear
        tagsNameCollectionView.indicatorStyle = .white
        tagsNameCollectionView.isUserInteractionEnabled = false
        
        cellTitleLabel.text = "Tags".localized()
        cellTitleLabel.textColor = .white
        cellTitleLabel.font = Text.style9.font
        
        cellNoItemLabel.text = "Tap to add tags".localized()
        cellNoItemLabel.textColor = .white
        cellNoItemLabel.backgroundColor = .clear
        cellNoItemLabel.font = Text.style8.font
        cellNoItemLabel.isHidden = true
        
        let columnLayout = TagsCollectionViewLayout()
        columnLayout.cellSpacing = 5
        tagsNameCollectionView.collectionViewLayout = columnLayout
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
      
    func configure(tagNames: [String]) {
        self.tagNames = tagNames
        tagsNameCollectionView.isHidden = (tagNames.count == 0)
        cellNoItemLabel.isHidden = tagNames.count > 0
        tagsNameCollectionView.reloadData()
    }
}

extension TagsNamesCollectionViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagNames?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as! TagCollectionViewCell
        if let tagName = tagNames?[indexPath.row] {
            cell.configure(name: tagName, font: Text.style8.font, fontColor: .white, cornerRadius: 5, backgroundColor: .darkGray)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  let name = tagNames?[indexPath.row] {
            let attributedName = NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: cellTitleLabel.font as Any])
            let width = attributedName.boundingRect(with: CGSize(width: collectionView.bounds.width, height: 30), options: [], context: nil).size.width
            return CGSize(width: 15 + width , height: 30)
        }
        return CGSize(width: 0, height: 0)
    }
}
