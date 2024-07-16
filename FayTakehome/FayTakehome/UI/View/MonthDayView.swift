//
//  MonthDayView.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit

/// Set up specially for `AppointmentCell`. Date displaying view sits in top middle
final class MonthDayView: UIView {

    // MARK: - UI Elements

    private lazy var dateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 10, weight: .light)
        return label
    }()

    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    // MARK: - Properties

    private let monthDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "MMM"
        return df
    }()

    private let dayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "dd"
        return df
    }()

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(dateView)
        dateView.addSubview(monthLabel)
        dateView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            dateView.topAnchor.constraint(equalTo: topAnchor),
            dateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateView.heightAnchor.constraint(equalTo: dateView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: dateView.topAnchor, constant: 4)
        ])

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor, constant: 4)
        ])
    }

    public func fillOut(with date: Date) {
        layoutIfNeeded()
        monthLabel.text = monthDateFormatter.string(from: date).uppercased()
        dayLabel.text = dayDateFormatter.string(from: date)
    }
}
