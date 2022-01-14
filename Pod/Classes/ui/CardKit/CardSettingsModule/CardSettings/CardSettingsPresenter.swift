//
//  CardSettingsPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import AptoSDK
import Bond
import Foundation

struct CardSettingsPresenterConfig {
    let cardholderAgreement: Content?
    let privacyPolicy: Content?
    let termsAndCondition: Content?
    let faq: Content?
    let exchangeRates: Content?
    let showDetailedCardActivity: Bool
    let showMonthlyStatements: Bool
    let iapRowTitle: String
}

class CardSettingsPresenter: CardSettingsPresenterProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var view: CardSettingsViewProtocol!
    var interactor: CardSettingsInteractorProtocol!
    weak var router: CardSettingsRouterProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    let viewModel: CardSettingsViewModel
    var analyticsManager: AnalyticsServiceProtocol?
    private var card: Card
    private let rowsPerPage = 20
    private let enableCardAction: EnableCardAction
    private let disableCardAction: DisableCardAction
    private let reportLostCardAction: ReportLostCardAction
    private let helpAction: HelpAction
    private let config: CardSettingsPresenterConfig
    private let phoneHelper = PhoneHelper.sharedHelper()
    private let legalDocuments: LegalDocuments

    init(platform: AptoPlatformProtocol,
         card: Card,
         config: CardSettingsPresenterConfig,
         emailRecipients: [String?],
         uiConfig: UIConfig)
    {
        self.card = card
        self.config = config
        viewModel = CardSettingsViewModel()
        enableCardAction = EnableCardAction(platform: platform, card: self.card, uiConfig: uiConfig)
        disableCardAction = DisableCardAction(platform: platform, card: self.card, uiConfig: uiConfig)
        reportLostCardAction = ReportLostCardAction(platform: platform, card: card, emailRecipients: emailRecipients,
                                                    uiConfig: uiConfig)
        helpAction = HelpAction(emailRecipients: emailRecipients)
        legalDocuments = LegalDocuments(cardHolderAgreement: config.cardholderAgreement,
                                        faq: config.faq,
                                        termsAndConditions: config.termsAndCondition,
                                        privacyPolicy: config.privacyPolicy,
                                        exchangeRates: config.exchangeRates)
        viewModel.legalDocuments.send(legalDocuments)
    }

    func viewLoaded() {
        refreshData()
        analyticsManager?.track(event: Event.manageCardCardSettings)
    }

    func lockCardChanged(switcher: UISwitch) {
        if switcher.isOn {
            disableCardAction.run { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    self.viewModel.locked.send(false)
                    switcher.isOn = false
                    self.handleDisableCardError(error: error)
                case .success:
                    self.viewModel.locked.send(true)
                    self.router.cardStateChanged()
                }
            }
        } else {
            enableCardAction.run { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    self.viewModel.locked.send(true)
                    self.handleEnableCardError(error: error)
                case .success:
                    self.viewModel.locked.send(false)
                    self.router.cardStateChanged()
                }
            }
        }
    }

    private func handleDisableCardError(error: NSError) {
        if let serviceError = error as? ServiceError, serviceError.isAbortedError {
            // The user aborted the operation, don't show an error message
            return
        }
        if let backendError = error as? BackendError, backendError.isCardDisableError {
            view.showClosedCardErrorAlert(title: "error.transport.shiftCardDisableError".podLocalized())
        } else {
            view.show(error: error)
        }
    }

    private func handleEnableCardError(error: NSError) {
        if let serviceError = error as? ServiceError, serviceError.isAbortedError {
            // The user aborted the operation, don't show an error message
            return
        }
        if let backendError = error as? BackendError, backendError.isCardEnableError {
            view.showClosedCardErrorAlert(title: "error.transport.shiftCardEnableError".podLocalized())
        } else {
            view.show(error: error)
        }
    }

    func updateCardNewStatus() {
        router.cardStateChanged()
        router.closeFromCardSettings()
    }

    func didTapOnShowCardInfo() {
        router.authenticate { [weak self] accessGranted in
            guard let self = self else { return }
            if accessGranted {
                self.router.showCardInfo()
                self.router.closeFromCardSettings()
            }
        }
    }

    fileprivate func refreshData() {
        viewModel.locked.send(card.state != .active)
        let iapEnabled = card.features?.inAppProvisioning?.status == .enabled
        viewModel.buttonsVisibility.send(CardSettingsButtonsVisibility(
            showChangePin: card.features?.setPin?.status == .enabled,
            showGetPin: card.features?.getPin?.status == .enabled,
            showSetPassCode: card.features?.passCode?.status == .enabled,
            showIVRSupport: card.features?.ivrSupport?.status == .enabled,
            showDetailedCardActivity: config.showDetailedCardActivity,
            isShowDetailedCardActivityEnabled: interactor
                .isShowDetailedCardActivityEnabled(),
            showMonthlyStatements: config.showMonthlyStatements,
            showAddFundsFeature: card.features?.funding?.status == .enabled,
            showOrderPhysicalCard: card.orderedStatus == .available,
            showP2PTransferFeature: card.features?.p2pTransfer?.status == .enabled,
            showAppleWalletRow: iapEnabled
        ))

        let cardShippingStatusResult = CardShippingStatus()
            .formatShippingStatus(orderedStatus: card.orderedStatus,
                                  issuedAt: card.issuedAt)

        viewModel.cardShipping.send(CardShipping(showShipping: cardShippingStatusResult.show,
                                                 title: cardShippingStatusResult.title,
                                                 subtitle: cardShippingStatusResult.subtitle))
    }

    func closeTapped() {
        router.closeFromCardSettings()
    }

    func callIvrTapped() {
        guard let url = phoneHelper.callURL(from: card.features?.ivrSupport?.phone) else { return }
        router.call(url: url) {}
    }

    func helpTapped() {
        helpAction.run()
    }

    func didTapOnLoadFunds() {
        let extraContent = ExtraContent(content: legalDocuments.cardHolderAgreement,
                                        title: "card_settings.legal.cardholder_agreement.title".podLocalized())
        if customerHasProvisionedACHAccount() {
            router.showAddMoneyBottomSheet(card: card, extraContent: extraContent)
        } else if customerShouldAcceptACHAgreement() {
            guard let features = card.features, let bankAccount = features.achAccount,
                  let disclaimer = bankAccount.disclaimer,
                  let content = disclaimer.content
            else {
                return
            }
            router.showACHAccountAgreements(disclaimer: content,
                                            cardId: card.accountId,
                                            acceptCompletion: { [router, card, weak self] in
                                                router?.showAddMoneyBottomSheet(card: card, extraContent: extraContent)
                                                self?.refreshCardData(card.accountId)
                                            },
                                            declineCompletion: { [router, card] in
                                                router?.showAddFunds(for: card, extraContent: extraContent)
                                            })
        } else {
            router.showAddFunds(for: card, extraContent: extraContent)
        }
    }

    private func customerHasProvisionedACHAccount() -> Bool {
        guard let features = card.features, let bankAccount = features.achAccount,
              let hasSetupACHAccount = bankAccount.isAccountProvisioned
        else {
            return false
        }
        return bankAccount.status == .enabled && hasSetupACHAccount
    }

    private func customerShouldAcceptACHAgreement() -> Bool {
        guard let features = card.features, let bankAccount = features.achAccount,
              let hasSetupACHAccount = bankAccount.isAccountProvisioned
        else {
            return false
        }
        return bankAccount.status == .enabled && hasSetupACHAccount == false
    }

    func refreshCardData(_ cardId: String) {
        AptoPlatform
            .defaultManager()
            .fetchCard(cardId,
                       forceRefresh: true) { [weak self] result in
                if let refreshedCard = try? result.get() {
                    self?.card = refreshedCard
                    self?.refreshData()
                }
            }
    }

    func didTapOnOrderPhysicalCard() {
        guard card.orderedStatus == .available else { return }
        router.showOrderPhysicalCard(card) { [weak self] in
            if let cardId = self?.card.accountId {
                self?.refreshCardData(cardId)
            }
        }
    }

    func didTapOnP2PTransfer() {
        AptoPlatform
            .defaultManager()
            .fetchContextConfiguration(false) { [router] result in
                switch result {
                case let .success(config):
                    router?.showP2PTransferScreen(with: config.projectConfiguration)
                default: break
                }
            }
    }

    func didTapOnApplePayIAP() {
        let cardId = card.accountId
        router.showApplePayIAP(cardId: cardId) { [weak self] in
            self?.refreshCardData(cardId)
        }
    }

    func lostCardTapped() {
        reportLostCardAction.run { [unowned self] result in
            switch result {
            case let .failure(error):
                if let serviceError = error as? ServiceError, serviceError.code == ServiceError.ErrorCodes.aborted.rawValue {
                    // User aborted, do nothing
                    return
                }
                self.view.show(error: error)
            case .success:
                self.viewModel.locked.send(true)
                self.router.cardStateChanged()
            }
        }
    }

    func changePinTapped() {
        guard let actionSource = card.features?.setPin?.source else { return }
        switch actionSource {
        case let .ivr(ivr):
            guard let url = phoneHelper.callURL(from: ivr.phone) else { return }
            router.call(url: url) { [weak self] in
                self?.router.cardStateChanged()
            }
        case .api:
            router.changeCardPin()
            router.closeFromCardSettings()
        case .voIP:
            router.showVoIP(actionSource: .getPin)
        case .unknown: break
        }
    }

    func getPinTapped() {
        guard let actionSource = card.features?.getPin?.source else { return }
        switch actionSource {
        case .voIP:
            router.showVoIP(actionSource: .getPin)
        case .api:
            break // Get pin via API is not supported yet
        case let .ivr(ivr):
            guard let url = phoneHelper.callURL(from: ivr.phone) else { return }
            router.call(url: url) { [unowned self] in
                self.router.cardStateChanged()
            }
        case .unknown:
            break
        }
    }

    func setPassCodeTapped() {
        router.setPassCode()
    }

    func show(content: Content, title: String) {
        router.show(content: content, title: title)
    }

    func showDetailedCardActivity(_ newValue: Bool) {
        interactor.setShowDetailedCardActivityEnabled(newValue)
        router.cardStateChanged(includingTransactions: true)
    }

    func monthlyStatementsTapped() {
        router.showMonthlyStatements()
    }

    func cardLastFourDigits() -> String {
        card.lastFourDigits
    }
}
