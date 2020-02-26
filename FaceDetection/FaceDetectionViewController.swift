
import AVFoundation
import UIKit
import Vision

class FaceDetectionViewController: UIViewController {
	var sequenceHandler = VNSequenceRequestHandler()
	
	@IBOutlet var faceView: FaceView!
	let imageView = UIImageView()
	
	var currentImage: UIImage? {
		didSet {
			imageView.image = currentImage
		}
	}
	let leftEyeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
	let rightEyeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
	
	let session = AVCaptureSession()
	var previewLayer: AVCaptureVideoPreviewLayer!
	
	let dataOutputQueue = DispatchQueue(
		label: "video data queue",
		qos: .userInitiated,
		attributes: [],
		autoreleaseFrequency: .workItem)
	
	var faceViewHidden = false
	
	var maxX: CGFloat = 0.0
	var midY: CGFloat = 0.0
	var maxY: CGFloat = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureCaptureSession()
		
		maxX = view.bounds.maxX
		midY = view.bounds.midY
		maxY = view.bounds.maxY
		
		session.startRunning()
		setupImageView()
		layoutEyeImageViews()
		layoutFaceButton()
		layoutEyesButton()
		layoutWireframeButton()
	}
	
	private func layoutEyeImageViews() {
		
		leftEyeImageView.isHidden = true
		rightEyeImageView.isHidden = true
		leftEyeImageView.image = UIImage(named: "eyeLeft")
		rightEyeImageView.image = UIImage(named: "eyeRight")
		leftEyeImageView.contentMode = .scaleAspectFit
		rightEyeImageView.contentMode = .scaleAspectFit
		leftEyeImageView.alpha = 0
		rightEyeImageView.alpha = 0
		view.addSubview(leftEyeImageView)
		view.addSubview(rightEyeImageView)
		
		faceView.didUpdateLeftEyeCenter = { center in
			guard let center = center else {
				self.leftEyeImageView.alpha = 0
				return
			}
			self.leftEyeImageView.alpha = 1
			
			let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
				self.leftEyeImageView.center = center
			}
			anim.startAnimation()
		}
		
		faceView.didUpdateRightEyeCenter = { center in
			guard let center = center else {
				self.rightEyeImageView.alpha = 0
				return
			}
			self.rightEyeImageView.alpha = 1
			let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
				self.rightEyeImageView.center = center
			}
			anim.startAnimation()
		}
		
	}
	
	private func setupImageView() {
		
		imageView.image = currentImage
		imageView.contentMode = .scaleAspectFit
		imageView.alpha = 0
		view.addSubview(imageView)
		
		faceView.didUpdateSize = { size in
			guard var size = size else { return }
			size.height = self.currentImage?.estimatedHeight(for: size.width) ?? 0
			size.height += 100
			if size.height < 200 { size.height = 200 }
			size.width = size.height
			let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
				self.imageView.frame.size = size
			}
			anim.startAnimation()
		}
		
		faceView.didUpdateFaceCenter = { center in
			guard let center = center else {
				self.imageView.alpha = 0
				return
			}
			self.imageView.alpha = 1
			let anim = UIViewPropertyAnimator(duration: 0.2, curve: .linear) {
				self.imageView.center = center
			}
			anim.startAnimation()
		}
		
	}
	
	private func layoutFaceButton() {
		
		let faceButton = UIButton()
		faceButton.translatesAutoresizingMaskIntoConstraints = false
		faceButton.setTitle("Faces", for: .normal)
		faceButton.backgroundColor = UIColor(white: 0, alpha: 0.8)
		faceButton.addTarget(self, action: #selector(goToImageSelectionVC), for: .touchUpInside)
		faceButton.sizeToFit()
		view.addSubview(faceButton)
		
		faceButton.layer.cornerRadius = faceButton.frame.height  / 2
		
		NSLayoutConstraint.activate([
			
			faceButton.widthAnchor.constraint(equalToConstant: faceButton.frame.width + 20),
			faceButton.heightAnchor.constraint(equalToConstant: faceButton.frame.height + 10),
			faceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			faceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
			
			])
		
	}
	
	private func layoutEyesButton() {
		
		let eyesButton = UIButton()
		eyesButton.translatesAutoresizingMaskIntoConstraints = false
		eyesButton.setTitle("Eyes", for: .normal)
		eyesButton.backgroundColor = UIColor(white: 0, alpha: 0.8)
		eyesButton.addTarget(self, action: #selector(toggleEyes), for: .touchUpInside)
		eyesButton.sizeToFit()
		view.addSubview(eyesButton)
		
		eyesButton.layer.cornerRadius = eyesButton.frame.height  / 2
		
		NSLayoutConstraint.activate([
			
			eyesButton.widthAnchor.constraint(equalToConstant: eyesButton.frame.width + 20),
			eyesButton.heightAnchor.constraint(equalToConstant: eyesButton.frame.height + 10),
			eyesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			eyesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
			
			])
		
	}
	
	private func layoutWireframeButton() {
		
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Wireframe", for: .normal)
		button.backgroundColor = UIColor(white: 0, alpha: 0.8)
		button.addTarget(self, action: #selector(toggleWireframe), for: .touchUpInside)
		button.sizeToFit()
		view.addSubview(button)
		
		button.layer.cornerRadius = button.frame.height  / 2
		
		NSLayoutConstraint.activate([
			
			button.widthAnchor.constraint(equalToConstant: button.frame.width + 20),
			button.heightAnchor.constraint(equalToConstant: button.frame.height + 10),
			button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
			
			])
		
	}
	
	@objc func goToImageSelectionVC() {
		let vc = ImageSelectionViewController()
		vc.owner = self
		present(vc, animated: true, completion: nil)
	}
	
	@objc func toggleEyes() {
		toggleEyeVisibility(hidden: nil)
	}
	
	@objc func toggleWireframe() {
		toggleWireframeVisibility(hidden: nil)
	}
	
	func toggleFaceViewVisibility(hidden: Bool?) {
		let isHidden = hidden ?? !faceView.isHidden
		faceView.isHidden = isHidden
	}
	
	func toggleEyeVisibility(hidden: Bool?) {
		let isHidden = hidden ?? !leftEyeImageView.isHidden
		leftEyeImageView.isHidden = isHidden
		rightEyeImageView.isHidden = isHidden
	}
	
	func toggleWireframeVisibility(hidden: Bool?) {
		let isHidden = hidden ?? !faceView.isHidden
		faceView.isHidden = isHidden
	}
	
}

// MARK: - Video Processing methods
extension FaceDetectionViewController {
	func configureCaptureSession() {
		// Define the capture device we want to use
		guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
												   for: .video,
												   position: .front) else {
													fatalError("No front video camera available")
		}
		
		// Connect the camera to the capture session input
		do {
			let cameraInput = try AVCaptureDeviceInput(device: camera)
			session.addInput(cameraInput)
		} catch {
			fatalError(error.localizedDescription)
		}
		
		// Create the video data output
		let videoOutput = AVCaptureVideoDataOutput()
		videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
		videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
		
		// Add the video output to the capture session
		session.addOutput(videoOutput)
		
		let videoConnection = videoOutput.connection(with: .video)
		videoConnection?.videoOrientation = .portrait
		
		// Configure the preview layer
		previewLayer = AVCaptureVideoPreviewLayer(session: session)
		previewLayer.videoGravity = .resizeAspectFill
		previewLayer.frame = view.bounds
		view.layer.insertSublayer(previewLayer, at: 0)
	}
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
		let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
		try? sequenceHandler.perform([detectFaceRequest], on: imageBuffer, orientation: .leftMirrored)
	}
}

extension FaceDetectionViewController {
	func convert(rect: CGRect) -> CGRect {
		let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
		let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
		return CGRect(origin: origin, size: size.cgSize)
	}
	
	func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
		let absolute = point.absolutePoint(in: rect)
		let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
		return converted
	}
	
	func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
		guard let points = points else {
			return nil
		}
		
		return points.compactMap { landmark(point: $0, to: rect) }
	}
	
	func updateFaceView(for result: VNFaceObservation) {
		defer { DispatchQueue.main.async { self.faceView.setNeedsDisplay() } }
		
		faceView.boundingBox = convert(rect: result.boundingBox)
		faceView.roll = CGFloat(result.roll?.floatValue ?? 0)
		faceView.yaw = CGFloat(result.yaw?.floatValue ?? 0)
		
		guard let landmarks = result.landmarks else { return }
		
		faceView.leftPupil = landmark(points: landmarks.leftPupil?.normalizedPoints, to: result.boundingBox)
		faceView.rightPupil = landmark(points: landmarks.rightPupil?.normalizedPoints, to: result.boundingBox)
		faceView.leftEye = landmark(points: landmarks.leftEye?.normalizedPoints, to: result.boundingBox)
		faceView.rightEye = landmark(points: landmarks.rightEye?.normalizedPoints, to: result.boundingBox)
		faceView.leftEyebrow = landmark(points: landmarks.leftEyebrow?.normalizedPoints, to: result.boundingBox)
		faceView.rightEyebrow = landmark(points: landmarks.rightEyebrow?.normalizedPoints, to: result.boundingBox)
		faceView.nose = landmark(points: landmarks.nose?.normalizedPoints, to: result.boundingBox)
		faceView.outerLips = landmark(points: landmarks.outerLips?.normalizedPoints, to: result.boundingBox)
		faceView.innerLips = landmark(points: landmarks.innerLips?.normalizedPoints, to: result.boundingBox)
		faceView.faceContour = landmark(points: landmarks.faceContour?.normalizedPoints, to: result.boundingBox)
		faceView.medianLine = landmark(points: landmarks.medianLine?.normalizedPoints, to: result.boundingBox)
		faceView.noseCrest = landmark(points: landmarks.noseCrest?.normalizedPoints, to: result.boundingBox)
		
	}
	
	func detectedFace(request: VNRequest, error: Error?) {
		guard
			let results = request.results as? [VNFaceObservation],
			let result = results.first else {
				faceView.clear()
				return
		}
		
		updateFaceView(for: result)
	}
}

