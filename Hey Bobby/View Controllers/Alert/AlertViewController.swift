//
//  AlertViewController.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 19/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    // MARK: UI Outlets

    @IBOutlet weak var acknowledgeButtonView: UIView! {
        didSet {
            self.acknowledgeButtonView.backgroundColor = .clear
            self.acknowledgeButtonView.isHidden = (self.acknowledgeButtonHandler == nil)
        }
    }
    
    @IBOutlet weak var acknowledgeButton: UIButton! {
        didSet {
            self.acknowledgeButton.setTitle("Alert.Acknowledge".localized, for: .normal)
            self.acknowledgeButton.setTitleColor(.white, for: .normal)
            self.acknowledgeButton.backgroundColor = .clear
            self.acknowledgeButton.layer.borderColor = UIColor.white.cgColor
            self.acknowledgeButton.layer.borderWidth = 2.0
            self.acknowledgeButton.layer.cornerRadius = 4.0
            self.acknowledgeButton.addTarget(self, action: #selector(AlertViewController.acknowledgeButtonPressed(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var label: UILabel! {
        didSet {
            self.label.textColor = .white
            self.label.font = UIFont.systemFont(ofSize: 56.0)
            self.label.numberOfLines = 4
            self.label.minimumScaleFactor = 0.6
            self.label.adjustsFontSizeToFitWidth = true
            self.label.text = self.severity.alertMessage(alert: self.alert)
        }
    }

    // MARK: Properties

    private var alert: Alert!
    private var severity: Severity!
    private var acknowledgeButtonHandler: (() -> Void)?
    
    // MARK: Init

    init(alert: Alert, severity: Severity, acknowledgeButtonHandler: (() -> Void)? = nil) {
        self.alert = alert
        self.severity = severity
        self.acknowledgeButtonHandler = acknowledgeButtonHandler
        super.init(nibName: AlertViewController.className, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Alert.Title".localized

        self.view.backgroundColor = self.severity.color

        self.navigationItem.leftBarButtonItem = .imageBackButton(self, action: #selector(AlertViewController.backPressed(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Theme.statusBar?.backgroundColor = self.severity.color
        self.navigationController?.navigationBar.backgroundColor = self.severity.color
        self.navigationController?.navigationBar.barTintColor = self.severity.color
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Theme.statusBar?.backgroundColor = .primaryColor
        self.navigationController?.navigationBar.backgroundColor = .primaryColor
        self.navigationController?.navigationBar.barTintColor = .primaryColor
    }

    // MARK: UI Actions

    @objc func backPressed(_ sender: Any) {
        Theme.statusBar?.backgroundColor = .primaryColor
        self.navigationController?.navigationBar.backgroundColor = .primaryColor
        self.navigationController?.navigationBar.barTintColor = .primaryColor
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func acknowledgeButtonPressed(_ sender: Any) {
        self.acknowledgeButtonHandler?()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
