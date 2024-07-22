//
//  OptionsViewController.swift
//  kebuke
//
//  Created by 黃翊唐 on 2024/7/21.
//

import UIKit

class OptionsViewController: UIViewController {
    
    var selectedItem: Item?
    var test: String?
    var selectedIceLevel: String = "正常"
    var selectedSugarLevel: String = "正常"
    var selectedSize: String = "中杯"
    var selectedTopping: String = "無"
    var totalPrice: Int = 0
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        
        if let item = selectedItem {
            itemNameLabel.text = item.name
            itemDescriptionLabel.text = item.description
            itemPriceLabel.text = "M: $\(item.price.m) L: $\(item.price.l)"
            if let imageUrl = URL(string: item.imageUrl) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            self.itemImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
            totalPrice = selectedItem?.price.m ?? 0
            priceLabel.text = "$\(totalPrice)"
        }
    }
    
    // MARK: - Actions
    @IBAction func sizeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSize = "中杯"
            totalPrice = selectedItem?.price.m ?? 0
        case 1:
            selectedSize = "大杯"
            totalPrice = selectedItem?.price.l ?? 0
        default:
            break
        }
        if selectedTopping != "無" {
            totalPrice += 10
        }
        priceLabel.text = "$\(totalPrice)"
    }

    @IBAction func iceChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedIceLevel = "正常"
        case 1:
            selectedIceLevel = "少冰"
        case 2:
            selectedIceLevel = "微冰"
        case 3:
            selectedIceLevel = "去冰"
        default:
            break
        }
    }

    @IBAction func sugarChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSugarLevel = "正常"
        case 1:
            selectedSugarLevel = "少糖"
        case 2:
            selectedSugarLevel = "半糖"
        case 3:
            selectedSugarLevel = "微糖"
        case 4:
            selectedSugarLevel = "無糖"
        default:
            break
        }
    }

    @IBAction func toppingChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedTopping = "無"
        case 1:
            selectedTopping = "白玉"
        case 2:
            selectedTopping = "水玉"
        case 3:
            selectedTopping = "菓玉"
        default:
            break
        }
        if selectedSize == "中杯" {
            totalPrice = (selectedItem?.price.m ?? 0)
        }
        else {
            totalPrice = (selectedItem?.price.l ?? 0)
        }
        if selectedTopping != "無" {
            totalPrice += 10
        }
        priceLabel.text = "$\(totalPrice)"
    }
    
    @IBAction func addToCartButtonTapped(_ sender: UIButton) {
        guard let selectedItem = selectedItem else {
            print("Missing data.")
            return
        }
        sendPostRequest(size: selectedSize, itemName: selectedItem.name, iceLevel: selectedIceLevel, sugarLevel: selectedSugarLevel, topping: selectedTopping, price: totalPrice)
        
        self.navigationController?.popViewController(animated: true)
    }

    func sendPostRequest(size: String, itemName: String, iceLevel: String, sugarLevel: String, topping: String, price: Int) {
        self.addButton.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        guard let url = URL(string: Bundle.main.object(forInfoDictionaryKey: "CART_API_URL") as! String) else {
            print("Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let postData: [String: Any] = [
                "size": size,
                "itemName": itemName,
                "iceLevel": iceLevel,
                "sugarLevel": sugarLevel,
                "topping": topping,
                "price": price
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON data: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                self.addButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }

        task.resume()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
