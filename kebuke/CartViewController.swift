//
//  CartViewController.swift
//  kebuke
//
//  Created by 黃翊唐 on 2024/7/21.
//

import UIKit

struct drink: Codable {
    let name: String
    let size: String
    let iceLevel: String
    let sugarLevel: String
    let topping: String
    let price: Int
}

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var cart: [drink] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the data source and delegate
        tableView.dataSource = self
        tableView.delegate = self

        fetchMenuItems()
    }
    
    func fetchMenuItems() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        guard let url = URL(string: Bundle.main.object(forInfoDictionaryKey: "CART_API_URL") as! String) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([drink].self, from: data)
                DispatchQueue.main.async {
                    self.cart = decodedData
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
        return cart.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // Set your desired height here
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartTableViewCell
        
        let item = cart[indexPath.row]
        cell.nameLabel.text = "\(item.name)（\(item.size)）"
        cell.ISTLabel.text = "\(item.iceLevel)\(item.sugarLevel)+\(item.topping)"
        cell.priceLabel.text = "$\(item.price)"
        
        return cell
    }
}
