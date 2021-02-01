/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import UIKit

open class TextMessageSizeCalculator: MessageSizeCalculator {

    public var incomingMessageLabelInsets = UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 14)
    public var outgoingMessageLabelInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 18)
    
    var incomingMessageLabelInsetsNoTail: UIEdgeInsets {
        var tmp = incomingMessageLabelInsets
        tmp.left -= 4
        return tmp
    }
    
    var incomingMessageLabelInsetsNoTailSingleLetter: UIEdgeInsets {
        var tmp = incomingMessageLabelInsets
        tmp.right += 4
        return tmp
    }
    
    var outgoingMessageLabelInsetsNoTail: UIEdgeInsets {
        var tmp = outgoingMessageLabelInsets
        tmp.right -= 4
        return tmp
    }
    
    var outgoingMessageLabelInsetsNoTailSingleLetter: UIEdgeInsets {
        var tmp = outgoingMessageLabelInsets
        tmp.left += 4
        return tmp
    }

    public var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)

    internal func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        
        let isNextSameSender = dataSource.isNextMessageSameSender(as: message)
        
        var isSingleLetter = false
        if case let .text(content) = message.kind, content.count == 1 {
            isSingleLetter = true
        }
        
        if isFromCurrentSender {
            if isNextSameSender {
                if isSingleLetter {
                    return outgoingMessageLabelInsetsNoTailSingleLetter
                } else {
                    return outgoingMessageLabelInsetsNoTail
                }
            } else {
                return outgoingMessageLabelInsets
            }
        } else {
            if isNextSameSender {
                if isSingleLetter {
                    return incomingMessageLabelInsetsNoTailSingleLetter
                } else {
                    return incomingMessageLabelInsetsNoTail
                }
            } else {
                return incomingMessageLabelInsets
            }
        }
    }
    
    open override func messageContainerPadding(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        
        let isNextSameSender = dataSource.isNextMessageSameSender(as: message)
        
        var isSingleLetter = false
        if case let .text(content) = message.kind, content.count == 1 {
            isSingleLetter = true
        }
        
        var padding = super.messageContainerPadding(for: message)
        
        if isFromCurrentSender {
            if isNextSameSender {
                if isSingleLetter {
                    padding.right += 4
                    return padding
                } else {
                    padding.right += 4
                    return padding
                }
            } else {
                return padding
            }
        } else {
            if isNextSameSender {
                if isSingleLetter {
                    padding.left += 4
                    return padding
                } else {
                    padding.left += 4
                    return padding
                }
            } else {
                return padding
            }
        }
    }

    open override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = messageLabelInsets(for: message)
        return maxWidth - textInsets.horizontal
    }

    open override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)

        var messageContainerSize: CGSize
        let attributedText: NSAttributedString

        let textMessageKind = message.kind.textMessageKind
        switch textMessageKind {
        case .attributedText(let text):
            attributedText = text
        case .text(let text), .emoji(let text):
            attributedText = NSAttributedString(string: text, attributes: [.font: messageLabelFont])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }

        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)

        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical

        return messageContainerSize
    }

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont

        switch message.kind {
        case .attributedText(let text):
            guard !text.string.isEmpty else { return }
            guard let font = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return }
            attributes.messageLabelFont = font
        default:
            break
        }
    }
}
