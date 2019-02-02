//
//  SQStoreViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 1/27/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import StoreKit

extension NSNotification.Name {
    static let didBuyFullPack = "didBuyFullPack"
}

class SQStoreViewController: UIViewController {
    
    enum StoreAction: Int {
        case buy, restore = 1, none
    }
    
    lazy var slideInTransitioningDelegate =  SlideInPresentationManager()
    
    var productRequest: SKProductsRequest!
    var product: SKProduct? {
        didSet {
            if let product = self.product {
                numberFormatter.locale = product.priceLocale
                self.buyButton.setTitle("\(numberFormatter.string(from: product.price)!)", for: .normal)
                self.restoreButton.setTitle(Labels.restore, for: .normal)
            }
        }
    }
    
    lazy var numberFormatter: NumberFormatter! = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var requesting: Bool = false
    
    var action: StoreAction = .none
    
    //MARK: Outlets and Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPresentation()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupPresentation()
    }
    
    fileprivate func setupPresentation(){
        self.transitioningDelegate = slideInTransitioningDelegate
        self.modalPresentationStyle = .custom
    }
    
    //MARK: Super and methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.textColor = Colors.title
        topSeparatorView.backgroundColor = Colors.semiWhite
        contentsLabel.textColor = Colors.contents
        buyButton.backgroundColor = Colors.tint
        restoreButton.tintColor = Colors.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.requesting {
            cancelRequest()
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func startRequest(){
        productRequest = SKProductsRequest.init(productIdentifiers: [kProductIdentifier])
        productRequest.delegate = self
        productRequest.start()
        requesting = true
        
        updateViewsForInProgressState(inProgress: true)
    }
    
    fileprivate func cancelRequest(){
        self.productRequest.cancel()
    }
    
    fileprivate func buyProduct(){
        guard let product = self.product else { return }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    fileprivate func restorePurchases(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    fileprivate func handleError(error: NSError?){
        guard let error = error else {
            showErrorMessage(ErrorMessages.cantAccessStore)
            delay(3) {
                self.dismiss()
            }
            return
        }
        
        /* display a localized error message, dismiss the store VC! */
        SKPaymentQueue.default().remove(self)
        showErrorMessage(error.localizedDescription)
        delay(3) {
            self.dismiss()
        }
    }
    
    fileprivate func updateViewsForInProgressState(inProgress: Bool){
        
        self.buyButton.isHidden = inProgress ? true : false
        self.restoreButton.isHidden = inProgress ? true : false
        inProgress ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    fileprivate func unlockProduct(){
        handleSuccessOperation()
    }
    
    fileprivate func handleSuccessOperation(){
        /* display a success message, dismiss the store VC! */
        SQPickingManager.unlockAllContent()
        showMessage(Messages.StoreStuff.success, color: UIColor.emerald)
        SKPaymentQueue.default().remove(self)
        delay(3) {
            self.dismiss()
        }
    }
}

extension SQStoreViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.invalidProductIdentifiers.count > 0 {
            handleError(error: nil)
            return
        }
        
        self.requesting = false
        self.product = response.products.first
        
        updateViewsForInProgressState(inProgress: false)
        switch action {
        case .buy:
            self.buyProduct()
        case .restore:
            self.restorePurchases()
        default:
            break
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        /* Display error!! */
        handleError(error: error as NSError?)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let transaction = transactions.first!
        switch transaction.transactionState {
        case .purchased:
            SKPaymentQueue.default().finishTransaction(transaction)
            updateViewsForInProgressState(inProgress: false)
            unlockProduct()
            break
        case .failed:
            handleError(error: transaction.error as NSError?)
            break
        case .deferred:
            updateViewsForInProgressState(inProgress: true)
            break
        case .purchasing:
            updateViewsForInProgressState(inProgress: true)
            break
        case .restored:
            SKPaymentQueue.default().finishTransaction(transaction)
            updateViewsForInProgressState(inProgress: false)
            unlockProduct()
            break
        }
    }
}

extension SQStoreViewController {
    @IBAction func buyButtonTap(){
        buyProduct()
    }
    
    @IBAction func restoreButtonTap(){
        restorePurchases()
    }
}
