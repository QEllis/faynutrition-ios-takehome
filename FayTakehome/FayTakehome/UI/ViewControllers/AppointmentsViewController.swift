//
//  AppointmentsViewController.swift
//  FayTakehome
//
//  Created by Quinn Ellis on 7/15/24.
//

import UIKit
import Combine

final class AppointmentsViewController: UIViewController {

    private struct AppointmentCellData: Hashable {
        let appointment: Appointment
        let isSelected: Bool
    }

    // MARK: - UI Elements

    private lazy var logoImv: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "FayNutritionNameLogo"))
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.contentMode = .scaleAspectFit
        return imv
    }()

    private lazy var topDividerLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.1)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.text = "Appointments"
        return label
    }()

    private lazy var modeControlStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [upcomingModeButton, pastModeButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .leading
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var upcomingModeButton: PageControlButtonView = {
        let view = PageControlButtonView(title: "Upcoming")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.button.addTarget(self, action: #selector(upcomingModePressed), for: .touchUpInside)
        return view
    }()

    private lazy var pastModeButton: PageControlButtonView = {
        let view = PageControlButtonView(title: "Past")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.button.addTarget(self, action: #selector(pastModePressed), for: .touchUpInside)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.register(AppointmentCell.self, forCellWithReuseIdentifier: AppointmentCell.defaultReuseIdentifier)
        return collectionView
    }()
    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = { return createLayout() }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.translatesAutoresizingMaskIntoConstraints = false
        ind.color = .systemBlue
        ind.hidesWhenStopped = true
        return ind
    }()

    // MARK: - Properties

    enum ViewingMode {
        case upcoming
        case past
    }
    @Published private var viewingMode: ViewingMode = .upcoming

    var subscribers: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<Int, AppointmentCellData>?
    @Published private var upcomingAppointments: [Appointment] = []
    @Published private var pastAppointments: [Appointment] = []
    @Published private var selectedAppointment: Appointment?

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        setupSubscribers()
        fetchAppointments()
        feedbackGenerator.prepare()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(logoImv)
        view.addSubview(topDividerLine)
        view.addSubview(titleLabel)
        view.addSubview(modeControlStackView)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            logoImv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImv.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoImv.heightAnchor.constraint(equalToConstant: 35),
            logoImv.widthAnchor.constraint(equalTo: logoImv.heightAnchor, multiplier: 2.87)
        ])

        NSLayoutConstraint.activate([
            topDividerLine.topAnchor.constraint(equalTo: logoImv.bottomAnchor, constant: 8),
            topDividerLine.heightAnchor.constraint(equalToConstant: 1),
            topDividerLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topDividerLine.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: topDividerLine.bottomAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            modeControlStackView.heightAnchor.constraint(equalToConstant: 48),
            modeControlStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modeControlStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        ])
        upcomingModeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: modeControlStackView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] in
            self?.cellProvider(collectionView: $0, indexPath: $1, appointmentData: $2)
        })

        let viewingModeAndSelectedPublisher = $viewingMode.removeDuplicates().combineLatest($selectedAppointment.removeDuplicates()).eraseToAnyPublisher()

        viewingModeAndSelectedPublisher
            .combineLatest($upcomingAppointments, $pastAppointments)
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: { [weak self] modeAndSelected, upcoming, past in
                guard let self else { return }
                let appointmentsToShow: [Appointment] = (modeAndSelected.0 == .upcoming) ? upcoming : past
                var snapshot = NSDiffableDataSourceSnapshot<Int, AppointmentCellData>()
                snapshot.appendSections([0])
                let data: [AppointmentCellData] = appointmentsToShow.map({ AppointmentCellData(appointment: $0, isSelected: $0 == modeAndSelected.1) })
                snapshot.appendItems(data, toSection: 0)
                UIView.performWithoutAnimation({
                    self.dataSource?.apply(snapshot, animatingDifferences: true)
                })
            }).store(in: &subscribers)
    }

    private func setupSubscribers() {
        $viewingMode.removeDuplicates().sink(receiveValue: { [weak self] currentMode in
            self?.upcomingModeButton.setSelected(currentMode == .upcoming)
            self?.pastModeButton.setSelected(currentMode == .past)
        }).store(in: &subscribers)
    }

    private func cellProvider(collectionView: UICollectionView, indexPath: IndexPath, appointmentData: AppointmentCellData) -> UICollectionViewCell? {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppointmentCell.defaultReuseIdentifier, for: indexPath) as? AppointmentCell else { return nil }
        cell.fillOut(with: appointmentData.appointment, isSelected: appointmentData.isSelected)
        return cell
    }

    private func startLoading() {
        loadingIndicator.startAnimating()
    }

    private func stopLoading() {
        loadingIndicator.stopAnimating()
    }

    private func fetchAppointments() {
        startLoading()
        Server.shared.fetchAppointments(completion: { [weak self] appointments, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.stopLoading()
                self.upcomingAppointments = appointments.filter({ $0.isUpcoming })
                self.pastAppointments = appointments.filter({ !$0.isUpcoming })
            }
        })
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let thisSection = NSCollectionLayoutSection(group: group)
            thisSection.interGroupSpacing = 16
            thisSection.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
            return thisSection
        }, configuration: configuration)
        return layout
    }

    @objc private func upcomingModePressed() {
        viewingMode = .upcoming
    }

    @objc private func pastModePressed() {
        viewingMode = .past
    }
}

// MARK: - UICollectionViewDelegate

extension AppointmentsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let snapshot = dataSource?.snapshot(), snapshot.numberOfItems(inSection: 0) > indexPath.item else { return }

        feedbackGenerator.impactOccurred()

        let selectedAppointment = snapshot.itemIdentifiers(inSection: 0)[indexPath.item]
        if self.selectedAppointment == selectedAppointment.appointment {
            self.selectedAppointment = nil // Deselect currently selected
        } else {
            self.selectedAppointment = selectedAppointment.appointment
        }
    }
}
