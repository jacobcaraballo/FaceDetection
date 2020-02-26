import Foundation
import UIKit

class ImageSelectionViewController: UIViewController {
	let tableView = UITableView()
	var owner: FaceDetectionViewController!
	let imageNames = [ "None", "Ape", "Crying", "Kim", "LuL", "Party", "Sparta", "Trump", "Will" ]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layoutTableView()
	}
	
	func layoutTableView() {
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 100
		view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			
			tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
			tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			
			])
		
	}
	
}


extension ImageSelectionViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageNames.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
		if cell == nil {
			cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
		}
		
		let imageName = imageNames[indexPath.row]
		cell.detailTextLabel?.text = imageName
		cell.imageView?.image = UIImage(named: imageName)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let imageName = imageNames[indexPath.row]
		if imageName == "None" {
			owner.currentImage = nil
		} else {
			owner.currentImage = UIImage(named: imageName)!
		}
		dismiss(animated: true, completion: nil)
	}
	
}

