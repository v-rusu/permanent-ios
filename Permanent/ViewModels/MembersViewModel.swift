//  
//  MembersViewModel.swift
//  Permanent
//
//  Created by Adrian Creteanu on 23.12.2020.
//

import Foundation

typealias AddMemberParams = (email: String, role: String)

protocol MembersViewModelDelegate: ViewModelDelegateInterface {
    
    func getMembers(then handler: @escaping ServerResponse)
    
}

class MembersViewModel: ViewModelInterface {
    
    fileprivate var csrf: String = ""
    fileprivate var members: [Account] = []
    fileprivate var memberSections: [AccessRole: [Account]] = [:]
    
    weak var delegate: MembersViewModelDelegate?
    
    func numberOfItemsForRole(_ role: AccessRole) -> Int {
        return memberSections[role]?.count ?? 0
    }
    
    func itemAtRow(_ row: Int, withRole role: AccessRole) -> Account? {
        return memberSections[role]?[row]
    }
}

extension MembersViewModel: MembersViewModelDelegate {
    
    func getMembers(then handler: @escaping ServerResponse) {
        
        guard let archiveNbr: String = PreferencesManager.shared.getValue(
            forKey: Constants.Keys.StorageKeys.archiveNbrStorageKey
        ) else {
            return
        }
        
        let operation = APIOperation(MembersEndpoint.members(archiveNbr: archiveNbr))
        operation.execute(in: APIRequestDispatcher()) { result in
            
            switch result {
            case .json(let response, _):
                
                guard
                    let model: APIResults<AccountVO> = JSONHelper.decoding(
                        from: response,
                        with: APIResults<AccountVO>.decoder
                    ), model.isSuccessful else {
                    
                    return handler(.error(message: .errorMessage))
                }
            
                self.csrf = model.csrf
                self.onGetMembersSucess(model.results.first?.data ?? [])
        
                handler(.success)
                
            case .error(let error, _):
                handler(.error(message: error?.localizedDescription))
                
            default:
                break
            }
        }
    }
    
    func addMember(params: AddMemberParams, then handler: @escaping ServerResponse) {
        
        guard let archiveNbr: String = PreferencesManager.shared.getValue(
            forKey: Constants.Keys.StorageKeys.archiveNbrStorageKey
        ) else {
            return
        }
        
        let operation = APIOperation(MembersEndpoint.addMember(archiveNbr: archiveNbr, params: params, csrf: csrf))
        operation.execute(in: APIRequestDispatcher()) { result in
            switch result {
            case .json(let response, _):
                guard
                    let model: APIResults<AccountVO> = JSONHelper.decoding(
                        from: response,
                        with: APIResults<AccountVO>.decoder
                    ), model.isSuccessful,
                    let member = model.results.first?.data?.first else {
                    
                    return handler(.error(message: .errorMessage))
                }
                                
                self.onAddMemberSuccess(member)
                
                handler(.success)
                
            case .error(let error, _):
                handler(.error(message: error?.localizedDescription))
                
            default:
                break
            }
        }
    }
    
    fileprivate func onAddMemberSuccess(_ account: AccountVO) {
        let accountVO = AccountVM(accountVO: account)
        self.members.append(accountVO)
        
        if var membersSameRole = self.memberSections[accountVO.accessRole] {
            self.memberSections[accountVO.accessRole]?.append(accountVO)
        } else {
            self.memberSections[accountVO.accessRole] = [accountVO]
        }
    }
    
    fileprivate func onGetMembersSucess(_ accounts: [AccountVO]) {
        self.members = accounts.map { AccountVM(accountVO: $0) }
        self.memberSections = Dictionary(grouping: self.members, by: { $0.accessRole })
    }
    
}
