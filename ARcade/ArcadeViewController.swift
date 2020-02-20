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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
//        arView.addGestureRecognizer(tap)

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
//            levelsAnchors[0].bullet?.scale = SIMD3(0, 0, 0)
            set(text: "Score: 0", for: levelsAnchors[0].scoreLabel)
//            levelsAnchors[0].actions.fakesDeath.onAction = fakesDeath(_:)
//            levelsAnchors[0].actions.realDeath.onAction = realDeath(_:)
        default:
            break
        }
    }

    func fakesDeath(_ entity: Entity?) {
        set(text: "Game Over", for: levelsAnchors[0].scoreLabel)
    }

    func realDeath(_ entity: Entity?) {
        set(text: "\(score + 10)", for: levelsAnchors[0].scoreLabel)
    }

    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)

        // Attempt to find a 3D location on a horizontal surface underneath the user's touch location.
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
//        if let firstResult = results.first {
//            // Add an ARAnchor at the touch location with a special name you check later in `session(_:didAdd:)`.
//            let anchor = ARAnchor(name: Anchor.placingObject.rawValue, transform: firstResult.worldTransform)
//            arView.session.add(anchor: anchor)
//
//        } else {
//            print("Warning: Object placement failed.")
//        }

        let cameraAnchor = ARAnchor(name: Anchor.camera.rawValue, transform: session.currentFrame!.camera.transform)
        session.add(anchor: cameraAnchor)
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == Anchor.camera.rawValue {
                let anchorEntity = AnchorEntity(anchor: anchor)
                //                 potatoAnchor.potato?.components.set(CollisionComponent(shapes: [.generateCapsule(height: 0.15, radius: 0.03)], mode: .trigger, filter: .sensor))

                //                arView.scene.subscribe(to: CollisionEvents.Began.self) { (event) in
                //                    print("Colidiu \(event.entityA) com \(event.entityB)")
                //                }.store(in: &collidedObjects)

                //                if let potato = (potatoAnchor.potato as? Entity & HasPhysics) {
                //                    potato.physicsBody?.isContinuousCollisionDetectionEnabled = true
                //                }

//                let radius: Float = 0.5
//                let bullet = ModelEntity(mesh: MeshResource.generateSphere(
//                    radius: radius),
//                                         materials: [SimpleMaterial(color: .black, isMetallic: true)]
//                )

//                guard let bullet = levelsAnchors[0].bullet?.clone(recursive: true) else {
//                    return
//                }
//                bullet.scale = SIMD3(1, 1, 1)
//
//                //Setando a ancora dela
//                anchorEntity.addChild(bullet)
//                bullet.position = [0, 0, -1]

                //Colocando a ancora com a bolinha na cena
                arView.scene.addAnchor(anchorEntity)

//                levelsAnchors[0].notifications.shoot.post()
//                bullet.addForce(SIMD3(20, 20, 20), relativeTo: bullet)
            }
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]

        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")

        DispatchQueue.main.async {
            // Present the error that occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func resetTracking() {
        guard let configuration = arView.session.configuration else { print("A configuration is required"); return }
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

class Bullet: Entity, HasModel, HasAnchoring, HasCollision {

    required init(color: UIColor) {
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateSphere(radius: 1),
            materials: [SimpleMaterial(
                color: color,
                isMetallic: false)
            ]
        )
    }

    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }

    required init() {
        fatalError("init() has not been implemented")
    }
}
