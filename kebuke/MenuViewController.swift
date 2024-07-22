//
//  MenuViewController.swift
//  kebuke
//
//  Created by 黃翊唐 on 2024/7/21.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var itemArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source and delegate
        tableView.dataSource = self
        tableView.delegate = self

        fetchMenuItems()
    }
    
    func fetchMenuItems() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        guard let url = URL(string: Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([Item].self, from: data)
                DispatchQueue.main.async {
                    self.itemArray = decodedData
                    self.tableView.reloadData()
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    print(decodedData[0])
                }
            } catch {
                print("Error decoding data: \(error)")
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56 // Set your desired height here
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuTableViewCell
        
        let item = itemArray[indexPath.row]
        cell.nameLabel.text = item.name
        cell.descriptionLabel.text = item.description
        cell.priceLabel.text = "M: $\(item.price.m), L: $\(item.price.l)"
        if let imageUrl = URL(string: item.imageUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        cell.imgView.image = UIImage(data: data)
                    }
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = itemArray[indexPath.row]
        performSegue(withIdentifier: "showOptions", sender: selectedItem)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOptions" {
            let optionsVC = segue.destination as? OptionsViewController
            if let row = tableView.indexPathForSelectedRow?.row{
                optionsVC?.selectedItem = itemArray[row]
            }
        }
    }
}
