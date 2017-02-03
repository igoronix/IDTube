import UIKit
import AsyncDisplayKit

class VideoItemCellNode: ASCellNode {
    
    let thumbnailImageNode: ASNetworkImageNode
    let descriptionTextNode: ASTextNode
//    fileprivate let backgroundImageNode: ASImageNode
    let videoItem: VideoItem
    required init(item:VideoItem) {
        
//        backgroundImageNode = ASImageNode()
        thumbnailImageNode = ASNetworkImageNode()
        descriptionTextNode = ASTextNode()
        videoItem = item
        
        super.init()
        
        backgroundColor = UIColor.white
        clipsToBounds = true
        
        //Animal Image
        thumbnailImageNode.url = URL(string: videoItem.snippet!.thumbnails[.Medium]!.url)
        thumbnailImageNode.clipsToBounds = true
        thumbnailImageNode.delegate = self
        thumbnailImageNode.contentMode = .center
        thumbnailImageNode.shouldRenderProgressImages = true
//        thumbnailImageNode.shouldCacheImage = true
        thumbnailImageNode.placeholderEnabled = true
        thumbnailImageNode.placeholderFadeDuration = 0.15
        thumbnailImageNode.defaultImage = UIImage(named: "ic_wallpaper_48pt")
        
        thumbnailImageNode.borderWidth = 1
        thumbnailImageNode.tintColor = UIColor(white: 0.777, alpha: 1.0)
        thumbnailImageNode.borderColor = UIColor(white: 0.777, alpha: 1.0).cgColor

//        Description
        descriptionTextNode.attributedText = NSAttributedString(string: videoItem.snippet!.title)
        descriptionTextNode.backgroundColor = UIColor.clear
        descriptionTextNode.placeholderEnabled = true
        descriptionTextNode.placeholderFadeDuration = 0.15
        descriptionTextNode.placeholderColor = UIColor(white: 0.777, alpha: 1.0)
//
//        //Background Image
//        backgroundImageNode.placeholderFadeDuration = 0.15
//        backgroundImageNode.placeholderEnabled = true
//        backgroundImageNode.imageModificationBlock = { image in
//            let h = CGFloat(self.videoItem.snippet.thumbnails[.Medium]!.height) + kIDDescriptionHeight
//            let w = CGFloat(self.videoItem.snippet.thumbnails[.Medium]!.width)
//
//            let newImage = UIImage.resize(image, newSize: CGSize(width: w, height: h)).applyBlur(withRadius: 10, tintColor: UIColor(white: 0.5, alpha: 0.3), saturationDeltaFactor: 1.8, maskImage: nil)
//            return (newImage != nil) ? newImage : image
//        }
    
//        addSubnode(backgroundImageNode)
        addSubnode(thumbnailImageNode)
        addSubnode(descriptionTextNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let fullHeight = CGFloat(videoItem.snippet!.thumbnails[.Medium]!.height) + kIDDescriptionHeight

        let imageRatio:CGFloat = constrainedSize.max.height / fullHeight
        let imageRatioSpec = ASRatioLayoutSpec(ratio: imageRatio, child: thumbnailImageNode)
        
        let textRatio:CGFloat = kIDDescriptionHeight / fullHeight
        let descriptionRatioSpec = ASRatioLayoutSpec(ratio: textRatio, child: descriptionTextNode)
        
        let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .center, children: [imageRatioSpec, descriptionRatioSpec])
//        let backgroundLayoutSpec = ASBackgroundLayoutSpec(child: verticalStackSpec, background: backgroundImageNode)
        
        return verticalStackSpec
    }
}

// MARK: - ASNetworkImageNodeDelegate

extension VideoItemCellNode: ASNetworkImageNodeDelegate {
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
//        self.backgroundImageNode.image = image
//        self.setNeedsLayout()
    }
}
