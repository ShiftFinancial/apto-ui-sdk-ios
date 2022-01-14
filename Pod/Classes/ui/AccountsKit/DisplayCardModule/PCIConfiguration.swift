import AptoSDK

struct PCIConfiguration: Equatable {
    let apiKey: String
    let userToken: String
    let cardId: String
    let lastFour: String
    let environment: AptoPlatformEnvironment
    let name: String?

    // swiftlint:disable force_unwrapping
    init(apiKey: String = AptoPlatform.defaultManager().apiKey,
         userToken: String = AptoPlatform.defaultManager().currentToken()!.token,
         cardId: String,
         lastFour: String,
         name: String?,
         environment: AptoPlatformEnvironment = AptoPlatform.defaultManager().environment)
    {
        self.apiKey = apiKey
        self.userToken = userToken
        self.cardId = cardId
        self.lastFour = lastFour
        self.name = name
        self.environment = environment
    }
    // swiftlint:enable force_unwrapping
}
