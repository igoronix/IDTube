//
//  ImageCellNode.swift
//  Sample
//
//  Created by Rajeev Gupta on 11/9/16.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit

class ImageCellNode: ASCellNode {
    
    fileprivate let backgroundImageNode: ASImageNode
    fileprivate let animalImageNode: ASNetworkImageNode
    fileprivate let animalDescriptionTextNode: ASTextNode
    
    required init(with title:String?, url:String?) {
        
        backgroundImageNode = ASImageNode()
        animalImageNode     = ASNetworkImageNode()
        animalDescriptionTextNode = ASTextNode()
        
        super.init()
        
        backgroundColor = UIColor.lightGray
        clipsToBounds = true
        
        //Animal Image
        animalImageNode.url = URL(string: url!)
        animalImageNode.clipsToBounds = true
        animalImageNode.delegate = self
        animalImageNode.placeholderFadeDuration = 0.15
        animalImageNode.contentMode = .scaleAspectFill
        animalImageNode.shouldRenderProgressImages = true
        
        //Animal Description
        animalDescriptionTextNode.attributedText = NSAttributedString(string: title!)
//        animalDescriptionTextNode.truncationAttributedText = NSAttributedString(forDescription: "…")
        animalDescriptionTextNode.backgroundColor = UIColor.clear
        animalDescriptionTextNode.placeholderEnabled = true
        animalDescriptionTextNode.placeholderFadeDuration = 0.15
        animalDescriptionTextNode.placeholderColor = UIColor(white: 0.777, alpha: 1.0)
        
        //Background Image
        backgroundImageNode.placeholderFadeDuration = 0.15
        backgroundImageNode.imageModificationBlock = { image in
            let newImage = UIImage.resize(image, newSize: CGSize(width: image.size.width, height: image.size.height)).applyBlur(withRadius: 10, tintColor: UIColor(white: 0.8, alpha: 0.3), saturationDeltaFactor: 1.8, maskImage: nil)
            return (newImage != nil) ? newImage : image
        }
        
        addSubnode(backgroundImageNode)
        addSubnode(animalImageNode)
        
        addSubnode(animalDescriptionTextNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.5
        if animalImageNode.image != nil {
//            imageRatio = (animalImageNode.image?.size.height)! / (animalImageNode.image?.size.width)!
            imageRatio = constrainedSize.min.height/constrainedSize.max.width
        }
        
        let imageRatioSpec = ASRatioLayoutSpec(ratio: imageRatio, child: animalImageNode)
        
        let relativeSpec = ASRelativeLayoutSpec(
            horizontalPosition: .start,
            verticalPosition: .end,
            sizingOption: ASRelativeLayoutSpecSizingOption(rawValue:0),
            child: animalDescriptionTextNode)
        
        let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .stretch, children: [imageRatioSpec, relativeSpec])
        verticalStackSpec.style.flexShrink = 1.0
        
//        let backgroundLayoutSpec = ASBackgroundLayoutSpec(child: verticalStackSpec, background: backgroundImageNode)
        
        return verticalStackSpec
    }
}

// MARK: - ASNetworkImageNodeDelegate

extension ImageCellNode: ASNetworkImageNodeDelegate {
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        backgroundImageNode.image = image
    }
}
