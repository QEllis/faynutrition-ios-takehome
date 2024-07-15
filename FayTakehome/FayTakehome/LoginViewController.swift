//
//  ViewController.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit
import Combine

class LoginViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var logoImv: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "FayNutritionNameLogo"))
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFit
        return imv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.text = "Log In"
        return label
    }()

    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Username"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return tf
    }()

    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Password"
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return tf
    }()

    private lazy var loginButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemBlue
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.isUserInteractionEnabled = false
        btn.alpha = 0.5
        return btn
    }()

    // MARK: - Properties

    private var subscribers: Set<AnyCancellable> = []
    private var loginButtonBottomConstraint: NSLayoutConstraint?

    struct Constants {
        static let LoginButtonBottomSpacing: CGFloat = 20
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupKeyboardDismissGesture()
        setupUI()
        setupSubscribers()
        addKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        triggerKeyboardOnAppear()
    }

    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(logoImv)
        view.addSubview(titleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            logoImv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            logoImv.heightAnchor.constraint(equalToConstant: 64)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            titleLabel.topAnchor.constraint(equalTo: logoImv.bottomAnchor, constant: 36)
        ])

        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            usernameTextField.heightAnchor.constraint(equalToConstant: 48)
        ])

        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 16),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48)
        ])

        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        loginButtonBottomConstraint = loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        loginButtonBottomConstraint?.isActive = true
    }

    private func setupSubscribers() {
        /// Controls state of `loginButton` based on username and password text fields
        usernameTextField.textPublisher()
            .combineLatest(passwordTextField.textPublisher())
            .map({ usernameText, passwordText in
                return usernameText.isEmpty || passwordText.isEmpty
            })
            .sink(receiveValue: { [weak self] usernameOrPasswordEmpty in
                self?.loginButton.isUserInteractionEnabled = !usernameOrPasswordEmpty
                self?.loginButton.alpha = usernameOrPasswordEmpty ? 0.5 : 1.0
            }).store(in: &subscribers)
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        loginButtonBottomConstraint?.constant = -notification.keyboardFrame().size.height - Constants.LoginButtonBottomSpacing
        view.layoutIfNeeded()
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        loginButtonBottomConstraint?.constant = -Constants.LoginButtonBottomSpacing
        view.layoutIfNeeded()
    }

    private func triggerKeyboardOnAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.usernameTextField.becomeFirstResponder()
        })
    }

    @objc private func backgroundTapped() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

}

