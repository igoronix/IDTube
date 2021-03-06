//
//  ViewController.swift
//  IDTube
//
//  Created by igor on 1/16/17.
//
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire

let kIDDescriptionHeight:CGFloat = 76.0

class ViewController: UIViewController, MosaicCollectionViewLayoutDelegate, ASCollectionDataSource {

    var _sections :[[VideoItem]] = [[]]
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
        textCellNode.text = String(format: "Most popular", indexPath.section + 1)
        return textCellNode;
    }
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _sections.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return _sections[section].count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        let videoItem = _sections[originalItemSizeAtIndexPath.section][originalItemSizeAtIndexPath.item]
        let size = CGSize(width: CGFloat(videoItem.snippet!.thumbnails[.Medium]!.width), height: CGFloat(videoItem.snippet!.thumbnails[.Medium]!.height) + kIDDescriptionHeight)
        debugPrint("path \(originalItemSizeAtIndexPath) size = \(size)")
        return size
    }
}

extension ViewController: ASCollectionDelegate {
    
    func nextPageWithCompletion(_ block: @escaping ([VideoItem]) -> ()) {
        ServerProvider.getVideos(nextPageToken: self.nextPageToken, videoCategoryId: nil, successCompletion: { (result) in
            self.nextPageToken = result.nextPageToken
            block(result.items)
        }, failureCompletion: { (error) in
            debugPrint(error as Any)
        })
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let videoItem = _sections[indexPath.section][indexPath.item]
        let cellNode = VideoItemCellNode(item: videoItem);
        return cellNode;
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        nextPageWithCompletion { (results) in
            self.insertNewItems(videoItems:results)
            
            context.completeBatchFetching(true)
        }
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
    func insertNewItems(videoItems:[VideoItem]) {
        var indexPaths = [IndexPath]()
        
        for row in self._sections[0].count ..< (self._sections[0].count + videoItems.count) {
            let path = IndexPath(row: row, section: 0)
            indexPaths.append(path)
        }
        self._sections[0].append(contentsOf: videoItems)
        self._collectionNode.insertItems(at: indexPaths)
    }
}

