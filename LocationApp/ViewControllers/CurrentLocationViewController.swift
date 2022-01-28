//
//  CurrentLocationViewController.swift
//  LocationApp
//
//  Created by Данил on 19.01.2022.
//

import UIKit
import CoreLocation
/*
 Для работы необходимо подклбчить делегат, запросить доступ к геолокации и в info.plist добавить ключ
 NSLocationWhenInUseUsageDescription
 */
class CurrentLocationViewController: UIViewController {

    //MARK: UIElements
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message"
        label.textAlignment = .center
        return label
    }()
    // Простой текст, в будущем не будет взаимодействия
    let latitudeTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Latitude:"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Простой текст, в будущем не будет взаимодействия
    let longitudeTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Longitude:"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Label, который в будущем будет изменяться(значение)
    let longitudeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "999"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Label, который в будущем будет изменяться(значение)
    let latitudeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "999"
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Template address"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tagButton: UIButton = {
        let button = UIButton()
        button.setTitle("Tag", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let getButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get my location", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // setup user interface
        setupActions() // add actions to buttons
    }
    
    //MARK: Настройка UI элементов
    private func setupUI() {
        
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
//        verticalStack.backgroundColor = .gray
        view.addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            verticalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -16),
            verticalStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
        verticalStack.addArrangedSubview(messageLabel)
        
        let latitudeStack = UIStackView()
        latitudeStack.distribution = .equalSpacing
        latitudeStack.addArrangedSubview(latitudeTextLabel)
        latitudeStack.addArrangedSubview(latitudeValueLabel)
        
        verticalStack.addArrangedSubview(latitudeStack)
        
        let longitudeStack = UIStackView()
        longitudeStack.distribution = .equalSpacing
        longitudeStack.addArrangedSubview(longitudeTextLabel)
        longitudeStack.addArrangedSubview(longitudeValueLabel)
        
        verticalStack.addArrangedSubview(longitudeStack)
        verticalStack.addArrangedSubview(addressLabel)
        verticalStack.addArrangedSubview(tagButton)
        
        view.addSubview(getButton)
        NSLayoutConstraint.activate([
            getButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            getButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            getButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            getButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
        
    }
    
    //MARK: Actions
    
    private func setupActions() {
        getButton.addTarget(self, action: #selector(getAction), for: .touchUpInside)
    }
    
    @objc private func getAction() {
        let authStatus = locationManager.authorizationStatus // нужно чтобы получить доступ к геолокации
        // также необходимо добавить ключ в info.plist
        if authStatus == .denied || authStatus == .restricted {
          showLocationServicesDeniedAlert()
          return
        }
        if authStatus == .notDetermined {
          locationManager.requestWhenInUseAuthorization()
          return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    //MARK: CLLocationLogic
    
    func showLocationServicesDeniedAlert() {
      let alert = UIAlertController(title: "Геолокация недоступна", message: "Перейдите в настройки и разрешите доступ к геолокации", preferredStyle: .alert)

      let okAction = UIAlertAction(title: "OK",style: .default,handler: nil)
      alert.addAction(okAction)

      present(alert, animated: true, completion: nil)
    }
    
    private func updateLabels() {
        if let location = location {
            longitudeValueLabel.text = String(format: "%.8f", location.coordinate.longitude)
            // .8 значит что нужно 8 значений после запятой
            latitudeValueLabel.text = String(format: "%.8f", location.coordinate.latitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeValueLabel.text = ""
            longitudeValueLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
        }
    }
    
}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            updateLabels()
        }
        guard let newLocation = locations.last else {return}
        location = newLocation
        print(newLocation)
    }
}
