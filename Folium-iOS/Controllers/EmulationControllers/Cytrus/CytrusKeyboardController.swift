//
//  CytrusKeyboardController.swift
//  Folium-iOS
//
//  Created by Jarrod Norwell on 6/9/2024.
//  Copyright © 2024 Jarrod Norwell. All rights reserved.
//

import Cytrus
import Foundation
import UIKit

class CytrusKeyboardController : UIViewController, UITextFieldDelegate {
    var bottomConstraint: NSLayoutConstraint!
    
    var buttonConfig: KeyboardButtonConfig
    init(buttonConfig: KeyboardButtonConfig) {
        self.buttonConfig = buttonConfig
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textField = MinimalRoundedTextField("Enter text", .all)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .tertiarySystemBackground
        textField.delegate = self
        view.addSubview(textField)
        view.addConstraints([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        var buttons: [UIButton] = []
        switch buttonConfig {
        case .single:
            var configuration = UIButton.Configuration.filled()
            configuration.attributedTitle = .init("Okay", attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            configuration.buttonSize = .large
            configuration.cornerStyle = .large
            
            buttons.append(.init(configuration: configuration, primaryAction: .init(handler: { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
                textField.text = nil
                self.dismiss(animated: true)
            })))
        case .dual:
            var cancelConfiguration = UIButton.Configuration.filled()
            cancelConfiguration.attributedTitle = .init("Cancel", attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            cancelConfiguration.buttonSize = .large
            cancelConfiguration.cornerStyle = .large
            
            var okayConfiguration = UIButton.Configuration.filled()
            okayConfiguration.attributedTitle = .init("Okay", attributes: .init([
                .font : UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
            ]))
            okayConfiguration.buttonSize = .large
            okayConfiguration.cornerStyle = .large
            
            let cancelButton = UIButton(configuration: cancelConfiguration, primaryAction: .init(handler: { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
                textField.text = nil
                self.dismiss(animated: true)
            }))
            cancelButton.tintColor = .systemRed
            
            buttons.append(cancelButton)
            buttons.append(.init(configuration: okayConfiguration, primaryAction: .init(handler: { _ in
                NotificationCenter.default.post(name: .init("closeKeyboard"), object: nil, userInfo: [
                    "buttonPressed" : 0,
                    "keyboardText" : textField.text ?? ""
                ])
                textField.text = nil
                self.dismiss(animated: true)
            })))
        case .triple:
            break
        case .none:
            break
        @unknown default:
            fatalError()
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        view.addSubview(stackView)
        
        bottomConstraint = stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        
        view.addConstraints([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomConstraint
        ])
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            self.bottomConstraint.constant = -20
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo, let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            self.bottomConstraint.constant = -frame.height
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
