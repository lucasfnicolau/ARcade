//
//  AlienXUSViewController.swift
//  ARcade
//
//  Created by Lucas Fernandez Nicolau on 19/02/20.
//

import UIKit
import RealityKit
import ARKit
import Combine

class AlienXUSViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    var configuration: ARWorldTrackingConfiguration?
    var anyCancellables: [AnyCancellable] = []
    let levelAnchor = try! Experience.loadLevel0()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arView.addGestureRecognizer(tap)

        arView.session.delegate = self

        set(text: "Score: 10", for: levelAnchor.scoreLabel)

        // Add the box anchor to the scene
        arView.scene.anchors.append(levelAnchor)
    }

    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)

        // Attempt to find a 3D location on a horizontal surface underneath the user's touch location.
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            // Add an ARAnchor at the touch location with a special name you check later in `session(_:didAdd:)`.
            let anchor = ARAnchor(name: Anchor.placingObject.rawValue, transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)

            //            guard let bullet = boxAnchor.bullet else { return }
            //            let bulletClone = bullet.clone(recursive: true)

            //            let anchorEntity = AnchorEntity(anchor: anchor)
            //            anchorEntity.addChild(bulletClone)
            //            arView.scene.anchors.append(anchorEntity)

        } else {
            print("Warning: Object placement failed.")
        }
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == Anchor.placingObject.rawValue {
                // Create a cube at the location of the anchor.
                let boxLength: Float = 0.05
                // Color the cube based on the user that placed it.
                let coloredCube = ModelEntity(mesh: MeshResource.generateBox(size: boxLength),
                                              materials: [SimpleMaterial(color: .black, isMetallic: true)])
                // Offset the cube by half its length to align its bottom with the real-world surface.
                coloredCube.position = [0, boxLength / 2, 0]
                coloredCube.generateCollisionShapes(recursive: true)

                arView.scene.subscribe(to: CollisionEvents.Began.self) { (event) in
                    print("Houve colisão entra \(event.entityA) e \(event.entityB)")
                }.store(in: &anyCancellables)

                // Attach the cube to the ARAnchor via an AnchorEntity.
                //   World origin -> ARAnchor -> AnchorEntity -> ModelEntity
                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(coloredCube)
                arView.scene.addAnchor(anchorEntity)
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
