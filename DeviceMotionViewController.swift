//
//  DeviceMotionViewController.swift
//  Sensors
//
//  Created by Linda Cobb on 9/22/14.
//  Copyright (c) 2014 TimesToCome Mobile. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion



// rotation with bias removed along x, y, z
// calibrated magnetic field minus device's magnetic field - earth's field plus surrounding fields gives total magnetic field
// attitude - orientation of device in space
// gravity - acceleration in device's reference frame - earth's gravity plue device acceleration
// user acceleration - gravity plus device acceleration

class DeviceMotionViewController: UIViewController  
{
    
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    
    @IBOutlet var updateIntervalSlider: UISlider!
    @IBOutlet var updateIntervalLabel: UILabel!
    
    @IBOutlet var scaleSlider: UISlider!
    @IBOutlet var scaleLabel: UILabel!
    
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var motionType = 0      // attitude, rotation rate, device acceleration, magnetic field
    
    var motionManager: CMMotionManager!
    var stopUpdates = false
    
    
    required init( coder aDecoder: NSCoder ){
        super.init(coder: aDecoder)
    }
    
    
    convenience override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.init(nibName: nil, bundle: nil)
    }
    
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        motionManager = appDelegate.sharedManager
        
        updateIntervalSlider.value = 10.0
        updateIntervalLabel.text = NSString(format: "%.0lf", updateIntervalSlider.value)
        
        scaleSlider.value = 1.0
        scaleLabel.text = NSString(format: "%.1lf", scaleSlider.value)
        
    }
    
    
    
    @IBAction func selectionChanged(sender: UISegmentedControl) {
        
        motionType = segmentedControl.selectedSegmentIndex
        startUpdatesWithSliderValue(updateIntervalSlider.value)
    }
    
    
    @IBAction func intervalChanged(sender: UISlider){
        
        let interval = Int(sender.value)
        updateIntervalLabel.text = NSString(format: "%.0lf", updateIntervalSlider.value)
        
        startUpdatesWithSliderValue(updateIntervalSlider.value)
    }
    
    
    
    @IBAction func scaleChanged(sender: UISlider){
        
        let scale = sender.value
        
        scaleLabel.text = NSString(format: "%.0lf", scale)
        
    }
    
    
    
    @IBAction func stop(){
        
        stopUpdates = true
    }
    
    
    
    @IBAction func start(){
        
        stopUpdates = false
        startUpdatesWithSliderValue(updateIntervalSlider.value)
    }
    
    
    
    func startUpdatesWithSliderValue(sliderValue: NSNumber){
        
        
        let updateInterval = 1.0/Double(updateIntervalSlider.value) as NSTimeInterval
        motionManager.deviceMotionUpdateInterval = updateInterval
        let dataQueue = NSOperationQueue()
        
        
        if motionType < 3 {
            motionManager.startDeviceMotionUpdatesToQueue(dataQueue, withHandler: {
                        data, error in
            

            NSOperationQueue.mainQueue().addOperationWithBlock({
                        
                        if self.motionType == 0 {                    // attitude in degrees

                          
                    
                            // update labels
                            self.xLabel.text = NSString(format: "Roll: %.6lf' ", data.attitude.roll * 57.2957795)
                            self.yLabel.text = NSString(format: "Pitch: %.6lf' ", data.attitude.pitch * 57.2957795)
                            self.zLabel.text = NSString(format: "Yaw: %.6lf' ", data.attitude.yaw * 57.2956695)
                    
                    
                    
                        }else if self.motionType == 1 {          // rotation rate
                
                          
                        
                            // update labels
                            self.xLabel.text = NSString(format: "RotX: %.6lf' ", data.rotationRate.x * 57.2957795)
                            self.yLabel.text = NSString(format: "RotY: %.6lf' ", data.rotationRate.y * 57.2957795)
                            self.zLabel.text = NSString(format: "RotZ: %.6lf' ", data.rotationRate.z * 57.2956695)
                        
                            
                        }else if self.motionType == 2 {          // user accel
                            
                          
                            
                            // update labels
                            self.xLabel.text = NSString(format: "Acc x: %.6lf g", data.gravity.x)
                            self.yLabel.text = NSString(format: "Acc y: %.6lf g", data.gravity.y)
                            self.zLabel.text = NSString(format: "Acc z: %.6lf g", data.gravity.z)
                            
                
                        }
                
                
                    if ( self.stopUpdates ){
                        self.motionManager.stopDeviceMotionUpdates()
                        NSOperationQueue.mainQueue().cancelAllOperations()
                    }
                
                
                    })
                })
            
        }else if motionType == 3 {      // magnetic field
            
            motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXTrueNorthZVertical, toQueue: dataQueue, withHandler: {
                data, error in
                
                 NSOperationQueue.mainQueue().addOperationWithBlock({
                
                  
                
                    // update labels
                    self.xLabel.text = NSString(format: "X: %.6lf mTesla", data.magneticField.field.x)
                    self.yLabel.text = NSString(format: "Y: %.6lf mTesla", data.magneticField.field.y)
                    self.zLabel.text = NSString(format: "Z: %.6lf mTesla", data.magneticField.field.z)
                    
                    if ( self.stopUpdates ){
                        self.motionManager.stopDeviceMotionUpdates()
                        NSOperationQueue.mainQueue().cancelAllOperations()
                    }

                })
            })
        }
    }
    
    
    
    
    
    
    override func viewDidDisappear(animated: Bool){
        
        super.viewDidDisappear(animated)
        stop()
        
    }
    

    
}