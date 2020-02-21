//
//  ARcadeScene.swift
//  ARcade
//
//  Created by Lucas Fernandez Nicolau on 20/02/20.
//

import ARKit
import RealityKit

class ARcadeView: ARView {
    var arcade: Entity?

    func disableScreen() {
        arcade?.scale = SIMD3(0, 0, 0)
    }

    func enableScreen() {
        arcade?.scale = SIMD3(1, 1, 1)
    }
}
