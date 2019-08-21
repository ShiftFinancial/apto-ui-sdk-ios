//
//  AptoPlatformTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 20/08/2018.
//
//

@testable import AptoSDK

class AptoPlatformFake: AptoPlatformProtocol {
  var delegate: AptoPlatformDelegate?

  // MARK: - SDK Initialization

  private(set) var initializeWithApiKeyCalled = false
  private(set) var lastApiKey: String?
  private(set) var lastEnvironment: AptoPlatformEnvironment?
  private(set) var lastSetupCertPining: Bool?
  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment, setupCertPinning: Bool) {
    initializeWithApiKeyCalled = true
    lastApiKey = apiKey
    lastEnvironment = environment
    lastSetupCertPining = setupCertPinning
  }

  func initializeWithApiKey(_ apiKey: String, environment: AptoPlatformEnvironment) {
    initializeWithApiKey(apiKey, environment: environment, setupCertPinning: true)
  }

  func initializeWithApiKey(_ apiKey: String) {
    initializeWithApiKey(apiKey, environment: .development)
  }

  // MARK: - Configuration handling

  private(set) var setCardOptionsCalled = false
  private(set) var lastCardOptionsSet: CardOptions?
  func setCardOptions(_ cardOptions: CardOptions?) {
    setCardOptionsCalled = true
    lastCardOptionsSet = cardOptions
  }

  var nextFetchContextConfigurationResult: Result<ContextConfiguration, NSError>?
  private(set) var fetchContextConfigurationCalled = false
  private(set) var lastFetchContextConfigurationForceRefresh: Bool?
  func fetchContextConfiguration(_ forceRefresh: Bool,
                                 callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
    fetchContextConfigurationCalled = true
    lastFetchContextConfigurationForceRefresh = forceRefresh
    if let result = nextFetchContextConfigurationResult {
      callback(result)
    }
  }

  var nextFetchUIConfigResult: UIConfig?
  private(set) var fetchUIConfigCalled = false
  func fetchUIConfig() -> UIConfig? {
    fetchUIConfigCalled = true
    return nextFetchUIConfigResult
  }

  var nextFetchCardProductsResult: Result<[CardProductSummary], NSError>?
  private(set) var fetchCardProductsCalled = false
  func fetchCardProducts(callback: @escaping Result<[CardProductSummary], NSError>.Callback) {
    fetchCardProductsCalled = true
    if let result = nextFetchCardProductsResult {
      callback(result)
    }
  }

  var nextFetchCardProductResult: Result<CardProduct, NSError>?
  private(set) var fetchCardConfigurationCalled = false
  private(set) var lastFetchCardConfigurationCardProductId: String?
  private(set) var lastFetchCardConfigurationForceRefresh: Bool?
  func fetchCardProduct(cardProductId: String, forceRefresh: Bool,
                        callback: @escaping Result<CardProduct, NSError>.Callback) {
    fetchCardConfigurationCalled = true
    lastFetchCardConfigurationCardProductId = cardProductId
    lastFetchCardConfigurationForceRefresh = forceRefresh
    if let result = nextFetchCardProductResult {
      callback(result)
    }
  }

  var nextIsFeatureEnabledResult = true
  private(set) var isFeatureEnabledCalled = false
  func isFeatureEnabled(_ featureKey: FeatureKey) -> Bool {
    isFeatureEnabledCalled = true
    return nextIsFeatureEnabledResult
  }

  var nextIsShowDetailedCardActivityEnabledResult = true
  private(set) var isShowDetailedCardActivityEnabledCalled = false
  func isShowDetailedCardActivityEnabled() -> Bool {
    isShowDetailedCardActivityEnabledCalled = true
    return nextIsShowDetailedCardActivityEnabledResult
  }

  private(set) var setShowDetailedCardActivityEnabledCalled = false
  private(set) var lastIsSetShowDetailedCardActivityEnabled: Bool?
  func setShowDetailedCardActivityEnabled(_ isEnabled: Bool) {
    setShowDetailedCardActivityEnabledCalled = true
    lastIsSetShowDetailedCardActivityEnabled = isEnabled
  }

  // MARK: - User tokens handling

  var nextCurrentTokenResult: AccessToken?
  private(set) var currentTokenCalled = false
  func currentToken() -> AccessToken? {
    currentTokenCalled = true
    return nextCurrentTokenResult
  }

  private(set) var clearUserTokenCalled = false
  func clearUserToken() {
    clearUserTokenCalled = true
    nextCurrentTokenResult = nil
  }

  var nextCurrentPushTokenResult: String?
  private(set) var currentPushTokenCalled = false
  func currentPushToken() -> String? {
    currentPushTokenCalled = true
    return nextCurrentPushTokenResult
  }

  // MARK: - User handling

  var nextCreateUserResult: Result<ShiftUser, NSError>?
  private(set) var createUserCalled = false
  private(set) var lastCreateUserUserData: DataPointList?
  private(set) var lastCreateUserCustodianUid: String?
  func createUser(userData: DataPointList, custodianUid: String?,
                  callback: @escaping Result<ShiftUser, NSError>.Callback) {
    createUserCalled = true
    lastCreateUserUserData = userData
    lastCreateUserCustodianUid = custodianUid
    if let result = nextCreateUserResult {
      callback(result)
    }
  }

  var nextLoginUserResult: Result<ShiftUser, NSError>?
  private(set) var loginUserCalled = false
  private(set) var lastLoginUserVerifications: [Verification]?
  func loginUserWith(verifications: [Verification], callback: @escaping Result<ShiftUser, NSError>.Callback) {
    loginUserCalled = true
    lastLoginUserVerifications = verifications
    if let result = nextLoginUserResult {
      callback(result)
    }
  }

  var nextFetchCurrentUserInfoResult: Result<ShiftUser, NSError>?
  private(set) var fetchCurrentUserInfoCalled = false
  private(set) var lastFetchCurrentUserForceRefresh: Bool?
  private(set) var lastFetchCurrentUserInfoFilterInvalidTokenResult: Bool?
  func fetchCurrentUserInfo(forceRefresh: Bool, filterInvalidTokenResult: Bool,
                            callback: @escaping Result<ShiftUser, NSError>.Callback) {
    fetchCurrentUserInfoCalled = true
    lastFetchCurrentUserForceRefresh = forceRefresh
    lastFetchCurrentUserInfoFilterInvalidTokenResult = filterInvalidTokenResult
    if let result = nextFetchCurrentUserInfoResult {
      callback(result)
    }
  }

  var nextUpdateUserInfoResult: Result<ShiftUser, NSError>?
  private(set) var updateUserInfoCalled = false
  private(set) var lastUpdateUserInfoUserData: DataPointList?
  func updateUserInfo(_ userData: DataPointList, callback: @escaping Result<ShiftUser, NSError>.Callback) {
    updateUserInfoCalled = true
    lastUpdateUserInfoUserData = userData
    if let result = nextUpdateUserInfoResult {
      callback(result)
    }
  }

  private(set) var logoutCalled = false
  func logout() {
    logoutCalled = true
  }

  // MARK: - Oauth handling
  var nextStartOauthAuthenticationResult: Result<OauthAttempt, NSError>?
  private(set) var startOauthAuthenticationCalled = false
  private(set) var lastStartOauthAuthenticationBalanceType: AllowedBalanceType?
  func startOauthAuthentication(balanceType: AllowedBalanceType,
                                callback: @escaping Result<OauthAttempt, NSError>.Callback) {
    startOauthAuthenticationCalled = true
    lastStartOauthAuthenticationBalanceType = balanceType
    if let result = nextStartOauthAuthenticationResult {
      callback(result)
    }
  }

  var nextVerifyOauthAttemptStatusResult: Result<Custodian?, NSError>?
  private(set) var verifyOauthAttemptStatusCalled = false
  private(set) var lastVerifyOauthAttemptStatusAttempt: OauthAttempt?
  private(set) var lastVerifyOauthAttemptStatusCustodianType: CustodianType?
  func verifyOauthAttemptStatus(_ attempt: OauthAttempt, custodianType: CustodianType,
                                callback: @escaping Result<Custodian?, NSError>.Callback) {
    verifyOauthAttemptStatusCalled = true
    lastVerifyOauthAttemptStatusAttempt = attempt
    lastVerifyOauthAttemptStatusCustodianType = custodianType
    if let result = nextVerifyOauthAttemptStatusResult {
      callback(result)
    }
  }

  var nextSaveOauthUserDataResult: Result<OAuthSaveUserDataResult, NSError>?
  private(set) var saveOauthUserDataCalled = false
  private(set) var lastSaveOauthUserDataUserData: DataPointList?
  func saveOauthUserData(_ userData: DataPointList, custodian: Custodian,
                         callback: @escaping Result<OAuthSaveUserDataResult, NSError>.Callback) {
    saveOauthUserDataCalled = true
    lastSaveOauthUserDataUserData = userData
    if let result = nextSaveOauthUserDataResult {
      callback(result)
    }
  }

  var nextFetchOAuthDataResult: Result<OAuthUserData, NSError>?
  private(set) var fetchOAuthDataCalled = false
  private(set) var lastFetchOAuthDataCustodian: Custodian?
  func fetchOAuthData(_ custodian: Custodian, callback: @escaping Result<OAuthUserData, NSError>.Callback) {
    fetchOAuthDataCalled = true
    lastFetchOAuthDataCustodian = custodian
    if let result = nextFetchOAuthDataResult {
      callback(result)
    }
  }

  // MARK: - Verifications

  var nextStartPhoneVerificationResult: Result<Verification, NSError>?
  private(set) var startPhoneVerificationCalled = false
  private(set) var lastStartPhoneVerificationPhone: PhoneNumber?
  func startPhoneVerification(_ phone: PhoneNumber, callback: @escaping Result<Verification, NSError>.Callback) {
    startPhoneVerificationCalled = true
    lastStartPhoneVerificationPhone = phone
    if let result = nextStartPhoneVerificationResult {
      callback(result)
    }
  }

  var nextStartEmailVerificationResult: Result<Verification, NSError>?
  private(set) var startEmailVerificationCalled = false
  private(set) var lastStartEmailVerificationEmail: Email?
  func startEmailVerification(_ email: Email, callback: @escaping Result<Verification, NSError>.Callback) {
    startEmailVerificationCalled = true
    lastStartEmailVerificationEmail = email
    if let result = nextStartEmailVerificationResult {
      callback(result)
    }
  }

  var nextStartBirthDateVerificationResult: Result<Verification, NSError>?
  private(set) var startBirthDateVerificationCalled = false
  private(set) var lastStartBirthDateVerificationBirthDate: BirthDate?
  func startBirthDateVerification(_ birthDate: BirthDate, callback: @escaping Result<Verification, NSError>.Callback) {
    startBirthDateVerificationCalled = true
    lastStartBirthDateVerificationBirthDate = birthDate
    if let result = nextStartBirthDateVerificationResult {
      callback(result)
    }
  }

  var nextStartDocumentVerificationResult: Result<Verification, NSError>?
  private(set) var startDocumentVerificationCalled = false
  private(set) var lastStartDocumentVerificationDocumentImages: [UIImage]?
  private(set) var lastStartDocumentVerificationSelfie: UIImage?
  private(set) var lastStartDocumentVerificationLivenessData: [String: AnyObject]?
  private(set) var lastStartDocumentVerificationWorkflowObject: WorkflowObject?
  func startDocumentVerification(documentImages: [UIImage], selfie: UIImage?, livenessData: [String: AnyObject]?,
                                 associatedTo workflowObject: WorkflowObject?,
                                 callback: @escaping Result<Verification, NSError>.Callback) {
    startDocumentVerificationCalled = true
    lastStartDocumentVerificationDocumentImages = documentImages
    lastStartDocumentVerificationSelfie = selfie
    lastStartDocumentVerificationLivenessData = livenessData
    lastStartDocumentVerificationWorkflowObject = workflowObject
    if let result = nextStartDocumentVerificationResult {
      callback(result)
    }
  }

  var nextFetchDocumentVerificationStatusResult: Result<Verification, NSError>?
  private(set) var fetchDocumentVerificationStatusCalled = false
  private(set) var lastFetchDocumentVerificationStatusVerification: Verification?
  func fetchDocumentVerificationStatus(_ verification: Verification,
                                       callback: @escaping Result<Verification, NSError>.Callback) {
    fetchDocumentVerificationStatusCalled = true
    lastFetchDocumentVerificationStatusVerification = verification
    if let result = nextFetchDocumentVerificationStatusResult {
      callback(result)
    }
  }

  var nextFetchVerificationStatusResult: Result<Verification, NSError>?
  private(set) var fetchVerificationStatusCalled = false
  private(set) var lastFetchVerificationStatusVerification: Verification?
  func fetchVerificationStatus(_ verification: Verification,
                               callback: @escaping Result<Verification, NSError>.Callback) {
    fetchVerificationStatusCalled = true
    lastFetchVerificationStatusVerification = verification
    if let result = nextFetchVerificationStatusResult {
      callback(result)
    }
  }

  var nextRestartVerificationResult: Result<Verification, NSError>?
  private(set) var restartVerificationCalled = false
  private(set) var lastRestartVerificationVerification: Verification?
  func restartVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback) {
    restartVerificationCalled = true
    lastRestartVerificationVerification = verification
    if let result = nextRestartVerificationResult {
      callback(result)
    }
  }

  var nextCompleteVerificationResult: Result<Verification, NSError>?
  private(set) var completeVerificationCalled = false
  private(set) var lastCompleteVerificationVerification: Verification?
  func completeVerification(_ verification: Verification, callback: @escaping Result<Verification, NSError>.Callback) {
    completeVerificationCalled = true
    lastCompleteVerificationVerification = verification
    if let result = nextCompleteVerificationResult {
      callback(result)
    }
  }

  // MARK: - Card application handling

  var nextNextCardApplicationsResult: Result<[CardApplication], NSError>?
  private(set) var nextCardApplicationsCalled = false
  private(set) var lastNextCardApplicationsPage: Int?
  private(set) var lastNextCardApplicationsRows: Int?
  func nextCardApplications(page: Int, rows: Int, callback: @escaping Result<[CardApplication], NSError>.Callback) {
    nextCardApplicationsCalled = true
    lastNextCardApplicationsPage = page
    lastNextCardApplicationsRows = rows
    if let result = nextNextCardApplicationsResult {
      callback(result)
    }
  }

  var nextApplyToCardResult: Result<CardApplication, NSError>?
  private(set) var applyToCardCalled = false
  private(set) var lastApplyToCardCardProduct: CardProduct?
  func applyToCard(cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback) {
    applyToCardCalled = true
    lastApplyToCardCardProduct = cardProduct
    if let result = nextApplyToCardResult {
      callback(result)
    }
  }

  var nextFetchCardApplicationStatusResult: Result<CardApplication, NSError>?
  private(set) var fetchCardApplicationStatusCalled = false
  private(set) var lastFetchCardApplicationStatusApplicationId: String?
  func fetchCardApplicationStatus(_ applicationId: String,
                                  callback: @escaping Result<CardApplication, NSError>.Callback) {
    fetchCardApplicationStatusCalled = true
    lastFetchCardApplicationStatusApplicationId = applicationId
    if let result = nextFetchCardApplicationStatusResult {
      callback(result)
    }
  }

  var nextSetBalanceStoreResult: Result<SelectBalanceStoreResult, NSError>?
  private(set) var setBalanceStoreCalled = false
  private(set) var lastSetBalanceStoreApplicationId: String?
  private(set) var lastSetBalanceStoreCustodian: Custodian?
  func setBalanceStore(applicationId: String, custodian: Custodian,
                       callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {
    setBalanceStoreCalled = true
    lastSetBalanceStoreApplicationId = applicationId
    lastSetBalanceStoreCustodian = custodian
    if let result = nextSetBalanceStoreResult {
      callback(result)
    }
  }

  var nextAcceptDisclaimerResult: Result<Void, NSError>?
  private(set) var acceptDisclaimerCalled = false
  private(set) var lastAcceptDisclaimerWorkflowObject: WorkflowObject?
  private(set) var lastAcceptDisclaimerWorkflowAction: WorkflowAction?
  func acceptDisclaimer(workflowObject: WorkflowObject, workflowAction: WorkflowAction,
                        callback: @escaping Result<Void, NSError>.Callback) {
    acceptDisclaimerCalled = true
    lastAcceptDisclaimerWorkflowObject = workflowObject
    lastAcceptDisclaimerWorkflowAction = workflowAction
    if let result = nextAcceptDisclaimerResult {
      callback(result)
    }
  }

  var nextCancelCardApplicationResult: Result<Void, NSError>?
  private(set) var cancelCardApplicationCalled = false
  private(set) var lastCancelCardApplicationApplicationId: String?
  func cancelCardApplication(_ applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {
    cancelCardApplicationCalled = true
    lastCancelCardApplicationApplicationId = applicationId
    if let result = nextCancelCardApplicationResult {
      callback(result)
    }
  }

  var nextIssueCardResult: Result<Card, NSError>?
  private(set) var issueCardCalled = false
  private(set) var lastIssueCardApplicationId: String?
  func issueCard(applicationId: String, callback: @escaping Result<Card, NSError>.Callback) {
    issueCardCalled = true
    lastIssueCardApplicationId = applicationId
    if let result = nextIssueCardResult {
      callback(result)
    }
  }

  private(set) var issueCardWithCustodianCalled = false
  private(set) var lastIssueCardCardProduct: CardProduct?
  private(set) var lastIssueCardCustodian: Custodian?
  private(set) var lastIssueCardAdditionalFields: [String: AnyObject]?
  func issueCard(cardProduct: CardProduct, custodian: Custodian?, additionalFields: [String: AnyObject]? = nil,
                 callback: @escaping Result<Card, NSError>.Callback) {
    issueCardWithCustodianCalled = true
    lastIssueCardCardProduct = cardProduct
    lastIssueCardCustodian = custodian
    lastIssueCardAdditionalFields = additionalFields
    if let result = nextIssueCardResult {
      callback(result)
    }
  }

  // MARK: - Card handling

  var nextFetchCardsResult: Result<[Card], NSError>?
  private(set) var fetchCardsCalled = false
  private(set) var lastFetchCardsPage: Int?
  private(set) var lastFetchCardsRows: Int?
  func fetchCards(page: Int, rows: Int, callback: @escaping Result<[Card], NSError>.Callback) {
    fetchCardsCalled = true
    lastFetchCardsPage = page
    lastFetchCardsRows = rows
    if let result = nextFetchCardsResult {
      callback(result)
    }
  }

  var nextFetchFinancialAccountResult: Result<FinancialAccount, NSError>?
  private(set) var fetchFinancialAccountCalled = false
  private(set) var lastFetchFinancialAccountAccountId: String?
  private(set) var lastFetchFinancialAccountForceRefresh: Bool?
  private(set) var lastFetchFinancialAccountRetrieveBalances: Bool?
  func fetchFinancialAccount(_ accountId: String, forceRefresh: Bool, retrieveBalances: Bool,
                             callback: @escaping Result<FinancialAccount, NSError>.Callback) {
    fetchFinancialAccountCalled = true
    lastFetchFinancialAccountAccountId = accountId
    lastFetchFinancialAccountForceRefresh = forceRefresh
    lastFetchFinancialAccountRetrieveBalances = retrieveBalances
    if let result = nextFetchFinancialAccountResult {
      callback(result)
    }
  }

  var nextFetchCardDetailsResult: Result<CardDetails, NSError>?
  private(set) var fetchCardDetailsCalled = false
  private(set) var lastFetchCardDetailsCardId: String?
  func fetchCardDetails(_ cardId: String, callback: @escaping Result<CardDetails, NSError>.Callback) {
    fetchCardDetailsCalled = true
    lastFetchCardDetailsCardId = cardId
    if let result = nextFetchCardDetailsResult {
      callback(result)
    }
  }

  var nextActivatePhysicalCardResult: Result<PhysicalCardActivationResult, NSError>?
  private(set) var activatePhysicalCardCalled = false
  private(set) var lastActivatePhysicalCardCardId: String?
  private(set) var lastActivatePhysicalCardCode: String?
  func activatePhysicalCard(_ cardId: String, code: String,
                            callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
    activatePhysicalCardCalled = true
    lastActivatePhysicalCardCardId = cardId
    lastActivatePhysicalCardCode = code
    if let result = nextActivatePhysicalCardResult {
      callback(result)
    }
  }

  var nextActivateCardResult: Result<Card, NSError>?
  private(set) var activateCardCalled = false
  private(set) var lastActivateCardCardId: String?
  func activateCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    activateCardCalled = true
    lastActivateCardCardId = cardId
    if let result = nextActivateCardResult {
      callback(result)
    }
  }

  var nextUnlockCardResult: Result<Card, NSError>?
  private(set) var unlockCardCalled = false
  private(set) var lastUnlockCardCardId: String?
  func unlockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    unlockCardCalled = true
    lastUnlockCardCardId = cardId
    if let result = nextUnlockCardResult {
      callback(result)
    }
  }

  var nextLockCardResult: Result<Card, NSError>?
  private(set) var lockCardCalled = false
  private(set) var lastLockCardCardId: String?
  func lockCard(_ cardId: String, callback: @escaping Result<Card, NSError>.Callback) {
    lockCardCalled = true
    lastLockCardCardId = cardId
    if let result = nextLockCardResult {
      callback(result)
    }
  }

  var nextChangeCardPINResult: Result<Card, NSError>?
  private(set) var changeCardPINCalled = false
  private(set) var lastChangeCardPINCardId: String?
  private(set) var lastChangeCardPINPIN: String?
  func changeCardPIN(_ cardId: String, pin: String, callback: @escaping Result<Card, NSError>.Callback) {
    changeCardPINCalled = true
    lastChangeCardPINCardId = cardId
    lastChangeCardPINPIN = pin
    if let result = nextChangeCardPINResult {
      callback(result)
    }
  }

  var nextFetchCardTransactionsResult: Result<[Transaction], NSError>?
  private(set) var fetchCardTransactionsCalled = false
  private(set) var lastFetchCardTransactionsCardId: String?
  private(set) var lastFetchCardTransactionsFilters: TransactionListFilters?
  private(set) var lastFetchCardTransactionsForceRefresh: Bool?
  func fetchCardTransactions(_ cardId: String, filters: TransactionListFilters, forceRefresh: Bool,
                             callback: @escaping Result<[Transaction], NSError>.Callback) {
    fetchCardTransactionsCalled = true
    lastFetchCardTransactionsCardId = cardId
    lastFetchCardTransactionsFilters = filters
    lastFetchCardTransactionsForceRefresh = forceRefresh
    if let result = nextFetchCardTransactionsResult {
      callback(result)
    }
  }

  var nextCardMonthlySpendingResult: Result<MonthlySpending, NSError>?
  private(set) var cardMonthlySpendingCalled = false
  private(set) var lastCardMonthlySpendingCardId: String?
  private(set) var lastCardMonthlySpendingDate: Date?
  func cardMonthlySpending(_ cardId: String, date: Date,
                           callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    cardMonthlySpendingCalled = true
    lastCardMonthlySpendingCardId = cardId
    lastCardMonthlySpendingDate = date
    if let result = nextCardMonthlySpendingResult {
      callback(result)
    }
  }

  // MARK: - Card funding sources handling
  var nextFetchCardFundingSourcesResult: Result<[FundingSource], NSError>?
  private(set) var fetchCardFundingSourcesCalled = false
  private(set) var lastFetchCardFundingSourcesCardId: String?
  private(set) var lastFetchCardFundingSourcesPage: Int?
  private(set) var lastFetchCardFundingSourcesRows: Int?
  private(set) var lastFetchCardFundingSourcesForceRefresh: Bool?
  func fetchCardFundingSources(_ cardId: String, page: Int?, rows: Int?, forceRefresh: Bool,
                               callback: @escaping Result<[FundingSource], NSError>.Callback) {
    fetchCardFundingSourcesCalled = true
    lastFetchCardFundingSourcesCardId = cardId
    lastFetchCardFundingSourcesPage = page
    lastFetchCardFundingSourcesRows = rows
    lastFetchCardFundingSourcesForceRefresh = forceRefresh
    if let result = nextFetchCardFundingSourcesResult {
      callback(result)
    }
  }

  var nextFetchCardFundingSourceResult: Result<FundingSource?, NSError>?
  private(set) var fetchCardFundingSourceCalled = false
  private(set) var lastFetchCardFundingSourceCardId: String?
  private(set) var lastFetchCardFundingSourceForceRefresh: Bool?
  func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool,
                              callback: @escaping Result<FundingSource?, NSError>.Callback) {
    fetchCardFundingSourceCalled = true
    lastFetchCardFundingSourceCardId = cardId
    lastFetchCardFundingSourceForceRefresh = forceRefresh
    if let result = nextFetchCardFundingSourceResult {
      callback(result)
    }
  }

  var nextSetCardFundingSourceResult: Result<FundingSource, NSError>?
  private(set) var setCardFundingSourceCalled = false
  private(set) var lastSetCardFundingSourceFundingSourceId: String?
  private(set) var lastSetCardFundingSourceCardId: String?
  func setCardFundingSource(_ fundingSourceId: String, cardId: String,
                            callback: @escaping Result<FundingSource, NSError>.Callback) {
    setCardFundingSourceCalled = true
    lastSetCardFundingSourceFundingSourceId = fundingSourceId
    lastSetCardFundingSourceCardId = cardId
    if let result = nextSetCardFundingSourceResult {
      callback(result)
    }
  }

  var nextAddCardFundingSourceResult: Result<FundingSource, NSError>?
  private(set) var addCardFundingSourceCalled = false
  private(set) var lastAddCardFundingSourceCardId: String?
  private(set) var lastAddCardFundingSourceCustodian: Custodian?
  func addCardFundingSource(cardId: String, custodian: Custodian,
                            callback: @escaping Result<FundingSource, NSError>.Callback) {
    addCardFundingSourceCalled = true
    lastAddCardFundingSourceCardId = cardId
    lastAddCardFundingSourceCustodian = custodian
    if let result = nextAddCardFundingSourceResult {
      callback(result)
    }
  }

  // MARK: - Notification preferences handling

  var nextFetchNotificationPreferencesResult: Result<NotificationPreferences, NSError>?
  private(set) var fetchNotificationPreferencesCalled = false
  func fetchNotificationPreferences(callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    fetchNotificationPreferencesCalled = true
    if let result = nextFetchNotificationPreferencesResult {
      callback(result)
    }
  }

  var nextUpdateNotificationPreferencesResult: Result<NotificationPreferences, NSError>?
  private(set) var updateNotificationPreferencesCalled = false
  private(set) var lastUpdateNotificationPreferencesPreferences: NotificationPreferences?
  func updateNotificationPreferences(_ preferences: NotificationPreferences,
                                     callback: @escaping Result<NotificationPreferences, NSError>.Callback) {
    updateNotificationPreferencesCalled = true
    lastUpdateNotificationPreferencesPreferences = preferences
    if let result = nextUpdateNotificationPreferencesResult {
      callback(result)
    }
  }

  // MARK: - VoIP
  var nextFetchVoIPTokenResult: Result<VoIPToken, NSError>?
  private(set) var fetchVoIPTokenCalled = false
  private(set) var lastFetchVoIPTokenCardId: String?
  private(set) var lastFetchVoIPTokenActionSource: VoIPActionSource?
  func fetchVoIPToken(cardId: String, actionSource: VoIPActionSource,
                      callback: @escaping Result<VoIPToken, NSError>.Callback) {
    fetchVoIPTokenCalled = true
    lastFetchVoIPTokenCardId = cardId
    lastFetchVoIPTokenActionSource = actionSource
    if let result = nextFetchVoIPTokenResult {
      callback(result)
    }
  }

  // MARK: Miscelaneous
  private(set) var runPendingNetworkRequestsCalled = false
  func runPendingNetworkRequests() {
    runPendingNetworkRequestsCalled = true
  }
}
