//
//  ViewController.swift
//  ARcade
//
//  Created by Lucas Fernandez Nicolau on 13/02/20.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()

        set(text: "Score: 10", for: boxAnchor.scoreLabel)
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
    }
}
