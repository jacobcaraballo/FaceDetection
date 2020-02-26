
import UIKit
import Vision

class FaceView: UIView {
	
	var didUpdateSize: ((CGSize?) -> ())?
	var didUpdateFaceCenter: ((CGPoint?) -> ())?
	var didUpdateLeftEyeCenter: ((CGPoint?) -> ())?
	var didUpdateRightEyeCenter: ((CGPoint?) -> ())?
	var didUpdateAngles: ((CGFloat, CGFloat) -> ())?
	
	var leftPupil: [CGPoint]?
	var rightPupil: [CGPoint]?
	var leftEye: [CGPoint]?
	var rightEye: [CGPoint]?
	var leftEyebrow: [CGPoint]?
	var rightEyebrow: [CGPoint]?
	var nose: [CGPoint]?
	var outerLips: [CGPoint]?
	var innerLips: [CGPoint]?
	var faceContour: [CGPoint]?
	var medianLine: [CGPoint]?
	var noseCrest: [CGPoint]?
	
	var boundingBox = CGRect.zero
	var roll: CGFloat?
	var yaw: CGFloat?
	
	func clear() {
		leftPupil = nil
		rightPupil = nil
		leftEye = nil
		rightEye = nil
		leftEyebrow = nil
		rightEyebrow = nil
		nose = nil
		outerLips = nil
		innerLips = nil
		faceContour = nil
		medianLine = nil
		noseCrest = nil
		
		boundingBox = .zero
		
		DispatchQueue.main.async {
			self.setNeedsDisplay()
		}
	}
	
	func drawLines(between points: [CGPoint]?, closed: Bool = true) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		guard let points = points, !points.isEmpty else { return }
		guard points.count > 1 else {
			drawPoint(points.first)
			return
		}
		context.addLines(between: points)
		if closed { context.closePath() }
		context.strokePath()
	}
	
	func drawPoint(_ point: CGPoint?) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		guard let point = point else { return }
		context.fill(CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
	}
	
	
	
	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		context.saveGState()
		defer { context.restoreGState() }
				
		context.addRect(boundingBox)
		UIColor.red.setStroke()
		context.strokePath()
		UIColor.white.setStroke()
		
		drawLines(between: leftPupil)
		drawLines(between: rightPupil)
		drawLines(between: leftEye)
		drawLines(between: rightEye)
		drawLines(between: outerLips)
		drawLines(between: innerLips)
		drawLines(between: leftEyebrow, closed: false)
		drawLines(between: rightEyebrow, closed: false)
		drawLines(between: nose, closed: false)
		drawLines(between: faceContour, closed: false)
		drawLines(between: medianLine, closed: false)
		
		if let noseCrest = noseCrest, noseCrest.count >= 2 {
			drawPoint(noseCrest[1])
			didUpdateFaceCenter?(noseCrest[1])
		}
		
		didUpdateSize?(box(between: faceContour)?.size)
		didUpdateLeftEyeCenter?(leftPupil?.first)
		didUpdateRightEyeCenter?(rightPupil?.first)
		didUpdateAngles?(roll ?? 0, yaw ?? 0)
		
		
	}
	
	func box(between points: [CGPoint]?) -> CGRect? {
		guard let points = points else { return nil }
		let path = CGMutablePath()
		path.addLines(between: points)
		return path.boundingBoxOfPath
	}
}

