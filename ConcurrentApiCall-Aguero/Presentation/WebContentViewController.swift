//
//  ViewController.swift
//  ConcurrentApiCall-Aguero
//
//  Created by ignacia on 08/08/2024.
//

import UIKit
import Combine

class WebContentViewController: UIViewController {
    private var viewModel = WebContentViewModel(service: WebContentService())
    private var cancellable = Set<AnyCancellable>()
    private var loadingView: UIView!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var every10thTitle: UILabel!
    @IBOutlet weak var wordCounterTitle: UILabel!
    @IBOutlet weak var every10thAnswer: UILabel!
    @IBOutlet weak var wordCounterAnswer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        combineSubscriptions()
    }
    
    func setupView() {
        title = "Concurrent API Calls"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1)
        startButton.backgroundColor = UIColor(red: 0.075, green: 0.184, blue: 0.961, alpha: 1)
        startButton.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        startButton.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        startButton.layer.cornerRadius = 14
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor(red: 0.075, green: 0.184, blue: 0.961, alpha: 1).cgColor
        startButton.setTitle("Let's begin!", for: .normal)
        every10thTitle.text = "Every 10th character result:"
        wordCounterTitle.text = "Word counter result:"
        every10thAnswer.text = "The result will be displayed here"
        wordCounterAnswer.text = "The result will be displayed here"
        loadingView = UIView(frame: self.view.frame)
        loadingView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        loadingView.addSubview(createActivityView())
    }
    
    func combineSubscriptions() {
        viewModel.$isLoading.receive(on: RunLoop.main)
            .sink { [weak self] isloading in
                guard let self = self else { return }
                if isloading {
                    self.view.addSubview(self.loadingView)
                } else {
                    UIView.transition(with: self.loadingView, duration: 0.3, options: .transitionCrossDissolve) {
                        self.loadingView.removeFromSuperview()
                    }
                }
            }.store(in: &cancellable)
        viewModel.$wordCounterAnswer.receive(on: RunLoop.main)
            .sink { [weak self] answer in
                guard let self = self else { return }
                if let answer = answer, !answer.isEmpty {
                    self.wordCounterAnswer.text = String(answer.count)
                }
            }.store(in: &cancellable)
        viewModel.every10thAnswer.receive(on: RunLoop.main)
            .sink { [weak self] answer in
                guard let self = self else { return }
                self.every10thAnswer.text = answer
            }.store(in: &cancellable)
        viewModel.$showErrorAlert.receive(on: RunLoop.main)
            .sink { [weak self] show in
                guard let self = self else { return }
                if show {
                    self.showErrorAlert()
                }
            }.store(in: &cancellable)
    }
    
    private func createActivityView() -> UIView {
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "There was an error", message: "Please, try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func didTapStartButton(_ sender: Any) {
        viewModel.didTapStarButton()
    }
}

