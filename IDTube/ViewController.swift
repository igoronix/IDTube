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
        
//        ServerProvider.getVideos(page: 0, successCompletion: { (result) in
//            self._sections.append(result as! VideoItems)
//            self._collectionNode.reloadData()
//        }, failureCompletion: { (error) in
//            debugPrint(error as Any)
//        })
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
        textCellNode.text = String(format: "Section %zd", indexPath.section + 1)
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
        return CGSize(width: Int(videoItem.snippet.thumbnails[.Medium]!.width), height: Int(videoItem.snippet.thumbnails[.Medium]!.height + 84))
    }
}

extension ViewController: ASCollectionDelegate {
    
    func nextPageWithCompletion(_ block: @escaping (_ results: [VideoItem]) -> ()) {
        ServerProvider.getVideos(pageToken: self.nextPageToken, successCompletion: { (result) in
            self.nextPageToken = result?.nextPageToken
            if let res = result?.items {
                block(res)
            }
        }, failureCompletion: { (error) in
            debugPrint(error as Any)
        })
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let videoItem = _sections[indexPath.section][indexPath.item]
        let cellNode = VideoItemCellNode(with: videoItem.snippet.title, imageUrl:videoItem.snippet.thumbnails[.High]!.url);
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

