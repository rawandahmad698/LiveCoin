//
//  ViewController.swift
//  LiveStockPrices
//
//  Created by Rawand Ahmad on 15/08/2023.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    // Views
    @IBOutlet weak var btcUsdCurrentView: UIView!
    @IBOutlet weak var btcUsdHighView: UIView!
    @IBOutlet weak var btcUsdLowView: UIView!
    
    // Labels
    @IBOutlet weak var UsdCurrent: UILabel!
    @IBOutlet weak var UsdHigh: UILabel!
    @IBOutlet weak var UsdLow: UILabel!
    
    private let viewModel = CryptoViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindViewModel()
    }
    
    private func configureUI() {
        setupBorders()
    }
    
    private func setupBorders() {
        btcUsdCurrentView.setBorderWithHexColor(hexColor: "FFD649", borderWidth: 3)
        btcUsdHighView.setBorderWithHexColor(hexColor: "FFD649", borderWidth: 2)
        btcUsdLowView.setBorderWithHexColor(hexColor: "FFD649", borderWidth: 2)
    }
    
    private func bindViewModel() {
        viewModel.cryptoData
            .map { response in
                guard let response = response else {
                    return ("N/A", "N/A", "N/A")
                }
                return (String(format: "%.2f", response.currentBTC),
                        String(format: "%.2f", response.currentBTCHigh),
                        String(format: "%.2f", response.currentBTCLow))
            }
            .bind(to: Binder(self) { viewController, values in
                viewController.UsdCurrent.formatCurrency(amount: values.0)
                viewController.UsdHigh.formatCurrency(amount: values.1)
                viewController.UsdLow.formatCurrency(amount: values.2)
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { errorMessage in
                self.presentErrorMessage(errorMessage)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
