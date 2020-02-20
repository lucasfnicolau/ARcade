//
//  ViewController.swift
//  ARcade
//
//  Created by Lucas Fernandez Nicolau on 13/02/20.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ArcadeViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    var configuration: ARWorldTrackingConfiguration?
    var anyCancellables: [AnyCancellable] = []
    let arcadeAnchor = try! Experience.loadArcade()
    var levelsAnchors = [
        try! Experience.loadLevel0()
    ]
    var session: ARSession{
        return arView.session
    }
    var currentState: GameState = .arcade
    var score = 0
    var remainingTime = 60
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.session.delegate = self

        // Add the box anchor to the scene
        arView.scene.anchors.append(arcadeAnchor)

        arcadeAnchor.actions.allActions.forEach { (action) in
            action.onAction = changeGameState(basedOn:)
        }
    }

    func changeGameState(basedOn entity: Entity?) {
        switch entity {
        case arcadeAnchor.blueButton,
             arcadeAnchor.greenButton:
            currentState = .alienXUSLevel0
            arView.scene.anchors.append(levelsAnchors[0])
            startTimer()
        default:
            break
        }
    }

    func startTimer() {
        set(text: "\(remainingTime)s", for: levelsAnchors[0].timerLabel)
        timer = Timer(timeInterval: 1, repeats: true, block: { (timer) in
            self.remainingTime -= 1
            set(text: "\(self.remainingTime)s", for: self.levelsAnchors[0].timerLabel)

            if self.remainingTime <= 0 {
                //
            }
        })

        timer?.fire()
    }
}
