//
//  ProfilePageViewModel.swift
//  Permanent
//
//  Created by Lucian Cerbu on 09.11.2021.
//

import UIKit
import AVFAudio
import AVFoundation

class PublicProfilePageViewModel: ViewModelInterface {
    var archiveData: ArchiveVOData!
    var archiveType: ArchiveType!
    
    var profileItems = [ProfileItemModel]()
    
    var blurbProfileItem: BlurbProfileItem? {
        return profileItems.first(where: {$0 is BlurbProfileItem}) as? BlurbProfileItem
    }
    var descriptionProfileItem: DescriptionProfileItem? {
        return profileItems.first(where: {$0 is DescriptionProfileItem}) as? DescriptionProfileItem
    }
    var basicProfileItem: BasicProfileItem? {
        return profileItems.first(where: {$0 is BasicProfileItem}) as? BasicProfileItem
    }
    var emailProfileItem: EmailProfileItem? {
        return profileItems.first(where: {$0 is EmailProfileItem}) as? EmailProfileItem
    }
    var profileGenderProfileItem: GenderProfileItem? {
        return profileItems.first(where: {$0 is GenderProfileItem}) as? GenderProfileItem
    }
    var birthInfoProfileItem: BirthInfoProfileItem? {
        return profileItems.first(where: {$0 is BirthInfoProfileItem}) as? BirthInfoProfileItem
    }
    
    init(_ archiveData: ArchiveVOData) {
        self.archiveData = archiveData
        guard let archiveType = archiveData.type else { return }
        self.archiveType = ArchiveType(rawValue: archiveType)
    }
    
    func getAllByArchiveNbr(_ archive: ArchiveVOData, _ completionBlock: @escaping ((Error?) -> Void)) {
        guard let archiveId = archive.archiveID, let archiveNbr = archive.archiveNbr else {
            completionBlock(APIError.unknown)
            return
        }
        
        let getAllByArchiveNbr = APIOperation(PublicProfileEndpoint.getAllByArchiveNbr(archiveId: archiveId, archiveNbr: archiveNbr))
        getAllByArchiveNbr.execute(in: APIRequestDispatcher()) { result in
            switch result {
            case .json(let response, _):
                guard
                    let model: APIResults<ProfileItemVO> = JSONHelper.decoding(from: response, with: APIResults<ProfileItemVO>.decoder),
                    model.isSuccessful
                else {
                    completionBlock(APIError.invalidResponse)
                    return
                }
                self.profileItems = model.results.first?.data?.compactMap({ $0.profileItemVO }) ?? []
                completionBlock(nil)
                return
            
            case .error:
                completionBlock(APIError.invalidResponse)
                return
                
            default:
                completionBlock(APIError.invalidResponse)
                return
            }
        }
    }
    
    func modifyPublicProfileItem(_ profileItemModel: ProfileItemModel, _ operationType: ProfileItemOperation, _ completionBlock: @escaping ((Bool, Error?, Int?) -> Void)) {
        let apiOperation: APIOperation
        
        switch operationType {
        case .update, .create:
            apiOperation = APIOperation(PublicProfileEndpoint.safeAddUpdate(profileItemVOData: profileItemModel))
            
        case .delete:
            apiOperation = APIOperation(PublicProfileEndpoint.deleteProfileItem(profileItemVOData: profileItemModel))
        }
        
        apiOperation.execute(in: APIRequestDispatcher()) { result in
            switch result {
            case .json(let response, _):
                guard
                    let model: APIResults<ProfileItemVO> = JSONHelper.decoding(from: response, with: APIResults<ProfileItemVO>.decoder),
                    model.isSuccessful,
                    let newProfileItemId = model.results.first
                else {
                    completionBlock(false, APIError.invalidResponse, nil)
                    return
                }
                NotificationCenter.default.post(name: .publicProfilePageUpdate, object: self)
                if operationType == .delete {
                    completionBlock(true, nil, nil)
                    return
                }
                completionBlock(true, nil, newProfileItemId.data?.first?.profileItemVO?.profileItemId)
                return
                
            case .error:
                completionBlock(false, APIError.invalidResponse, nil)
                return
                
            default:
                completionBlock(false, APIError.invalidResponse, nil)
                return
            }
        }
    }
    
    func modifyBlurbProfileItem(profileItemId: Int? = nil, newValue: String, operationType: ProfileItemOperation, _ completionBlock: @escaping ((Bool, Error?, Int?) -> Void)) {
        let newBlurbItem = BlurbProfileItem()
        newBlurbItem.shortDescription = newValue
        newBlurbItem.archiveId = archiveData.archiveID
        newBlurbItem.profileItemId = profileItemId
        
        modifyPublicProfileItem(newBlurbItem, operationType, completionBlock)
    }
    
    func modifyDescriptionProfileItem(profileItemId: Int? = nil, newValue: String, operationType: ProfileItemOperation, _ completionBlock: @escaping ((Bool, Error?, Int?) -> Void)) {
        let newProfileItem = DescriptionProfileItem()
        newProfileItem.longDescription = newValue
        newProfileItem.archiveId = archiveData.archiveID
        newProfileItem.profileItemId = profileItemId
        
        modifyPublicProfileItem(newProfileItem, operationType, completionBlock)
    }
    
    func modifyBasicProfileItem(profileItemId: Int? = nil, newValueFullname: String? = nil, newValueNickName: String? = nil, operationType: ProfileItemOperation, _ completionBlock: @escaping ((Bool, Error?, Int?) -> Void)) {
        let newProfileItem = BasicProfileItem()
        newProfileItem.fullName = newValueFullname
        newProfileItem.nickname = newValueNickName
        newProfileItem.archiveId = archiveData.archiveID
        newProfileItem.profileItemId = profileItemId
        
        modifyPublicProfileItem(newProfileItem, operationType, completionBlock)
    }
    
    func modifyGenderProfileItem(profileItemId: Int? = nil, newValueGender: String? = nil, operationType: ProfileItemOperation, _ completionBlock: @escaping ((Bool, Error?, Int?) -> Void)) {
        let newProfileItem = GenderProfileItem()
        newProfileItem.personGender = newValueGender
        newProfileItem.archiveId = archiveData.archiveID
        newProfileItem.profileItemId = profileItemId
        
        modifyPublicProfileItem(newProfileItem, operationType, completionBlock)
    }
    
    func modifyBirthInfoProfileItem(profileItemId: Int? = nil, newValueBirthDate: String? = nil, newValueBirthLocation: String? = nil, operationType: ProfileItemOperation, _ completionBlock: @escaping ((Bool, Error?, Int?) -> Void)) {
        let newProfileItem = BirthInfoProfileItem()
        newProfileItem.birthDate = newValueBirthDate
        newProfileItem.archiveId = archiveData.archiveID
        newProfileItem.profileItemId = profileItemId
        
        modifyPublicProfileItem(newProfileItem, operationType, completionBlock)
    }
    
    func updateBasicProfileItem(fullNameNewValue: String?, nicknameNewValue: String?, _ completion: @escaping (Bool) -> Void ) {
        var textFieldIsEmpty = (false, false)
        var textFieldHaveNewValue = (false, false)
        
        if let savedFullName = basicProfileItem?.fullName,
           savedFullName != fullNameNewValue {
            textFieldHaveNewValue.0 = true
        } else if (fullNameNewValue ?? "").isNotEmpty {
            textFieldHaveNewValue.0 = true
        }
        
        if let savedNickname = basicProfileItem?.nickname,
            savedNickname != nicknameNewValue {
            textFieldHaveNewValue.1 = true
        } else if (nicknameNewValue ?? "").isNotEmpty {
            textFieldHaveNewValue.1 = true
        }
        
        if let fullName = fullNameNewValue,
            fullName.isEmpty {
            textFieldIsEmpty.0 = true
        }
        
        if let nickname = nicknameNewValue,
            nickname.isEmpty {
            textFieldIsEmpty.1 = true
        }
        
        if textFieldHaveNewValue == (false, false) {
            completion(true)
            return
        }
        
        if textFieldHaveNewValue.0 || textFieldHaveNewValue.1,
            textFieldIsEmpty == (true, true) {
            modifyBasicProfileItem(profileItemId: basicProfileItem?.profileItemId, operationType: .delete, { result, error, itemId in
                if result {
                    self.basicProfileItem?.profileItemId = nil
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            })
        } else {
            modifyBasicProfileItem(profileItemId: basicProfileItem?.profileItemId, newValueFullname: fullNameNewValue, newValueNickName: nicknameNewValue, operationType: .update, { result, error, itemId in
                if result {
                    if self.basicProfileItem?.profileItemId == nil {
                        self.basicProfileItem?.profileItemId = itemId
                    }
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            })
        }
    }
    
    func updateGenderProfileItem(genderNewValue: String?, _ completion: @escaping (Bool) -> Void ) {
        var textFieldIsEmpty = false
        var textFieldHaveNewValue = false
        
        if let savedProfileGender = profileGenderProfileItem?.personGender,
            savedProfileGender != genderNewValue {
            textFieldHaveNewValue = true
        } else if (genderNewValue ?? "").isNotEmpty {
            textFieldHaveNewValue = true
        }
        
        if let value = genderNewValue,
            value.isEmpty {
            textFieldIsEmpty = true
        }
        
        if textFieldHaveNewValue == false {
            completion(true)
            return
        }
        
        if textFieldHaveNewValue,
            textFieldIsEmpty {
            modifyGenderProfileItem(profileItemId: profileGenderProfileItem?.profileItemId, operationType: .delete, { result, error, itemId in
                if result {
                    self.profileGenderProfileItem?.profileItemId = nil
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            })
        } else {
            modifyGenderProfileItem(profileItemId: profileGenderProfileItem?.profileItemId, newValueGender: genderNewValue, operationType: .update, { result, error, itemId in
                if result {
                    if self.profileGenderProfileItem?.profileItemId == nil {
                        self.profileGenderProfileItem?.profileItemId = itemId
                    }
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            })
        }
    }
    
    func updateBirthInfoProfileItem(birthDateNewValue: String?, birthLocationNewValue: String?, _ completion: @escaping (Bool) -> Void ) {
        var textFieldIsEmpty = (false, false)
        var textFieldHaveNewValue = (false, false)
        
        if let savedBirthDate = birthInfoProfileItem?.birthDate,
            savedBirthDate != birthDateNewValue {
            textFieldHaveNewValue.0 = true
        } else if (birthDateNewValue ?? "").isNotEmpty {
            textFieldHaveNewValue.0 = true
        }
        
        if let savedBirthLocation = birthInfoProfileItem?.birthLocationFormated,
            savedBirthLocation != birthLocationNewValue {
            textFieldHaveNewValue.1 = true
        } else if (birthLocationNewValue ?? "").isNotEmpty {
            textFieldHaveNewValue.1 = true
        }
        
        if let birthDate = birthDateNewValue,
            birthDate.isEmpty {
            textFieldIsEmpty.0 = true
        }
        
        if let birthLocation = birthLocationNewValue,
            birthLocation.isEmpty {
            textFieldIsEmpty.1 = true
        }
        
        if textFieldHaveNewValue == (false, false) {
            completion(true)
            return
        }
        
        if textFieldHaveNewValue.0 || textFieldHaveNewValue.1 {
            modifyBirthInfoProfileItem(profileItemId: birthInfoProfileItem?.profileItemId, newValueBirthDate: birthDateNewValue, newValueBirthLocation: nil, operationType: .update, { result, error, itemId in
                if result {
                    if self.basicProfileItem?.profileItemId == nil {
                        self.basicProfileItem?.profileItemId = itemId
                    }
                    completion(true)
                    return
                } else {
                    completion(false)
                    return
                }
            })
        } else {
            completion(true)
            return
        }
    }
}
