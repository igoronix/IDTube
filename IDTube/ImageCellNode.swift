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
    
    fileprivate let animalImageNode: ASNetworkImageNode
    fileprivate let animalDescriptionTextNode: ASTextNode
    
    required init(with title:String?, imageUrl:String?) {
        
        animalImageNode = ASNetworkImageNode()
        animalDescriptionTextNode = ASTextNode()
        
        super.init()
        
        backgroundColor = UIColor.white
        clipsToBounds = true
        
        //Animal Image
        animalImageNode.url = URL(string: imageUrl!)
        animalImageNode.clipsToBounds = true
        animalImageNode.delegate = self
        animalImageNode.placeholderFadeDuration = 0.25
        animalImageNode.contentMode = .scaleAspectFill
        animalImageNode.shouldRenderProgressImages = true
        animalImageNode.placeholderEnabled = true
        animalImageNode.shouldCacheImage = true
        animalImageNode.backgroundColor = UIColor(white: 0.777, alpha: 1.0)
        
        //Animal Description
        animalDescriptionTextNode.attributedText = NSAttributedString(string: title!)
        animalDescriptionTextNode.backgroundColor = UIColor.clear
        animalDescriptionTextNode.placeholderEnabled = true
        animalDescriptionTextNode.placeholderFadeDuration = 0.25
        animalDescriptionTextNode.placeholderColor = UIColor(white: 0.777, alpha: 1.0)
    
        addSubnode(animalImageNode)
        addSubnode(animalDescriptionTextNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.75
        if animalImageNode.image != nil {
            imageRatio = (animalImageNode.image?.size.height)! / (animalImageNode.image?.size.width)!
        }
        
        var newRatio = 1-imageRatio;
        let imageRatioSpec = ASRatioLayoutSpec(ratio: imageRatio, child: animalImageNode)
        
        if newRatio <= 0 {
            newRatio = 0.25
        }
        let imageRatioSpec2 = ASRatioLayoutSpec(ratio: newRatio, child: animalDescriptionTextNode)
        
        let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 3, justifyContent: .center, alignItems: .stretch, children: [imageRatioSpec, imageRatioSpec2])
        
        return verticalStackSpec
    }
}

// MARK: - ASNetworkImageNodeDelegate

extension ImageCellNode: ASNetworkImageNodeDelegate {
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        self.setNeedsLayout()
    }
}
