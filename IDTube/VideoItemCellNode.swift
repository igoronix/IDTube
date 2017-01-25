import UIKit
import AsyncDisplayKit

class VideoItemCellNode: ASCellNode {
    
    let thumbnailImageNode: ASNetworkImageNode
    let descriptionTextNode: ASTextNode
//    var title: String?
    required init(with title:String?, imageUrl:String?) {
        
        thumbnailImageNode = ASNetworkImageNode()
        descriptionTextNode = ASTextNode()
        
        super.init()
        
        backgroundColor = UIColor.white
        clipsToBounds = true
        
        //Animal Image
        thumbnailImageNode.url = URL(string: imageUrl!)
        thumbnailImageNode.clipsToBounds = true
        thumbnailImageNode.delegate = self
        thumbnailImageNode.placeholderFadeDuration = 0.25
        thumbnailImageNode.contentMode = .scaleAspectFill
//        thumbnailImageNode.shouldRenderProgressImages = true
        thumbnailImageNode.placeholderEnabled = true
//        thumbnailImageNode.shouldCacheImage = true
        thumbnailImageNode.backgroundColor = UIColor(white: 0.777, alpha: 1.0)
        
        //Description
//        self.title = title
        descriptionTextNode.attributedText = NSAttributedString(string: title!)
        descriptionTextNode.backgroundColor = UIColor.clear
        descriptionTextNode.placeholderEnabled = true
        descriptionTextNode.placeholderFadeDuration = 0.25
        descriptionTextNode.placeholderColor = UIColor(white: 0.777, alpha: 1.0)
    
        addSubnode(thumbnailImageNode)
        addSubnode(descriptionTextNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.75
        if thumbnailImageNode.image != nil {
            imageRatio = (thumbnailImageNode.image?.size.height)! / (thumbnailImageNode.image?.size.width)!
        }
        
        var newRatio = 1-imageRatio;
        let imageRatioSpec = ASRatioLayoutSpec(ratio: imageRatio, child: thumbnailImageNode)
        
        if newRatio <= 0 {
            newRatio = 0.25
        }
        let imageRatioSpec2 = ASRatioLayoutSpec(ratio: newRatio, child: descriptionTextNode)
        
        let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 3, justifyContent: .center, alignItems: .stretch, children: [imageRatioSpec, imageRatioSpec2])
        
        return verticalStackSpec
    }
}

// MARK: - ASNetworkImageNodeDelegate

extension VideoItemCellNode: ASNetworkImageNodeDelegate {
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        self.setNeedsLayout()
    }
}
