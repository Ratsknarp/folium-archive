//
//  SkinController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 13/12/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Foundation
import GameController
import UIKit

class SkinController : LastPlayedPlayTimeController {
    var controllerView: ControllerView? = nil
    var skin: Skin
    init(game: GameBase, skin: Skin) {
        self.skin = skin
        super.init(game: game)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        guard let orientation = skin.orientation(for: interfaceOrientation()) else { return }
        
        controllerView = .init(orientation: orientation, skin: skin, delegates: (button: self, thumbstick: self))
        guard let controllerView else { return }
        controllerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controllerView)
        
        controllerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        controllerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        controllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        Task { await GCController.startWirelessControllerDiscovery() }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: .main, using: controllerDidConnect(_:))
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main, using: controllerDidDisconnect(_:))
        NotificationCenter.default.addObserver(forName: .init("applicationStateDidChange"), object: nil, queue: .main, using: applicationStateDidChange(_:))
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { skin.orientations.supportedInterfaceOrientations }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            let skin: Skin? = if let url = self.skin.url {
                try? SkinManager.shared.skin(from: url)
            } else {
                switch self.skin.core {
                case .cytrus: cytrusSkin
                case .grape: grapeSkin
                case .lychee: lycheeSkin
                case .mango: mangoSkin
                case .peach: peachSkin
                case .tomato: tomatoSkin
                default:
                    nil
                }
            }
            
            guard let skin else { return }
            self.skin = skin
            
            guard let controllerView = self.controllerView,
                  let orientation = skin.orientation(for: self.interfaceOrientation()) else { return }
            
            controllerView.updateFrames(for: orientation, controllerDisconnected: GCController.controllers().isEmpty)
        }
    }
    
    func controllerDidConnect(_ notification: Notification) {}
    func controllerDidDisconnect(_ notification: Notification) {}
    
    func applicationStateDidChange(_ notification: Notification) {}
}

extension SkinController : ControllerButtonDelegate {
    func touchBegan(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        guard let core = Core(rawValue: game.core) else { return }
        switch core {
        case .cytrus:
            CytrusDefaultController.touchBegan(with: type, playerIndex: playerIndex)
        case .grape:
            if self.isKind(of: GrapeDefaultController.classForCoder()) {
                GrapeDefaultController.touchBegan(with: type, playerIndex: playerIndex)
            } else {
                NewGrapeDefaultController.touchBegan(with: type, playerIndex: playerIndex)
            }
        case .lychee:
            LycheeDefaultController.touchBegan(with: type, playerIndex: playerIndex)
            LycheeSkinController.touchBegan(with: type, playerIndex: playerIndex)
        case .mango:
            MangoDefaultController.touchBegan(with: type, playerIndex: playerIndex)
            MangoSkinController.touchBegan(with: type, playerIndex: playerIndex)
        case .peach:
            PeachDefaultController.touchBegan(with: type, playerIndex: playerIndex)
        case .tomato:
            TomatoDefaultController.touchBegan(with: type, playerIndex: playerIndex)
        default:
            break
        }
    }
    
    func touchEnded(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        guard let core = Core(rawValue: game.core) else { return }
        switch core {
        case .cytrus:
            CytrusDefaultController.touchEnded(with: type, playerIndex: playerIndex)
        case .grape:
            if self.isKind(of: GrapeDefaultController.classForCoder()) {
                GrapeDefaultController.touchEnded(with: type, playerIndex: playerIndex)
            } else {
                NewGrapeDefaultController.touchEnded(with: type, playerIndex: playerIndex)
            }
        case .lychee:
            LycheeDefaultController.touchEnded(with: type, playerIndex: playerIndex)
            LycheeSkinController.touchEnded(with: type, playerIndex: playerIndex)
        case .mango:
            MangoDefaultController.touchEnded(with: type, playerIndex: playerIndex)
            MangoSkinController.touchEnded(with: type, playerIndex: playerIndex)
        case .peach:
            PeachDefaultController.touchEnded(with: type, playerIndex: playerIndex)
        case .tomato:
            TomatoDefaultController.touchEnded(with: type, playerIndex: playerIndex)
        default:
            break
        }
    }
    
    func touchMoved(with type: Button.`Type`, playerIndex: GCControllerPlayerIndex) {
        guard let core = Core(rawValue: game.core) else { return }
        switch core {
        case .cytrus:
            CytrusDefaultController.touchMoved(with: type, playerIndex: playerIndex)
        case .grape:
            if self.isKind(of: GrapeDefaultController.classForCoder()) {
                GrapeDefaultController.touchMoved(with: type, playerIndex: playerIndex)
            } else {
                NewGrapeDefaultController.touchMoved(with: type, playerIndex: playerIndex)
            }
        case .lychee:
            LycheeDefaultController.touchMoved(with: type, playerIndex: playerIndex)
            LycheeSkinController.touchMoved(with: type, playerIndex: playerIndex)
        case .mango:
            MangoDefaultController.touchMoved(with: type, playerIndex: playerIndex)
            MangoSkinController.touchMoved(with: type, playerIndex: playerIndex)
        case .peach:
            PeachDefaultController.touchMoved(with: type, playerIndex: playerIndex)
        case .tomato:
            TomatoDefaultController.touchMoved(with: type, playerIndex: playerIndex)
        default:
            break
        }
    }
}

extension SkinController : ControllerThumbstickDelegate {
    func touchBegan(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        guard let core = Core(rawValue: game.core) else { return }
        switch core {
        case .cytrus:
            CytrusDefaultController.touchBegan(with: type, position: position, playerIndex: playerIndex)
        default:
            break
        }
    }
    
    func touchEnded(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        guard let core = Core(rawValue: game.core) else { return }
        switch core {
        case .cytrus:
            CytrusDefaultController.touchEnded(with: type, position: position, playerIndex: playerIndex)
        default:
            break
        }
    }
    
    func touchMoved(with type: Thumbstick.`Type`, position: (x: Float, y: Float), playerIndex: GCControllerPlayerIndex) {
        guard let core = Core(rawValue: game.core) else { return }
        switch core {
        case .cytrus:
            CytrusDefaultController.touchMoved(with: type, position: position, playerIndex: playerIndex)
        default:
            break
        }
    }
}
