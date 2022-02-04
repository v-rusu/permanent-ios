//
//  PublicProfileAddMilestonesViewController.swift
//  Permanent
//
//  Created by Lucian Cerbu on 01.02.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class PublicProfileAddMilestonesViewController: BaseViewController<PublicProfilePageViewModel> {
    var milestone: MilestoneProfileItem?
    var isNewItem: Bool {
        return milestone == nil ? true : false
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleHintLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var startDateHintLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var endDateHintLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var descriptionHintLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationHintLabel: UILabel!
    @IBOutlet weak var mapView: UIView!
    
    var map: GMSMapView!
    var marker: GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        initUI()
        
        titleTextField.delegate = self
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        descriptionTextField.delegate = self
        locationTextField.delegate = self
        
        setFieldValues()
        initMapView()
        addDismissKeyboardGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        view.endEditing(true)
    }
    
    func initUI() {
        title = isNewItem ? "Add Milestone".localized() : "Edit Milestone".localized()
        let titleLabels = [titleLabel, startDateLabel, endDateLabel, descriptionLabel, locationLabel]
        let textFields = [titleTextField, startDateTextField, endDateTextField, descriptionTextField, locationTextField]
        let hintLabels = [titleHintLabel, startDateHintLabel, endDateHintLabel, descriptionHintLabel, locationHintLabel]
        
        for label in titleLabels {
            label?.textColor = .middleGray
            label?.font = Text.style12.font
        }
        
        for textField in textFields {
            textField?.layer.borderColor = UIColor.lightGray.cgColor
            textField?.layer.borderWidth = 0.5
            textField?.layer.cornerRadius = 3
            textField?.textColor = .middleGray
            textField?.font = Text.style7.font
        }
        
        for label in hintLabels {
            label?.textColor = .lightGray
            label?.font = Text.style8.font
            label?.textAlignment = .left
        }
        
        titleLabel.text = "\(ProfilePageData.milestoneTitle()) (<COUNT>/140)".localized().replacingOccurrences(of: "<COUNT>", with: "\(milestone?.title?.count ?? 0)")
        startDateLabel.text = ProfilePageData.milestoneStartDate()
        endDateLabel.text = ProfilePageData.milestoneEndDate()
        descriptionLabel.text = "\(ProfilePageData.milestoneDescription()) (<COUNT>/200)".localized().replacingOccurrences(of: "<COUNT>", with: "\(milestone?.description?.count ?? 0)")
        locationLabel.text = ProfilePageData.milestoneLocation()
        
        titleHintLabel.text = ProfilePageData.milestoneTitleHint()
        startDateHintLabel.text = ProfilePageData.milestoneStartDateHint()
        endDateHintLabel.text = ProfilePageData.milestoneEndDateHint()
        descriptionHintLabel.text = ProfilePageData.milestoneDescriptionHint()
        locationHintLabel.text = ProfilePageData.milestoneLocationHint()
        
        setupDatePickers()
    }
    
    func setupNavigationBar() {
        styleNavBar()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeButtonAction(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonAction(_:)))
    }
    
    func setFieldValues() {
        if !isNewItem {
            setInitialLabelValueForTextField(titleTextField, value: milestone?.title, associatedLabel: titleHintLabel)
            setInitialLabelValueForTextField(startDateTextField, value: milestone?.startDate, associatedLabel: startDateHintLabel)
            setInitialLabelValueForTextField(endDateTextField, value: milestone?.endDate, associatedLabel: endDateHintLabel)
            setInitialLabelValueForTextField(descriptionTextField, value: milestone?.description, associatedLabel: descriptionHintLabel)
            setInitialLabelValueForTextField(locationTextField, value: milestone?.locationFormated, associatedLabel: locationHintLabel)
        }
    }
    
    func setupDatePicker(dateDidChange: Selector, dateDoneButtonPressed: Selector, savedDate: String?) -> UIStackView {
        let dateFormatter = DateFormatter()
        var date = dateFormatter.date(from: "")
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        date = dateFormatter.date(from: savedDate ?? "")
        
        let datePicker = UIDatePicker()
        datePicker.date = date ?? Date()
        datePicker.addTarget(self, action: dateDidChange, for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.sizeToFit()
        
        let doneContainerView = UIView(frame: CGRect(x: 0, y: 0, width: datePicker.frame.width, height: 40))
        let doneButton = RoundedButton(frame: CGRect(x: datePicker.frame.width - 92, y: 0, width: 90, height: doneContainerView.frame.height))
        doneButton.autoresizingMask = [.flexibleLeftMargin]
        doneButton.setup()
        doneButton.setFont(UIFont.systemFont(ofSize: 17))
        doneButton.configureActionButtonUI(title: "done", bgColor: .systemBlue)
        doneButton.addTarget(self, action: dateDoneButtonPressed, for: .touchUpInside)
        doneContainerView.addSubview(doneButton)
        
        let stackView = UIStackView(arrangedSubviews: [datePicker, doneContainerView])
        stackView.axis = .vertical
        stackView.frame = CGRect(x: 0, y: 0, width: datePicker.frame.width, height: datePicker.frame.height + doneContainerView.frame.height + 40)
        
        return stackView
    }
    
    func setInitialLabelValueForTextField(_ textField: UITextField, value: String?, associatedLabel: UILabel) {
        if let savedValue = value,
            savedValue.isNotEmpty {
            textField.text = savedValue
            associatedLabel.isHidden = true
        } else {
            associatedLabel.isHidden = false
        }
    }
    
    func setupDatePickers() {
        startDateTextField.inputView = setupDatePicker(dateDidChange: #selector(startDatePickerDidChange(_:)), dateDoneButtonPressed: #selector(startDatePickerDoneButtonPressed(_:)), savedDate: milestone?.startDate)
        endDateTextField.inputView = setupDatePicker(dateDidChange: #selector(endDatePickerDidChange(_:)), dateDoneButtonPressed: #selector(endDatePickerDoneButtonPressed(_:)), savedDate: milestone?.endDate)
    }
    
    func initMapView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 9.9)
        map = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        map.isUserInteractionEnabled = false
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.addSubview(map)
        
        let locationDetails = getLocationDetails(location: milestone?.location)
        mapView.isHidden = locationDetails == (0,0)
        
        setLocation(locationDetails.latitude, locationDetails.longitude)
    }
    
    func setLocation(_ latitude: Double, _ longitude: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        map.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 9.9))

        if marker == nil {
            marker = GMSMarker()
        }
        marker.position = coordinate
        marker.map = map
    }
    
    func getLocationDetails(location: LocnVO?) -> (latitude: Double, longitude: Double) {
        if let latitude = location?.latitude,
            let longitude = location?.longitude {
                    return (latitude, longitude)
                }
        return (0, 0)
    }
    
    @objc func startDatePickerDoneButtonPressed(_ sender: Any) {
        startDateTextField.resignFirstResponder()
    }
    
    @objc func startDatePickerDidChange(_ sender: UIDatePicker) {
        let date = sender.date
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        startDateTextField.text = dateFormatter.string(from: date)
    }
    
    @objc func endDatePickerDoneButtonPressed(_ sender: Any) {
        startDateTextField.resignFirstResponder()
    }
    
    @objc func endDatePickerDidChange(_ sender: UIDatePicker) {
        let date = sender.date
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        endDateTextField.text = dateFormatter.string(from: date)
    }
    
    @objc func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc func doneButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension PublicProfileAddMilestonesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case titleTextField:
            titleHintLabel.isHidden = true
            
        case startDateTextField:
            startDateHintLabel.isHidden = true
            
        case endDateTextField:
            endDateHintLabel.isHidden = true
            
        case descriptionTextField:
            descriptionHintLabel.isHidden = true
            
        case locationTextField:
            let locationSetVC = UIViewController.create(withIdentifier: .locationSetOnTap, from: .profile) as! PublicProfileLocationSetViewController
            locationSetVC.delegate = self
            locationSetVC.viewModel = viewModel
            locationSetVC.locnVO = milestone?.location
            
            let navigationVC = NavigationController(rootViewController: locationSetVC)
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: true)
            
        default:
            return
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else { return false }
        let textCount = textFieldText.count + string.count - range.length
        
        switch textField {
        case titleTextField:
            titleLabel.text = "\(ProfilePageData.milestoneTitle()) (<COUNT>/140)".localized().replacingOccurrences(of: "<COUNT>", with: "\(textCount)")
            
            if textCount < 140 {
                return true
            }
            return false
            
        case descriptionTextField:
            descriptionLabel.text = "\(ProfilePageData.milestoneDescription())(<COUNT>/200)".localized().replacingOccurrences(of: "<COUNT>", with: "\(textCount)")
            
            if textCount < 200 {
                return true
            }
            return false
            
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldText = textField.text else { return }
        
        switch textField {
        case titleTextField:
            if textFieldText.isEmpty {
                titleHintLabel.isHidden = false
            }
            
        case startDateTextField:
            if textFieldText.isEmpty {
                startDateHintLabel.isHidden = false
            }
            
        case endDateTextField:
            if textFieldText.isEmpty {
                endDateHintLabel.isHidden = false
            }
            
        case descriptionTextField:
            if textFieldText.isEmpty {
                descriptionHintLabel.isHidden = false
            }
            
        case locationTextField:
            if textFieldText.isEmpty {
                locationHintLabel.isHidden = false
            }
        
        default:
            return
        }
    }
}

extension PublicProfileAddMilestonesViewController: PublicProfileLocationSetViewControllerDelegate {
    func locationSetViewControllerDidUpdate(_ locationVC: PublicProfileLocationSetViewController) {
        print("from location")
    }
}
