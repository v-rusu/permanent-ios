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
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionHintLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var map: GMSMapView!
    var marker: GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        initUI()
        
        titleTextField.delegate = self
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        descriptionTextView.delegate = self
        locationTextField.delegate = self
        
        setFieldValues()
        initMapView()
        addDismissKeyboardGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let textFields = [titleTextField, startDateTextField, endDateTextField, locationTextField]
        
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
        
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 3
        descriptionTextView.textColor = .middleGray
        descriptionTextView.font = Text.style7.font
        
        descriptionHintLabel?.textColor = .lightGray
        descriptionHintLabel?.font = Text.style7.font
        descriptionHintLabel?.textAlignment = .left
        
        titleLabel.text = "\(ProfilePageData.milestoneTitle()) (<COUNT>/140)".localized().replacingOccurrences(of: "<COUNT>", with: "\(milestone?.title?.count ?? 0)")
        startDateLabel.text = ProfilePageData.milestoneStartDate()
        endDateLabel.text = ProfilePageData.milestoneEndDate()
        descriptionLabel.text = "\(ProfilePageData.milestoneDescription()) (<COUNT>/200)".localized().replacingOccurrences(of: "<COUNT>", with: "\(milestone?.description?.count ?? 0)")
        locationLabel.text = ProfilePageData.milestoneLocation()
        
        titleTextField.placeholder = ProfilePageData.milestoneTitleHint()
        startDateTextField.placeholder = ProfilePageData.milestoneStartDateHint()
        endDateTextField.placeholder = ProfilePageData.milestoneEndDateHint()
        descriptionHintLabel.text = ProfilePageData.milestoneDescriptionHint()
        locationTextField.placeholder = ProfilePageData.milestoneLocationHint()
        
        setupDatePickers()
    }
    
    func setupNavigationBar() {
        styleNavBar()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeButtonAction(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonAction(_:)))
    }
    
    func setFieldValues() {
        if !isNewItem {
            setInitialLabelValueForTextField(titleTextField, value: milestone?.title)
            setInitialLabelValueForTextField(startDateTextField, value: milestone?.startDateString)
            setInitialLabelValueForTextField(endDateTextField, value: milestone?.endDateString)
            setInitialLabelValueForTextField(locationTextField, value: milestone?.locationFormated)
            
            if let savedValue = milestone?.description,
                savedValue.isNotEmpty {
                descriptionTextView.text = savedValue
                descriptionHintLabel.isHidden = true
            } else {
                descriptionTextView.text = nil
                descriptionHintLabel.isHidden = false
            }
        } else {
            milestone = MilestoneProfileItem()
            milestone?.archiveId = viewModel?.archiveData.archiveID
            milestone?.isNewlyCreated = true
            milestone?.isPendingAction = true
        }
    }
    
    func setupDatePicker(dateDidChange: Selector, dateDoneButtonPressed: Selector, savedDate: String?) -> UIStackView {
        let dateFormatter = DateFormatter()
        var date = dateFormatter.date(from: "")
        dateFormatter.timeZone = .init(secondsFromGMT: 0)
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
    
    func setInitialLabelValueForTextField(_ textField: UITextField, value: String?, associatedLabel: UILabel = UILabel() ) {
        if let savedValue = value,
            savedValue.isNotEmpty {
            textField.text = savedValue
            associatedLabel.isHidden = true
        } else {
            textField.text = nil
            associatedLabel.isHidden = false
        }
    }
    
    func setupDatePickers() {
        startDateTextField.inputView = setupDatePicker(dateDidChange: #selector(startDatePickerDidChange(_:)), dateDoneButtonPressed: #selector(startDatePickerDoneButtonPressed(_:)), savedDate: milestone?.startDateString)
        endDateTextField.inputView = setupDatePicker(dateDidChange: #selector(endDatePickerDidChange(_:)), dateDoneButtonPressed: #selector(endDatePickerDoneButtonPressed(_:)), savedDate: milestone?.endDateString)
    }
    
    func initMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 9.9)
        map = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        map.isUserInteractionEnabled = false
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.addSubview(map)
        
        let locationDetails = getLocationDetails(location: milestone?.location)
        mapView.isHidden = locationDetails == (0, 0)
        
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
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDateTextField.text = dateFormatter.string(from: date)
        
        startDateTextField.resignFirstResponder()
    }
    
    @objc func startDatePickerDidChange(_ sender: UIDatePicker) {
        let date = sender.date
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        startDateTextField.text = dateFormatter.string(from: date)
    }
    
    @objc func endDatePickerDoneButtonPressed(_ sender: Any) {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        endDateTextField.text = dateFormatter.string(from: date)
        
        endDateTextField.resignFirstResponder()
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
        var titleNotEmpty: Bool = false
        
        if let value = titleTextField.text,
            value.isNotEmpty {
            milestone?.title = value
            titleNotEmpty = true
        }
        
        if let value = startDateTextField.text,
            value.isNotEmpty {
            milestone?.startDateString = value
        }
        
        if let value = endDateTextField.text,
            value.isNotEmpty {
            milestone?.endDateString = value
        }
        
        if let value = descriptionTextView.text,
            value.isNotEmpty {
            milestone?.description = value
        }
        
        if titleNotEmpty {
            guard let milestone = milestone else { return }
            showSpinner()
            
            viewModel?.updateMilestoneProfileItem(newValue: milestone, { status in
                self.hideSpinner()
                if status {
                    self.dismiss(animated: true)
                } else {
                    self.showAlert(title: .error, message: .errorMessage)
                }
            })
        } else {
            showAlert(title: .error, message: "Please enter a title for your milestone".localized())
        }
    }
    
    // MARK: - Keyboard
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let scrollView = scrollView,
            let keyBoardInfo = notification.userInfo,
            let endFrame = keyBoardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let window = scrollView.window
        else { return }
        
        let keyBoardFrame = window.convert(endFrame.cgRectValue, to: scrollView.superview)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((keyBoardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double))
        UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: (keyBoardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardFrame.height, right: 0)
        UIView.commitAnimations()
        
        guard let firstResponder: UIView = contentView.subviews.first(where: { $0.isFirstResponder }) else { return }
        
        scrollView.scrollRectToVisible(firstResponder.frame, animated: true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let keyBoardInfo = notification.userInfo!
        var tableInsets = scrollView.contentInset
        tableInsets.bottom = 0
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((keyBoardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double))
        UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: (keyBoardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!)
        scrollView.contentInset = tableInsets
        UIView.commitAnimations()
    }
}

// MARK: - UITextFieldDelegate
extension PublicProfileAddMilestonesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == locationTextField {
            let locationSetVC = UIViewController.create(withIdentifier: .locationSetOnTap, from: .profile) as! PublicProfileLocationSetViewController
            locationSetVC.delegate = self
            locationSetVC.viewModel = viewModel
            locationSetVC.locnVO = milestone?.location
            
            let navigationVC = NavigationController(rootViewController: locationSetVC)
            navigationVC.modalPresentationStyle = .fullScreen
            present(navigationVC, animated: true)
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

        default:
            return true
        }
    }
}

extension PublicProfileAddMilestonesViewController: PublicProfileLocationSetViewControllerDelegate {
    func locationSetViewControllerDidUpdate(_ locationVC: PublicProfileLocationSetViewController) {
        let locationDetails = getLocationDetails(location: locationVC.pickedLocation)
        milestone?.location = locationVC.pickedLocation
        milestone?.locnId1 = locationVC.pickedLocation?.locnID
        
        locationTextField.text = milestone?.locationFormated
        
        mapView.isHidden = locationDetails == (0, 0)
        
        setLocation(locationDetails.latitude, locationDetails.longitude)
    }
}

// MARK: - UITextFieldDelegate
extension PublicProfileAddMilestonesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionHintLabel.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textFieldText = textView.text else { return false }
        let textCount = textFieldText.count + text.count - range.length
        
        descriptionLabel.text = "\(ProfilePageData.milestoneDescription())(<COUNT>/200)".localized().replacingOccurrences(of: "<COUNT>", with: "\(textCount)")
        
        if textCount < 200 {
            return true
        }
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            descriptionHintLabel.isHidden = false
        }
    }
}
