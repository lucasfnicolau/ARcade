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
    
    @IBOutlet var arView: ARcadeView!
    var configuration: ARWorldTrackingConfiguration?
    var anyCancellables: [AnyCancellable] = []
    var arcadeAnchor: Experience.Arcade = try! Experience.loadArcade()
    var levelsAnchors: [Experience.Level0] = [
        try! Experience.loadLevel0()
    ]
    var session: ARSession{
        return arView.session
    }
    var currentState: GameState = .arcade
    var remainingTime = 60
    var kills = 0
    var tutorialView: UIView?
    var tutorialTextView: UITextView?
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

    func showTutorial() {
        tutorialTextView = UITextView(frame: .zero)

        guard let tutorialTextView = tutorialTextView else { return }
        tutorialTextView.translatesAutoresizingMaskIntoConstraints = false

        arView.addSubview(tutorialTextView)

        tutorialTextView.text = """
        You have up to 60s to save the Earth!

        Kill at least 12 aliens by tapping them twice and keep humanity alive!!!

        Good luck :D
        """
        tutorialTextView.textColor = .yellow
        tutorialTextView.textAlignment = .center
        tutorialTextView.font = UIFont(name: Font.pressStart.rawValue, size: 24)!
        tutorialTextView.isEditable = false
        tutorialTextView.isSelectable = false
        tutorialTextView.backgroundColor = .black
        tutorialTextView.layer.cornerRadius = 35

        NSLayoutConstraint.activate([
            tutorialTextView.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            tutorialTextView.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            tutorialTextView.widthAnchor.constraint(equalTo: arView.widthAnchor, multiplier: 0.8),
            tutorialTextView.heightAnchor.constraint(equalToConstant: 340),
        ])

        UIView.animate(withDuration: 3, delay: 5, animations: {
            tutorialTextView.alpha = 0
        }) { (_) in
            tutorialTextView.removeFromSuperview()
        }
    }

    func changeGameState(basedOn entity: Entity?) {
        switch entity {
        case arcadeAnchor.blueButton,
             arcadeAnchor.greenButton:
            showTutorial()
            currentState = .alienXUSLevel0
            arView.scene.anchors.append(levelsAnchors[0])
            levelsAnchors[0].actions.allActions.forEach { (action) in
                action.onAction = handleTapOnEntity(_:)
            }
            startTimer()
        default:
            break
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.remainingTime -= 1

            if self.remainingTime <= 0 {
                self.levelsAnchors[0].notifications.explosion.post()
                self.timer?.invalidate()
            }
        })

        timer?.fire()
    }

    func handleTapOnEntity(_ entity: Entity?) {
        kills += 1

        if kills >= 12 {
            levelsAnchors[0].notifications.victory.post()
        }
    }
}
