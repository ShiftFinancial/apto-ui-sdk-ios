//
//  TransactionListContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import Bond
import AptoSDK

struct TransactionListModuleConfig {
  let startDate: Date?
  let endDate: Date?
  let categoryId: MCCIcon?
}

protocol TransactionListModuleProtocol: UIModuleProtocol {
  func showDetails(of transaction: Transaction)
}

protocol TransactionListInteractorProtocol {
  func fetchTransactions(filters: TransactionListFilters, callback: @escaping Result<[Transaction], NSError>.Callback)
}

class TransactionListViewModel {
  let title: Observable<String?> = Observable(nil)
  let transactions: MutableObservableArray2D<String, Transaction> = MutableObservableArray2D(Array2D())
}

protocol TransactionListPresenterProtocol: class {
  var viewModel: TransactionListViewModel { get }
  var router: TransactionListModuleProtocol? { get set }
  var interactor: TransactionListInteractorProtocol? { get set }
  var analyticsManager: AnalyticsServiceProtocol? { get set }

  func viewLoaded()
  func closeTapped()
  func reloadData()
  func loadMoreTransactions(completion: @escaping (_ noMoreTransactions: Bool) -> Void)
  func transactionSelected(_ transaction: Transaction)
}
