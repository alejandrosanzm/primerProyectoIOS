//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import CoreLocation
import Alamofire
import SwiftyJSON
import UIKit


class WeatherViewController: UIViewController, CLLocationManagerDelegate ,changeCityViewDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"

    //TODO: Declare instance variables here
    var locationManager = CLLocationManager()
    var currentData: WeatherDataModel?

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String) {
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { (result) in result.result.ifSuccess {
                if let data = result.data {
                    self.updateWeatherData(response: data)
                }
            }
        }
    }

    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(response: Data) {
        let responseJSON = try! JSON(data: response)
        currentData = WeatherDataModel(city: responseJSON["name"].stringValue, temperature: (responseJSON["main"]["temp"].doubleValue - 273), condition: responseJSON["weather"][0]["id"].intValue)
        updateUIWithWeatherData()
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        if let cCondition = currentData?.condition, let cCity = currentData?.city, let cTemperature = currentData?.temperature {
            weatherIcon.image = UIImage(named: cCondition)
            cityLabel.text = cCity
            temperatureLabel.text = "\(Int(cTemperature))" + "º"
        }
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myLocation = locations[locations.count - 1]
        guard let location = locationManager.location else { return }
        
        if myLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let url = WEATHER_URL + "?lat=\(latitude)&lon=\(longitude)&appid=\(APP_ID)"
            getWeatherData(url: url)
        }
    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        cityLabel.text = "Error en el gps"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(cit: String)  {
        let url = WEATHER_URL + "?q=\(cit)&appid=\(APP_ID)"
        getWeatherData(url: url)
    }

    //Write the PrepareForSegue Method here
    override
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationSegue = segue.destination as? ChangeCityViewController {
            destinationSegue.delegate = self
        }
    }
}
