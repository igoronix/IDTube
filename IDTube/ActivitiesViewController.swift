//
//  ActivitiesViewController.swift
//  IDTube
//
//  Created by igor on 1/31/17.
//
//

import UIKit

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire

class ActivitiesViewController: UIViewController, MosaicCollectionViewLayoutDelegate, ASCollectionDataSource {
    
    var _sections :[VideoItems] = []
    let _collectionNode: ASCollectionNode!
    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    var nextPageToken: String?
    
    required init?(coder aDecoder: NSCoder) {
        let layout = MosaicCollectionViewLayout()
        layout.numberOfColumns = 2;
        layout.headerHeight = 44;
        _collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(coder: aDecoder)
        layout.delegate = self
        
        nextPageToken = ""
        
        _collectionNode.dataSource = self;
        _collectionNode.delegate = self;
        _collectionNode.view.layoutInspector = _layoutInspector
        _collectionNode.backgroundColor = UIColor.white
        _collectionNode.view.isScrollEnabled = true
        _collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        
        ServerProvider.getCategories(nextPageToken: self.nextPageToken, successCompletion: { (result) in
            result.items.forEach({ (item) in
                DispatchQueue.global().async {
                    ServerProvider.getVideos(nextPageToken: nil, count:2, videoCategoryId:item.id, successCompletion: { (itemsForCategory) in
                        guard itemsForCategory.items.count > 0 else { return }
                        
                        itemsForCategory.categoryTitle = item.snippet?.title
                        self._sections.append(itemsForCategory)
                        let newSectionIndex = self._sections.count - 1;
                        self._collectionNode.performBatch(animated: true, updates: {
                            self._collectionNode.insertSections(IndexSet(integer: newSectionIndex))
                            var indexPaths = [IndexPath]()
                            
                            for row in 0..<itemsForCategory.items.count {
                                indexPaths.append(IndexPath(row: row, section: newSectionIndex))
                            }
                            self._collectionNode.insertItems(at: indexPaths)
                        }, completion: nil)
                    }, failureCompletion: { (errorForCategory) in
                    })
                }
            })
        }) { (error) in
            
        }
    }
    
    deinit {
        _collectionNode.dataSource = nil;
        _collectionNode.delegate = nil;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubnode(_collectionNode!)
    }
    
    override func viewWillLayoutSubviews() {
        _collectionNode.frame = self.view.bounds;
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        let textAttributes : NSDictionary = [
            NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
            NSForegroundColorAttributeName: UIColor.gray
        ]
        let textInsets = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        let textCellNode = ASTextCellNode(attributes: textAttributes as! [AnyHashable : Any], insets: textInsets)
        
        let videoItems = _sections[indexPath.section]
        if let title = videoItems.categoryTitle {
            textCellNode.text = "\(title)"//String(format: "Section %zd", indexPath.section + 1)
        }
        return textCellNode;
    }
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _sections.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return _sections[section].items.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        let videoItem = _sections[originalItemSizeAtIndexPath.section].items[originalItemSizeAtIndexPath.item]
        let size = CGSize(width: CGFloat(videoItem.snippet!.thumbnails[.Medium]!.width), height: CGFloat(videoItem.snippet!.thumbnails[.Medium]!.height) + kIDDescriptionHeight)
        debugPrint("path \(originalItemSizeAtIndexPath) size = \(size)")
        return size
    }
}

extension ActivitiesViewController: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let videoItem = _sections[indexPath.section].items[indexPath.item]
        let cellNode = VideoItemCellNode(item: videoItem);
        return cellNode;
    }
}

