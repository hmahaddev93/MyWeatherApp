//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by Khateeb H. on 12/23/21.
//

import UIKit
import MapKit

final class WeatherMapViewController: UIViewController {

    @IBOutlet weak var mapView: MapViewWithZoom!
    let locationManager = CLLocationManager()
    private let viewModel = WeatherMapViewModel()
    private var isLoading: Bool = false
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        addReloadButton()
    }
    
    private func reloadStations(stations:[StationAnnotation]) {
        mapView.removeAnnotations(mapView.annotations)
        for station in stations {
            mapView.addAnnotation(station)
        }
    }
    
    private func addReloadButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        button.addTarget(self, action:#selector(onReload(sender:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = .black
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.setRightBarButton(barButton, animated: false)
        self.isLoading = false
    }
    
    private func addReloadingActivityIndicator() {
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        activityIndicator.startAnimating()
        self.isLoading = true
    }
    
    @objc func onReload(sender: Any) {
        reload()
    }
    
    private func reload() {
        if isLoading {
            return
        }
        self.addReloadingActivityIndicator()
        viewModel.spots(by: self.mapView.newBounds.firstBound.coordinate, maxLocation: self.mapView.newBounds.secondBound.coordinate, mapZoomLevel: self.mapView.zoomLevel) { [unowned self] result in
            switch result {

            case .success(let stations):
                DispatchQueue.main.async {
                    self.reloadStations(stations: stations)
                    self.addReloadButton()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.addReloadButton()
                }
            }
        }
    }
    
}

extension WeatherMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        print(location.coordinate)
        self.mapView.centerToLocation(location)
    }
}

extension WeatherMapViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        reload()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "WindDirection"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        let station = annotation as! StationAnnotation
        // rotating arrow by wind direction angle
        if let windDirection = station.windDirectionAngle {
            anView!.image = UIImage(named: "right_arrow")?.rotate(radians: .pi * (windDirection/180.0))
        } else {
            anView!.image = UIImage(named: "right_arrow")
        }
        
        return anView
    }
}

