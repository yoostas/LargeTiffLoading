//
//  ViewController.swift
//  LargeTiffLoading
//
//  Created by Stanislav's MacBook Pro on 16.07.2020.
//  Copyright © 2020 Stanislav's MacBook Pro. All rights reserved.
//

import UIKit

class UncompressedImageListViewController: UITableViewController {
    var model = UncompressedImageListViewModel()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setup()
    }
    
    func setup() {
        self.model.delegate = self
        self.model.setup()
        self.tableView.tableFooterView = UIView()
    }
}

// MARK: tableview delegate and datasource
extension UncompressedImageListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return self.model.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageCell.self), for: indexPath) as? ImageCell else {
            fatalError("ImageCell not found")
        }
        
//        let imageVm = self.model.imageAtIndex(indexPath.row)
//        cell.setup(viewModel: imageVm)
        
        let model = self.model.images[indexPath.row]
        cell.largeImageView.image = model.image
        switch model.state {
        case .cached:
            cell.activityIndicator.stopAnimating()
        case .new, .resized:
            cell.activityIndicator.startAnimating()
            if !tableView.isDragging && !tableView.isDecelerating {
                self.model.startOperations(for: model, at: indexPath)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(self.model.heightForRow(at: indexPath.row))
    }
    
}

 //MARK: ScrollView delegates handler

extension UncompressedImageListViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.model.suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let indexArray = self.tableView.indexPathsForVisibleRows {
                self.model.loadImagesForOnscreenCells(pathsArray: indexArray)
                self.model.resumeAllOperations()
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexArray = self.tableView.indexPathsForVisibleRows {
            self.model.loadImagesForOnscreenCells(pathsArray: indexArray)
            self.model.resumeAllOperations()
        }
    }
}
// MARK: some staff for alerts

extension UncompressedImageListViewController{
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: NSLocalizedString("warning.ok.title", comment: ""), style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: viewmodel delegate methods

extension UncompressedImageListViewController: UncompressedImageListViewModelDelegate {
    
    func sendAlertMessage(message: String) {
        self.showAlertWith(title: NSLocalizedString("warning.title", comment: ""), message: message)
    }
    

    func showActivity() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivity() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func reloadTable() {
         DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reloadRows(indexPath:IndexPath) {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

