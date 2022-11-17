//
//  ViewController.swift
//  WeatherKrasikov
//
//  Created by Антон Красиков on 15.11.2022.
//

import UIKit
import Alamofire
import SwiftyJSON


class CitiesList: UITableViewController {

    var cities: [City] = []
    let url = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&aqi=no"
    
    //количество ячеек
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    //создает ячейку
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCity", for: indexPath) as! CityCell
        cell.nameCity.text = cities[indexPath.row].name
        cell.tempCity.text = String(cities[indexPath.row].temp_c)
        
        return cell
    }
    
    @IBAction func addCityAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "add new City", message: "enter city", preferredStyle: .alert)
        alertController.addTextField{textField in textField.placeholder = "City name"}
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard alertController.textFields![0].text != nil else { return }
            let name = alertController.textFields![0].text!
            self.requestData(city: name)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func requestData(city: String){
        let params = ["q": city]
        AF.request(url, method: .get, parameters: params).response {[self] response in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value!)
                let name = json["location"]["name"].stringValue
                let temp_c = json["current"]["temp_c"].doubleValue
                let country = json["location"]["country"].stringValue
                
                guard !checkCity(name: name) else { return alertController(message: "City already added" )}
                
                cities.append(City(name: name, temp_c: temp_c, country: country))
                tableView.reloadData()
            case .failure(let error):
                print(error)
                alertController(message: "Error request")
            }
        }
    }
    
    func checkCity(name: String) -> Bool {
        cities.contains { list in
            return list.name == name
        }
    }
    
    func alertController(message: String){
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        
    }
}

