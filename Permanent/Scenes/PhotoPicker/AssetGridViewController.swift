//
//  AssetGridViewController.swift
//  Permanent
//
//  Created by Vlad Alexandru Rusu on 25.08.2021.
//

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

protocol AssetPickerDelegate: AnyObject {
    func assetGridViewControllerDidPickAssets(_ vc: AssetGridViewController?, assets: [PHAsset])
}

class AssetGridViewController: UICollectionViewController {
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var availableWidth: CGFloat = 0
    
    weak var delegate: AssetPickerDelegate?
    
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var selectButtonItem: UIBarButtonItem!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var isSelectGesture: Bool?
    fileprivate var startGestureCoordinates: CGPoint = .zero
    fileprivate var stopGestureCoordinates: CGPoint = .zero
    fileprivate var previousSelectedElements = 0
    
    fileprivate var pendingFirstScroll = true
    
    // MARK: UIViewController / Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // Reaching this point without a segue means that this AssetGridViewController
        // became visible at app launch. As such, match the behavior of the segue from
        // the default "All Photos" view.
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(panGesture)
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        updateToolbar()
        
        styleNavBar()
        navigationController?.toolbar.tintColor = .primary
        
        if delegate == nil {
            delegate = tabBarController as? PhotoTabBarViewController
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigateToLastCell()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    @objc func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        var selectionFrame: CGRect = CGRect()
        if sender.state == .ended || sender.state == .failed || collectionView.allowsSelection == false {
            isSelectGesture = nil
            return
        }
        let location = sender.location(in: collectionView)
        
        if sender.state == .began {
            startGestureCoordinates = location
            guard let firstTapCell = collectionView.indexPathForItem(at: startGestureCoordinates) else { return }
            isSelectGesture = !(collectionView.indexPathsForSelectedItems?.contains(firstTapCell) ?? false)
            selectionFrame = CGRect(x: startGestureCoordinates.x, y: startGestureCoordinates.y, width: 1, height: 1)
        } else if sender.state == .changed || sender.state == .ended {
            stopGestureCoordinates = location
            selectionFrame = CGRect(x: startGestureCoordinates.x, y: startGestureCoordinates.y, width: stopGestureCoordinates.x - startGestureCoordinates.x, height: stopGestureCoordinates.y - startGestureCoordinates.y)
        }
        
        let select = collectionView.indexPathsForElements(in: selectionFrame)
        
        if isSelectGesture ?? false {
            for each in select {
                collectionView.selectItem(at: each, animated: true, scrollPosition: [])
            }
        } else {
            for each in select {
                collectionView.deselectItem(at: each, animated: true)
            }
        }
        if (collectionView.indexPathsForSelectedItems?.count ?? 0) != previousSelectedElements {
            updateToolbar()
        }
        
        previousSelectedElements = collectionView.indexPathsForSelectedItems?.count ?? 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func styleNavBar() {
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .darkBlue
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: Text.style14.font
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func selectAllPhotos(_ sender: Any) {
        if collectionView.indexPathsForSelectedItems?.count == fetchResult.count {
            collectionView.indexPathsForSelectedItems?.forEach({ ip in
                collectionView.deselectItem(at: ip, animated: true)
            })
        } else {
            for idx in 0..<fetchResult.count {
                collectionView.selectItem(at: [0, idx], animated: true, scrollPosition: [])
            }
        }
        updateToolbar()
    }
    
    @objc func uploadPhotos(_ sender: Any) {
        let selectedAssets = collectionView.indexPathsForSelectedItems?.map({ ip in
            fetchResult.object(at: ip.item)
        }) ?? []
        
        delegate?.assetGridViewControllerDidPickAssets(self, assets: selectedAssets)
    }
    
    func updateToolbar() {
        var items: [UIBarButtonItem]

        if collectionView.indexPathsForSelectedItems?.count == fetchResult.count {
            items = [UIBarButtonItem(title: "Deselect All".localized(), style: .plain, target: self, action: #selector(selectAllPhotos(_:)))]
        } else {
            items = [UIBarButtonItem(title: "Select All".localized(), style: .plain, target: self, action: #selector(selectAllPhotos(_:)))]
        }
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        if let count = collectionView.indexPathsForSelectedItems?.count, count > 0 {
            let uploadButtonTitle = "Upload <COUNT> items".localized().replacingOccurrences(of: "<COUNT>", with: "\(count)")
            items.append(contentsOf: [
                UIBarButtonItem(title: uploadButtonTitle, style: .plain, target: self, action: #selector(uploadPhotos(_:)))
            ])
            setToolbarItems(items, animated: true)
        } else {
            setToolbarItems(items, animated: true)
        }
    }
    
    // MARK: UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    /// - Tag: PopulateCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as? GridViewCell
            else { return UICollectionViewCell() }
        cell.configure()
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateToolbar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateToolbar()
    }
    
    // MARK: UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(
            for: addedAssets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: nil
        )
        imageManager.stopCachingImages(
            for: removedAssets,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: nil
        )
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [
                    CGRect(
                        x: new.origin.x,
                        y: old.maxY,
                        width: new.width,
                        height: new.maxY - old.maxY
                    )
                ]
            }
            if old.minY > new.minY {
                added += [
                    CGRect(
                        x: new.origin.x,
                        y: new.minY,
                        width: new.width,
                        height: old.minY - new.minY
                    )
                ]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [
                    CGRect(
                        x: new.origin.x,
                        y: new.maxY,
                        width: new.width,
                        height: old.maxY - new.maxY
                    )
                ]
            }
            if old.minY < new.minY {
                removed += [
                    CGRect(
                        x: new.origin.x,
                        y: old.minY,
                        width: new.width,
                        height: new.minY - old.minY
                    )
                ]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    fileprivate func navigateToLastCell() {
        if pendingFirstScroll {
            pendingFirstScroll = false
            let item = collectionView(collectionView, numberOfItemsInSection: 0) - 1
            let lastItemIndex = IndexPath(item: item, section: 0)
            collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension AssetGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(
                            at: IndexPath(item: fromIndex, section: 0),
                            to: IndexPath(item: toIndex, section: 0)
                        )
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AssetGridViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: collectionView)
            return abs(translation.x) > abs(translation.y)
        }
        
        return true
    }
}
