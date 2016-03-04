//
//  ViewController.swift
//  MarcaRutaEnMapa
//
//  Created by Jose Luis Garcia Dueñas on 1/3/16.
//  Copyright © 2016 Jose Luis Garcia Dueñas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


//extension Double{
//    
//    var roundedTwoDigit:Double{
//        
//        return Double(round(100*self)/100)
//        
//    }
//}

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var Mapa: MKMapView!
    private let manejador = CLLocationManager()
    var metrosIniciales: Double = 0
    var metros: Double = 0
    var LecturaPrimera: CLLocation = CLLocation()
    var LectuarActual:CLLocation = CLLocation()
    var TotalMetros:Double = Double()
    var delta:Double = 0.01
    var MilongtudDelta:Double = 0.01
    var MilatitudDelta:Double = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest // Exactitud : la mejor
        manejador.requestWhenInUseAuthorization()
        
        let pin = MKPointAnnotation()
        pin.title = "Mi Casa"
        pin.subtitle = "Madrid"
        Mapa.addAnnotation(pin)
        Mapa.mapType = MKMapType.Satellite
        let location = "Cupertino, CA"
        let geocoder:CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks, error) -> Void in

            let placemark:CLPlacemark = placemarks![0]
            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
            let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = coordinates


            self.Mapa.centerCoordinate = coordinates
            self.LecturaPrimera = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manejador.startUpdatingLocation()
            Mapa.showsUserLocation = true
            metrosIniciales = distanceInMetersFrom()
        } else {
            manejador.stopUpdatingLocation()
            Mapa.showsUserLocation = false
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: MilatitudDelta, longitudeDelta: MilongtudDelta))
        
        let span = MKCoordinateSpanMake(location.coordinate.latitude , location.coordinate.longitude)
        print("\nspan:\(span.latitudeDelta) \(span.longitudeDelta) \ndelta: \(delta)")

        self.Mapa.setRegion(region, animated: true)
        
       
        LectuarActual = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

      //  metros = calculateDisatnceBetweenTwoLocations(LecturaPrimera, destination: LectuarActual)
        if metros > 0 &&  metrosIniciales == 0 {
            metrosIniciales = distanceInMetersFrom()
        }
        metros = distanceInMetersFrom()
        //print (String(format: "%.2f", metros))
        if abs( metrosIniciales - metros) < 50 {
            } else {
                metrosIniciales = metros
                TotalMetros += metros
                colocaAnotacion("\(TotalMetros)")
                LectuarActual = LecturaPrimera
            
        }
    }

    func colocaAnotacion (metros: String) {
        var punto = CLLocationCoordinate2D()
        punto.latitude = LectuarActual.coordinate.latitude
        punto.longitude = LectuarActual.coordinate.longitude
        
        let pin = MKPointAnnotation()
        pin.title = "lat:" + "\(punto.latitude)" + " lon:" + "\(punto.longitude)"
        pin.subtitle = "Dist:" + metros
        pin.coordinate = punto
        Mapa.addAnnotation(pin)

    }
    
//    func calculateDisatnceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double{
//        
//        let distanceMeters = source.distanceFromLocation(destination)
//        let distanceKM = distanceMeters / 1000
//        let roundedTwoDigit = distanceKM.roundedTwoDigit
//        print(distanceMeters)
//        print(distanceKM)
//        print(roundedTwoDigit)
//        return roundedTwoDigit
//        
//        
//    }
    
    
    @IBAction func Zoomout() {
        MilongtudDelta = Mapa.region.span.longitudeDelta*2
        MilatitudDelta = Mapa.region.span.latitudeDelta*2
        let span = MKCoordinateSpan(latitudeDelta: MilatitudDelta, longitudeDelta: MilongtudDelta)
        
        let region = MKCoordinateRegion(center: Mapa.region.center, span: span)
        Mapa.setRegion(region, animated: true)
    }
    
    @IBAction func ZoomIn() {
        MilongtudDelta = Mapa.region.span.longitudeDelta/2
        MilatitudDelta = Mapa.region.span.latitudeDelta/2

        let span = MKCoordinateSpan(latitudeDelta: MilatitudDelta, longitudeDelta: MilongtudDelta)
        let region = MKCoordinateRegion(center: Mapa.region.center, span: span)
        Mapa.setRegion(region, animated: true)

    }
    
    func distanceInMetersFrom() -> CLLocationDistance {
        let firstLoc = CLLocation(latitude: LecturaPrimera.coordinate.longitude, longitude: LecturaPrimera.coordinate.longitude)
        let secondLoc = CLLocation(latitude: LectuarActual.coordinate.longitude, longitude: LectuarActual.coordinate.longitude)
        return firstLoc.distanceFromLocation(secondLoc)
    }
    
    
    
    @IBAction func VistaNormal(sender: UIBarButtonItem) {
        Mapa.mapType = MKMapType.Standard
    }
    
    @IBAction func VistaSatelite(sender: UIBarButtonItem) {
        Mapa.mapType = MKMapType.Satellite
    }
    
    @IBAction func VistaHibrido(sender: UIBarButtonItem) {
        Mapa.mapType = MKMapType.Hybrid
    }
    

}
