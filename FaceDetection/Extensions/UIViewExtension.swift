import UIKit

extension UIView {
	@IBInspectable
	var cornerRadius: CGFloat {
		get { return layer.cornerRadius }
		set { layer.cornerRadius = newValue }
	}
}

extension UIImage {
	var aspect: CGFloat {
		return size.width / size.height
	}
	func estimatedHeight(for width: CGFloat) -> CGFloat {
		return width / aspect
	}
}
