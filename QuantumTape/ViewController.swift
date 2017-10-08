//
//  ViewController.swift
//  QuantumTape
//
//  Created by Michael Jay Abalos on 08/10/2017.
//  Copyright © 2017 Michael Jay Abalos. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //began touch
        
        if dotNodes.count >= 2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
                
            //hittest is a location of a point in the real world from our scene
            
            if let hitTestResult = hitTestResults.first{
                addDot(at:hitTestResult)
            }
                
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        let dotNode = SCNNode.init(geometry: dotGeometry)
        dotNode.position = SCNVector3.init(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2{
            calculate()
        }
        
    }
    
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print("start = \(start)")
        print("end = \(end)")
        
        let A = end.position.x - start.position.x
        let B = end.position.y - start.position.y
        let C = end.position.z - start.position.z
        
        let D = sqrt(pow(A, 2) + pow(B, 2) + pow(C, 2))
        print("distance = \(abs(D))")
        updateText(text: "\(abs(D))", atPosition: end.position)
        
    }
    func updateText(text: String, atPosition position: SCNVector3)  {
        
        textNode.removeFromParentNode()
        let textGeometry = SCNText.init(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        textNode = SCNNode.init(geometry: textGeometry)
        textNode.position = SCNVector3.init(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3.init(0.001, 0.001, 0.001)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
