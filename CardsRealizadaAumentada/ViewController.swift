//
//  ViewController.swift
//  CardsRealizadaAumentada
//
//  Created by André Brilho on 11/05/19.
//  Copyright © 2019 André Brilho. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var caliceNode:SCNNode?
    var jockerNode:SCNNode?
    var copasNode:SCNNode?
    var zapNode:SCNNode?
    var imagesNodes = [SCNNode]()
    var isJumping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        let caliceScene = SCNScene(named: "art.scnassets/diamond2.scn")
        let jockerScene = SCNScene(named: "art.scnassets/cor1.scn")
        let copasScene = SCNScene(named: "art.scnassets/diamond.scn")
        let zapScene = SCNScene(named: "art.scnassets/vulpix.scn")
        
        caliceNode = caliceScene?.rootNode
        jockerNode = jockerScene?.rootNode
        copasNode = copasScene?.rootNode
        zapNode = zapScene?.rootNode
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed:  "AR Resources", bundle: Bundle.main){
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            var shapeNode:SCNNode?
            
            if imageAnchor.referenceImage.name == "joker"{
                shapeNode = caliceNode
            }else if imageAnchor.referenceImage.name == "copas"{
                shapeNode = zapNode
            }else if imageAnchor.referenceImage.name == "calice" {
                shapeNode = copasNode
            }else {
                  shapeNode = jockerNode
            }
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            
            guard let shape = shapeNode else {return nil}
            node.addChildNode(shape)
            imagesNodes.append(node)
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imagesNodes.count == 2 {
            let positionOne = SCNVector3ToGLKVector3(imagesNodes[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imagesNodes[1].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            if distance < 0.10 {
                spinJump(node: imagesNodes[0])
                spinJump(node: imagesNodes[1])
                isJumping = true
            }else{
                isJumping = false
            }
        }
    }
    
    func spinJump(node:SCNNode){
        if isJumping { return }
        let shapeNode = node.childNodes[1]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        
        let down = up.reversed()
        let upDown = SCNAction.sequence([up, down])
        
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
        
    }
    
}
