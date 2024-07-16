//
//  AppointmentCell.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit
import Combine

final class AppointmentCell: UICollectionViewCell, ReusableView {

    // MARK: - UI Elements

    private lazy var contentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [topContentStackView, zoomButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .leading
        sv.distribution = .fill
        sv.setContentHuggingPriority(.required, for: .vertical)
        return sv
    }()

    private lazy var topContentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [monthDayView, labelsStackView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .leading
        sv.distribution = .fill
        sv.setContentHuggingPriority(.required, for: .vertical)
        return sv
    }()

    private lazy var labelsStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, timeRangeLabel, repeatingLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .leading
        sv.distribution = .fill
        sv.setContentHuggingPriority(.required, for: .vertical)
        return sv
    }()

    private lazy var monthDayView: MonthDayView = {
        let view = MonthDayView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = "Placeholder\ntitle"
        return label
    }()

    private lazy var timeRangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        return label
    }()

    private lazy var repeatingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        return label
    }()

    // Button currently does nothing
    private lazy var zoomButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemBlue
        btn.setTitle("Join Zoom", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.isHidden = true
        return btn
    }()

    // MARK: - Properties

    var subscribers: Set<AnyCancellable> = []
    @Published public var appointmentSelected: Bool = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        
        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            zoomButton.heightAnchor.constraint(equalToConstant: 45),
            zoomButton.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            monthDayView.widthAnchor.constraint(equalToConstant: 48)
        ])
    }

    public func fillOut(with appointment: Appointment, isSelected: Bool = false) {
        titleLabel.text = "\(appointment.appointment_type) with \(appointment.dietitianName)"
        timeRangeLabel.text = appointment.timeRangeString

        if let image = UIImage(systemName: "calendar") {
            repeatingLabel.attributedText = AttributedStringUtils.createAttributedString(with: image, and: appointment.recurrence_type)
        } else {
            repeatingLabel.attributedText = NSAttributedString(string: appointment.recurrence_type)
        }
        zoomButton.isHidden = !isSelected
        monthDayView.fillOut(with: appointment.start)
        contentView.layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscribers = []
    }

}
