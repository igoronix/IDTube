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

class ViewController: UIViewController, MosaicCollectionViewLayoutDelegate, ASCollectionDataSource, ASCollectionDelegate  {

    var _sections = [VideoItems]()
    let _collectionNode: ASCollectionNode!
    let _layoutInspector = MosaicCollectionViewLayoutInspector()
    
    required init?(coder aDecoder: NSCoder) {
        let layout = MosaicCollectionViewLayout()
        layout.numberOfColumns = 2;
        layout.headerHeight = 44;
        _collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(coder: aDecoder)
        layout.delegate = self
        
        _collectionNode.dataSource = self;
        _collectionNode.delegate = self;
        _collectionNode.view.layoutInspector = _layoutInspector
        _collectionNode.backgroundColor = UIColor.white
        _collectionNode.view.isScrollEnabled = true
        _collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        
        ServerProvider.getVideos(page: 0, successCompletion: { (result) in
            self._sections.append(result as! VideoItems)
            self._collectionNode.reloadData()
        }, failureCompletion: { (error) in
            debugPrint(error as Any)
        })
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
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let videoItem = _sections[indexPath.section].items[indexPath.item]
        let cellNode = ImageCellNode(with: videoItem.snippet.title, url:videoItem.snippet.thumbnails[.High]!.url);
        return cellNode;
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
        return _sections[section].items.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        let videoItem = _sections[originalItemSizeAtIndexPath.section].items[originalItemSizeAtIndexPath.item]
        return CGSize(width: Int(videoItem.snippet.thumbnails[.Medium]!.width), height: Int(videoItem.snippet.thumbnails[.Medium]!.height))
//        return CGSize(width:320, height:180)
    }
}

