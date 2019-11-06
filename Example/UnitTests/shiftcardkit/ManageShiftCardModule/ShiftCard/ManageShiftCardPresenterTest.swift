//
// ManageShiftCardPresenterTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/11/2018.
//

import XCTest
@testable import AptoSDK
@testable import AptoUISDK

class ManageShiftCardPresenterTest: XCTestCase {
  var sut: ManageShiftCardPresenter! // swiftlint:disable:this implicitly_unwrapped_optional

  // Collaborators
  private let config = ManageShiftCardPresenterConfig(name: "name",
                                                      imageUrl: "url",
                                                      showActivateCardButton: true,
                                                      showStatsButton: true,
                                                      showAccountSettingsButton: true)
  private let interactor = ManageShiftCardInteractorFake()
  private let view = ManageShiftCardViewFake()
  private let router = ManageShiftCardModuleSpy(serviceLocator: ServiceLocatorFake())
  private let dataProvider = ModelDataProvider.provider
  private let analyticsManager: AnalyticsManagerSpy = AnalyticsManagerSpy()
  private let notificationHandler = NotificationHandlerFake()

  override func setUp() {
    super.setUp()

    setUpSUTWith(config: config)
  }

  func testRegisterForNotifications() {
    // Then
    XCTAssertTrue(notificationHandler.addObserverCalled)
    XCTAssertTrue(notificationHandler.lastAddObserverObserver === sut)
    XCTAssertEqual(.UIApplicationDidBecomeActive, notificationHandler.lastAddObserverName)
  }

  func testViewLoadedCallInteractor() {
    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideFundingSourceCalled)
  }

  func testProvideFundingSourceFailsShowError() {
    // Given
    interactor.nextProvideFundingSourceResult = .failure(BackendError(code: .other))

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(view.showErrorCalled)
  }

  func testProvideFundingSourceSucceedUpdateViewModel() {
    // Given
    let card = dataProvider.card
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.viewLoaded()

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(card.lastFourDigits, viewModel.lastFour.value)
    XCTAssertEqual(card.cardHolder, viewModel.cardHolder.value)
    XCTAssertEqual(card.cardNetwork, viewModel.cardNetwork.value)
  }

  func testOrderedCardLoadedSetShowPhysicalCardActivationToTrue() {
    // Given
    let card = dataProvider.orderedCard
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(sut.viewModel.showPhysicalCardActivationMessage.value)
  }

  func testOrderedCardReloadedSetShowPhysicalCardActivationToFalse() {
    // Given
    let card = dataProvider.orderedCard
    interactor.nextProvideFundingSourceResult = .success(card)
    sut.viewLoaded()

    // When
    interactor.nextReloadCardResult = .success(card)
    sut.refreshCard()

    // Then
    XCTAssertFalse(sut.viewModel.showPhysicalCardActivationMessage.value)
  }

  func testReceivedCardLoadedSetShowPhysicalCardActivationToFalse() {
    // Given
    let card = dataProvider.card
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertFalse(sut.viewModel.showPhysicalCardActivationMessage.value)
  }

  func testProvideFundingSourceSucceedLoadTransactions() {
    // Given
    let card = dataProvider.card
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertEqual(false, interactor.lastProvideTransactionForceRefresh)
  }

  func testCloseTappedCallRouter() {
    // When
    sut.closeTapped()

    // Then
    XCTAssertTrue(router.closeFromManageShiftCardViewerCalled)
  }

  func testNextTappedCallRouterToPresentAccountSettings() {
    // When
    sut.nextTapped()

    // Then
    XCTAssertTrue(router.accountSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardTappedCallRouter() {
    // When
    sut.cardTapped()

    // Then
    XCTAssertTrue(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardTappedForCreatedCardDoNotCallRouter() {
    // Given
    sut.viewModel.state.send(.created)

    // When
    sut.cardTapped()

    // Then
    XCTAssertFalse(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardTappedForInvalidFundingSourceCallRouterToShowBalance() {
    // Given
    sut.viewModel.fundingSource.send(dataProvider.invalidFundingSource)

    // When
    sut.cardTapped()

    // Then
    XCTAssertFalse(router.cardSettingsTappedInManageShiftCardViewerCalled)
    XCTAssertTrue(router.balanceTappedInManageShiftCardViewerCalled)
  }

  func testCardSettingsTappedCallRouter() {
    // When
    sut.cardSettingsTapped()

    // Then
    XCTAssertTrue(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testCardSettingsTappedForCreatedCardDoNotCallRouter() {
    // Given
    sut.viewModel.state.send(.created)

    // When
    sut.cardSettingsTapped()

    // Then
    XCTAssertFalse(router.cardSettingsTappedInManageShiftCardViewerCalled)
  }

  func testBalanceTappedCallRouter() {
    // When
    sut.balanceTapped()

    // Then
    XCTAssertTrue(router.balanceTappedInManageShiftCardViewerCalled)
  }

  func testTransactionSelectedCallRouterToShowDetails() {
    // Given
    givenInitialDataLoaded()
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])
    sut.moreTransactionsTapped { _ in }
    let indexPath = IndexPath(row: 0, section: 0)

    // When
    sut.transactionSelected(indexPath: indexPath)

    // Then
    XCTAssertTrue(router.showTransactionDetailsCalled)
  }

  func testActivateCardTappedCallInteractor() {
    // When
    sut.activateCardTapped()

    // Then
    XCTAssertTrue(interactor.activateCardCalled)
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testShowCardStatsTappedCallRouter() {
    // When
    sut.showCardStatsTapped()

    // Then
    XCTAssertTrue(router.showCardStatsTappedInManageCardViewerCalled)
  }

  func testCardActivationFailsShowError() {
    // Given
    interactor.nextActivateCardResult = .failure(BackendError(code: .other))

    // When
    sut.activateCardTapped()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testCardActivationSucceedUpdateViewModel() {
    // Given
    interactor.nextActivateCardResult = .success(dataProvider.card)

    // When
    sut.activateCardTapped()

    // Then
    XCTAssertEqual(FinancialAccountState.active, sut.viewModel.state.value)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testRefreshCardCallInteractor() {
    // When
    sut.refreshCard()

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testRefreshCardReloadCardFailsShowError() {
    // Given
    interactor.nextReloadCardResult = .failure(BackendError(code: .other))

    // When
    sut.refreshCard()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testReloadCardSucceedUpdateViewModel() {
    // Given
    let card = dataProvider.cardWithoutDetails
    interactor.nextReloadCardResult = .success(card)

    // When
    sut.refreshCard()

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(card.lastFourDigits, viewModel.lastFour.value)
    XCTAssertEqual(card.cardHolder, viewModel.cardHolder.value)
    XCTAssertEqual(card.cardNetwork, viewModel.cardNetwork.value)
    XCTAssertNil(viewModel.cvv.value)
    XCTAssertNil(viewModel.pan.value)
    XCTAssertNil(viewModel.expirationMonth.value)
    XCTAssertNil(viewModel.expirationYear.value)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testRefreshFundingSourceCallInteractor() {
    // When
    sut.refreshFundingSource()

    // Then
    XCTAssertTrue(interactor.provideFundingSourceCalled)
    XCTAssertEqual(false, interactor.lastProvideFundingSourceForceRefresh)
  }

  func testRefreshFundingSourceProvideFundingSourceSucceedUpdateViewModel() {
    // Given
    let card = dataProvider.card
    interactor.nextProvideFundingSourceResult = .success(card)

    // When
    sut.refreshFundingSource()

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(card.lastFourDigits, viewModel.lastFour.value)
    XCTAssertEqual(card.cardHolder, viewModel.cardHolder.value)
    XCTAssertEqual(card.cardNetwork, viewModel.cardNetwork.value)
  }

  func testShowCardInfoCallInteractor() {
    // When
    sut.showCardInfo() {}

    // Then
    XCTAssertTrue(interactor.loadCardInfoCalled)
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testLoadCardInfoFailsShowError() {
    // Given
    interactor.nextLoadCardInfoResult = .failure(BackendError(code: .other))

    // When
    sut.showCardInfo() {}

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testLoadCardInfoSucceedUpdateViewModelCardDetails() {
    // Given
    let cardDetails = dataProvider.cardDetails
    interactor.nextLoadCardInfoResult = .success(cardDetails)

    // When
    sut.showCardInfo() {}

    // Then
    let viewModel = sut.viewModel
    XCTAssertEqual(cardDetails.cvv, viewModel.cvv.value)
    XCTAssertEqual(cardDetails.pan, viewModel.pan.value)
    XCTAssertEqual(3, viewModel.expirationMonth.value)
    XCTAssertEqual(99, viewModel.expirationYear.value)
    XCTAssertEqual(true, viewModel.cardInfoVisible.value)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testHideCardInfoUpdateViewModel() {
    // When
    sut.hideCardInfo()

    // Then
    XCTAssertEqual(false, sut.viewModel.cardInfoVisible.value)
  }

  func testReloadTappedShowingSpinnerShowSpinner() {
    // Given
    givenInitialDataLoaded()

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(view.showLoadingSpinnerCalled)
  }

  func testInitialDataLoadedRefreshDataFromServer() {
    // When
    givenInitialDataLoaded()

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertNil(interactor.lastProvideTransactionFilters?.lastTransactionId)
    XCTAssertEqual(true, interactor.lastProvideTransactionForceRefresh)
    XCTAssertTrue(interactor.loadFundingSourcesCalled)
  }

  func testWillEnterForegroundNotificationReceivedRefreshDataFromServer() {
    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertNil(interactor.lastProvideTransactionFilters?.lastTransactionId)
    XCTAssertEqual(true, interactor.lastProvideTransactionForceRefresh)
    XCTAssertTrue(interactor.loadFundingSourcesCalled)
  }

  func testBackgroundRefreshAppendDataToTheTop() {
    // Given
    givenInitialDataLoaded()
    interactor.nextProvideTransactionsResult = .success([dataProvider.transactionWith(transactionId: "other"),
                                                         dataProvider.transaction])

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertEqual(2, sut.viewModel.transactions.numberOfItemsInAllSections)
  }

  func testBackgroundRefreshWithoutOverlapSetNewData() {
    // Given
    givenInitialDataLoaded()
    interactor.nextProvideTransactionsResult = .success([dataProvider.transactionWith(transactionId: "other")])

    // When
    notificationHandler.postNotification(.UIApplicationDidBecomeActive)

    // Then
    XCTAssertEqual(1, sut.viewModel.transactions.numberOfItemsInAllSections)
    XCTAssertEqual("other", sut.viewModel.transactions[itemAt: [0, 0]].transactionId)
  }

  func testReloadTappedNotShowingSpinnerDoNotShowSpinner() {
    // When
    sut.reloadTapped(showSpinner: false)

    // Then
    XCTAssertFalse(view.showLoadingSpinnerCalled)
  }

  func testReloadTappedCallInteractor() {
    // Given
    givenInitialDataLoaded()

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(interactor.reloadCardCalled)
    XCTAssertTrue(interactor.loadFundingSourcesCalled)
  }

  func testReloadTappedReloadCardFailsShowError() {
    // Given
    interactor.nextReloadCardResult = .failure(BackendError(code: .other))

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(view.showErrorCalled)
  }

  func testReloadCardFinishRefreshTransactions() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertEqual(20, interactor.lastProvideTransactionFilters?.rows)
    XCTAssertNil(interactor.lastProvideTransactionFilters?.lastTransactionId)
  }

  func testReloadTappedShowingSpinnerReloadCardFinishHideSpinner() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.reloadTapped(showSpinner: true)

    // Then
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testReloadTappedNotShowingSpinnerReloadCardFinishDoNotHideSpinner() {
    // Given
    interactor.nextReloadCardResult = .success(dataProvider.card)
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])

    // When
    sut.reloadTapped(showSpinner: false)

    // Then
    XCTAssertFalse(view.hideLoadingSpinnerCalled)
  }

  func testInitialLoadFinishMoreTransactionsTappedCallInteractor() {
    // Given
    givenInitialDataLoaded()

    // When
    sut.moreTransactionsTapped { _ in }

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
  }

  func testTransactionProvidedMoreTransactionsTappedCallInteractorWithTransactionId() {
    //Given
    givenInitialDataLoaded()
    let transaction = dataProvider.transaction
    interactor.nextProvideTransactionsResult = .success([transaction])
    sut.moreTransactionsTapped { _ in }

    // When
    sut.moreTransactionsTapped { _ in }

    // Then
    XCTAssertTrue(interactor.provideTransactionsCalled)
    XCTAssertEqual(transaction.transactionId, interactor.lastProvideTransactionFilters?.lastTransactionId)
  }

  func testActivatePhysicalCardTappedRequestActivationCode() {
    // When
    sut.activatePhysicalCardTapped()

    // Then
    XCTAssertTrue(view.requestPhysicalActivationCodeCalled)
  }

  func testActivationCodeProvidedPhysicalCardActivationFailsShowError() {
    // Given
    interactor.nextActivatePhysicalCardResult = .failure(BackendError(code: .other))
    view.nextPhysicalCardActivationCode = "111111"

    // When
    sut.activatePhysicalCardTapped()

    // Then
    XCTAssertTrue(view.showErrorCalled)
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
  }

  func testActivationCodeProvidedPhysicalCardActivationSucceedCallNotifyRouter() {
    // Given
    interactor.nextActivatePhysicalCardResult = .success(Void())
    view.nextPhysicalCardActivationCode = "111111"

    // When
    sut.activatePhysicalCardTapped()

    // Then
    XCTAssertTrue(view.hideLoadingSpinnerCalled)
    XCTAssertTrue(router.physicalActivationSucceedCalled)
  }

  func testShowStatsButtonStatsFeatureIsEnabled() {
    // Given
    let config = ManageShiftCardPresenterConfig(name: "name",
                                                imageUrl: "url",
                                                showActivateCardButton: true,
                                                showStatsButton: true,
                                                showAccountSettingsButton: false)
    setUpSUTWith(config: config)
    interactor.nextProvideFundingSourceResult = .success(dataProvider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(sut.viewModel.isStatsFeatureEnabled.value)
  }

  func testShowStatsButtonFalseStatsFeatureIsDisabled() {
    // Given
    let config = ManageShiftCardPresenterConfig(name: "name",
                                                imageUrl: "url",
                                                showActivateCardButton: true,
                                                showStatsButton: false,
                                                showAccountSettingsButton: false)
    setUpSUTWith(config: config)
    interactor.nextProvideFundingSourceResult = .success(dataProvider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertFalse(sut.viewModel.isStatsFeatureEnabled.value)
  }

  func testShowStatsButtonNilStatsFeatureIsDisabled() {
    // Given
    let config = ManageShiftCardPresenterConfig(name: "name",
                                                imageUrl: "url",
                                                showActivateCardButton: true,
                                                showStatsButton: nil,
                                                showAccountSettingsButton: false)
    setUpSUTWith(config: config)
    interactor.nextProvideFundingSourceResult = .success(dataProvider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertFalse(sut.viewModel.isStatsFeatureEnabled.value)
  }

  func testShowAccountSettingsButtonTrueFeatureIsEnabled() {
    // Given
    let config = ManageShiftCardPresenterConfig(name: "name",
                                                imageUrl: "url",
                                                showActivateCardButton: true,
                                                showStatsButton: true,
                                                showAccountSettingsButton: true)
    setUpSUTWith(config: config)
    interactor.nextProvideFundingSourceResult = .success(dataProvider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(sut.viewModel.isAccountSettingsEnabled.value)
  }

  func testShowAccountSettingsFalseStatsFeatureIsDisabled() {
    // Given
    let config = ManageShiftCardPresenterConfig(name: "name",
                                                imageUrl: "url",
                                                showActivateCardButton: true,
                                                showStatsButton: false,
                                                showAccountSettingsButton: false)
    setUpSUTWith(config: config)
    interactor.nextProvideFundingSourceResult = .success(dataProvider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertFalse(sut.viewModel.isAccountSettingsEnabled.value)
  }

  func testShowAccountSettingsNilStatsFeatureIsDisabled() {
    // Given
    let config = ManageShiftCardPresenterConfig(name: "name",
                                                imageUrl: "url",
                                                showActivateCardButton: true,
                                                showStatsButton: nil,
                                                showAccountSettingsButton: nil)
    setUpSUTWith(config: config)
    interactor.nextProvideFundingSourceResult = .success(dataProvider.card)

    // When
    sut.viewLoaded()

    // Then
    XCTAssertTrue(sut.viewModel.isAccountSettingsEnabled.value)
  }

  private func setUpSUTWith(config: ManageShiftCardPresenterConfig) {
    sut = ManageShiftCardPresenter(config: config, notificationHandler: notificationHandler)
    sut.interactor = interactor
    sut.router = router
    sut.view = view
    sut.analyticsManager = analyticsManager
  }

  private func givenInitialDataLoaded() {
    let card = dataProvider.card
    interactor.nextReloadCardResult = .success(card)
    interactor.nextProvideFundingSourceResult = .success(card)
    interactor.nextProvideTransactionsResult = .success([dataProvider.transaction])
    sut.viewLoaded()
  }
  
  func testViewLoadedLogManageCard() {
    // When
    sut.viewLoaded()
    
    // Then
    XCTAssertTrue(analyticsManager.trackCalled)
    XCTAssertEqual(analyticsManager.lastEvent, Event.manageCard)
  }
}
