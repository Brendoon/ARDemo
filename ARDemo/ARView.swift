//
//  ARView.swift
//  ARDemo
//
//  Created by Brendoon Ryos on 24/05/17.
//  Copyright © 2017 Brendoon Ryos. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import CoreMotion

class ARView: UIView {

    // Camera properties
    var cameraSession: AVCaptureSession?
    var cameraLayer: AVCaptureVideoPreviewLayer?
    var cameraView: UIView!
    
    // 3D properties
    var sceneView: SCNView!
    
    // Accelerometer properties
    var motionQueue : OperationQueue!
    var motionManager: CMMotionManager!
    
    // Constructor with frame 
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // Contructor with coder
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // Constructor with no arguments
    convenience public init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
    }
    
    // @private Our initialization code
    func setup() {
        
        // Setup camera
        setupCamera()
        
        // Setup 3D scene
        setup3D()
        
        // Setup accelerometer
        setupAccelerometer()
        
    }
    
    // @private Set up the camera layer
    func setupCamera() {
        
        // Create capture session
        cameraSession = AVCaptureSession()
        
        // Get camera
        guard let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            return
        }
        
        // Create input from camera
        guard let cameraInput = try? AVCaptureDeviceInput(device: backCamera) else {
            return
        }
        
        // Add input to the camera session
        if cameraSession!.canAddInput(cameraInput) {
            cameraSession?.addInput(cameraInput)
        }
        
        // Create camera view
        cameraView = UIView()
        self.addSubview(cameraView)
        
        // Create output layer
        cameraLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        cameraLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView.layer.addSublayer(cameraLayer!)
        
        // Start the camera session
        cameraSession?.startRunning()
        
    }
    
    func stop3D() {
        
        sceneView.scene = nil
        
    }
    
    // @private Set up the 3D view
    func setup3D() {
        
        // Create 3D view
        sceneView = SCNView()
        sceneView.frame = self.bounds
        sceneView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        sceneView.backgroundColor = UIColor.clear
        self.addSubview(sceneView)
        
        // Create 3D scene
        sceneView.scene = SCNScene(named: "Coin.scn")
        
        // Create 3D camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Add camera to scene
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        // Set camera as render target
        sceneView.pointOfView = cameraNode
        
        // (Demo) Create pyramid
        
        //let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        //var boxNode = SCNNode(geometry: box)
        //box.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "img_crate_diffuse")
        //box.firstMaterial?.normal.contents = #imageLiteral(resourceName: "img_crate_normal")
        
        
        //driveLeftAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-2.0, 0, 0), duration: 1.0))
        
        //var boxNode = (sceneView.scene?.rootNode.childNode(withName: "Coin", recursively: true))!
        //boxNode.position = SCNVector3(x: 0, y: 0, z: -10)
        //boxNode.runAction(SCNAction.rotateByEuler)
        
        //boxNode.runAction(SCNAction.repeat(SCNAction.rotateTo(x: 0, y: CGFloat(Double.pi / 2), z: 0, duration: 1.0, usesShortestUnitArc: true), count: 1000))
        
        //boxNode.runAction(SCNAction.repeatForever(SCNAction.rotateTo(x: 0, y: CGFloat(Double.pi / 2), z: 0, duration: 1.0, usesShortestUnitArc: true)))
        //sceneView.scene?.rootNode.addChildNode(boxNode)
        
        
        /*let pyramid = SCNPyramid(width: 1, height: 1, length: 1)
        let pyramidNode = SCNNode(geometry: pyramid)
        pyramid.firstMaterial?.diffuse.contents = UIColor.green
        pyramidNode.position = SCNVector3(x: 0, y: 0, z: -10)
        sceneView.scene?.rootNode.addChildNode(pyramidNode)*/
        
        // (Demo) Create sphere
        /*let sphere = SCNSphere(radius: 1)
        let sphereNode = SCNNode(geometry: sphere)
        sphere.firstMaterial?.lightingModel = .blinn
        sphere.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "img_ball_diffuse")
        sphere.firstMaterial?.normal.contents = #imageLiteral(resourceName: "img_ball_normal")
        sphere.firstMaterial?.emission.contents = #imageLiteral(resourceName: "img_ball_emission")
        sphere.firstMaterial?.reflective.contents = self.cameraLayer?.contents
        sphereNode.position = SCNVector3(x: -10, y: -10, z: 0)
        sphereNode.runAction(SCNAction.repeatForever(SCNAction.rotateTo(x: 0, y: 0, z: CGFloat(Double.pi), duration: 1.0, usesShortestUnitArc: true)))
        sceneView.scene?.rootNode.addChildNode(sphereNode)*/
        
    }
    
    // @private Set up the accelerometer
    func setupAccelerometer() {
        
        // Create operation queue for our updates to be called on
        motionQueue = OperationQueue()
        motionQueue.maxConcurrentOperationCount = 1
        
        // Create instance of motion manager
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1 / 60
        
        // Start receiving motion updates
        let ref = CMAttitudeReferenceFrame.xMagneticNorthZVertical
        motionManager.startDeviceMotionUpdates(using: ref, to: motionQueue){ [weak self]
            (motionData, error) in
            
            // Stop if error
            if error != nil || motionData == nil {
                return
            }
            
            // Update 3D camera's rotation
            let deviceQuarternion = motionData!.attitude.quaternion
            
            self?.sceneView.pointOfView?.orientation = SCNQuaternion(x: Float(deviceQuarternion.x), y: Float(deviceQuarternion.y), z: Float(deviceQuarternion.z), w: Float(deviceQuarternion.w))
            
            
        }
        
    }
    
    // Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure camera layer is filling the whole view
        cameraView.frame = self.bounds
        cameraLayer?.frame = cameraView.bounds
        
    }

}
