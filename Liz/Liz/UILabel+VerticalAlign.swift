import UIKit

extension UILabel {
    
    func alignTop() {
        guard self.text != nil else {
			log.info("Tried to align a label with no text in it.")
            return
        }
        let attributes = [NSFontAttributeName: self.font]
        let fontSize = self.text!.sizeWithAttributes(attributes)
        let finalHeight = fontSize.height * CGFloat(self.numberOfLines)
        let finalWidth = self.frame.size.width
        
        let rect = self.text!.boundingRectWithSize(CGSizeMake(finalWidth, finalHeight), options: .TruncatesLastVisibleLine, attributes: attributes, context: nil)
        let theStringSize = rect.size
        let newLinesToPad = (finalHeight - theStringSize.height)/fontSize.height
        
        Int(newLinesToPad).times {
            self.text = self.text!.stringByAppendingString("\n ")
        }
    }
    
    func alignBottom() {
        guard self.text != nil else {
			log.info("Tried to align a label with no text in it.")
            return
        }
        let attributes = [NSFontAttributeName: self.font]
        let fontSize = self.text!.sizeWithAttributes(attributes)
        let finalHeight = fontSize.height * CGFloat(self.numberOfLines)
        let finalWidth = self.frame.size.width
        
        let rect = self.text!.boundingRectWithSize(CGSizeMake(finalWidth, finalHeight), options: .TruncatesLastVisibleLine, attributes: attributes, context: nil)
        let theStringSize = rect.size
        let newLinesToPad = (finalHeight - theStringSize.height)/fontSize.height
        
        Int(newLinesToPad).times {
            self.text = " \n" + self.text!
        }
    }
}