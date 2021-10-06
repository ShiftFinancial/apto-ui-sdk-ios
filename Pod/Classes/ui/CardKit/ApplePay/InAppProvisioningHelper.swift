//
//  InAppProvisioningHelper.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 14/4/21.
//

import PassKit
import AptoSDK

public protocol ApplePayInAppProvisioningProtocol {
    func appleWalletButton() -> UIButton
}

public typealias AppleWalletButtonAction = (() -> Void)

public class InAppProvisioningHelper: ApplePayInAppProvisioningProtocol {
    
    static let appleWalletButtonTag = 223311
    static let appleWalletContainerViewTag = 223312

    public init() {}
    
    public func appleWalletButton() -> UIButton {
        let button = PKAddPassButton(addPassButtonStyle: .blackOutline)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = InAppProvisioningHelper.appleWalletButtonTag
        return button
    }
}
