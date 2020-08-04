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
        
        let imageVm = self.model.imageAtIndex(indexPath.row)
        cell.setup(viewModel: imageVm)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(self.model.heightForRow(at: indexPath.row))
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
}

