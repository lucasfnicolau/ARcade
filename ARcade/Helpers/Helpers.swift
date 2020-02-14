//
//  Helpers.swift
//  ARcade
//
//  Created by Lucas Fernandez Nicolau on 14/02/20.
//

import UIKit
import RealityKit

func set(text: String,
         for entity: Entity?,
         withExtrusionDepth extrusionDepth: Float = 0.025) {

    guard let entity = entity else { return }
    let textEntity = entity.children[0].children[0]
    var textModelComponent: ModelComponent = (textEntity.components[ModelComponent])!

    textModelComponent.mesh = .generateText(text,
                                            extrusionDepth: extrusionDepth,
                                            font: .systemFont(ofSize: 0.25),
                                            containerFrame: CGRect.zero,
                                            alignment: .center,
                                            lineBreakMode: .byCharWrapping)

    entity.children[0].children[0].components.set(textModelComponent)
}


