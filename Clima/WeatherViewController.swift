//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
   
    @IBOutlet weak var faren: UISwitch!
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "83849873bffe7bd0d7f36b5c9ba3d82a"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    @IBAction func `switch`(_ sender: UISwitch) {
        
        if sender.isOn  {
        
        }
    }
    
    
    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    //Delegate - Pulls locationManager from CoreLocation API. This ( = self) sets WeatherViewController class as a delegate of locationManager
        locationManager.delegate = self
        //the more accurate the more power drawn and longer the process takes
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //prompt for location data access
        //Have to add to plist as well
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        // getting weather data from Alamofire API.
                        //url of api, type/method of request (.get data), parameters API requries to get data
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                                        //reformt Any type to JSON type here using JSON() for response.result.value
                let weatherJSON: JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    

    func updateWeatherData(json: JSON) {
        //Get the JSON data - go to main - go to temp and get value
        //OPtional Binding with if else statement so we don't force unwrap temp result.
        let tempResult = json["main"]["temp"].doubleValue
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
            
        updateUIWithWeatherData()
            
        }
//        else {
//            cityLabel.text = "Weather Unavailable"
//        }
//    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //Adds locations data to CLLocation array. Pull the last entry as it will be most accurate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        //check to make sure locations are valid.
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
           
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        
        let params: [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
        
    }
    
    
    
}


