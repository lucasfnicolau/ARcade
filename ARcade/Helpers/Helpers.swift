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

    guard let font = UIFont(name: Font.pressStart.rawValue, size: 0.25) else { return }

    textModelComponent.mesh = .generateText(text,
                                            extrusionDepth: extrusionDepth,
                                            font: font,
                                            containerFrame: CGRect.zero,
                                            alignment: .center,
                                            lineBreakMode: .byCharWrapping)

    entity.children[0].children[0].components.set(textModelComponent)
}


