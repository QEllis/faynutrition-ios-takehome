//
//  PageControlButtonView.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit
import Combine

final class PageControlButtonView: UIView {

    // MARK: - UI Elements

    /// The button that covers entire view and signals selection to owner
    public lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()

    private lazy var selectedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()

    // MARK: - Init

    init(title: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        setupUI()
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(selectedView)
        addSubview(button)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            selectedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            selectedView.heightAnchor.constraint(equalToConstant: 2)
        ])

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    public func setSelected(_ isSelected: Bool) {
        self.selectedView.isHidden = !isSelected
        self.titleLabel.textColor = isSelected ? .systemBlue : .black
    }

}
