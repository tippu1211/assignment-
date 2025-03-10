//
//  AccountsViewModel.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import Foundation
import UIKit
import CoreData

class AccountsViewModel {
   
    var accounts: [Account] = []  // Fix: Changed from String() to an array
    var onAccountsFetched: (() -> Void)?
    
    func fetchAccounts() {
        // Fetch accounts from the API
        fetchAccounts { [weak self] accounts in
            self?.accounts = accounts ?? []
            self?.saveAccountsToCoreData(accounts!)
            self?.onAccountsFetched?()
        }
    }
    
    private func cleanJsonString(_ jsonString: String) -> String? {
       
        let keyPattern = "(\\w+):"
        guard let keyRegex = try? NSRegularExpression(pattern: keyPattern, options: []) else { return nil }
        let modifiedString = keyRegex.stringByReplacingMatches(in: jsonString, options: [], range: NSRange(location: 0, length: jsonString.utf16.count), withTemplate: "\"$1\":")

        let valuePattern = ":(\\w+)(,|\\})"
        guard let valueRegex = try? NSRegularExpression(pattern: valuePattern, options: []) else { return nil }
        let finalString = valueRegex.stringByReplacingMatches(in: modifiedString, options: [], range: NSRange(location: 0, length: modifiedString.utf16.count), withTemplate: ":\"$1\"$2")

        return finalString
    }
    
    private func fetchAccounts(completion: @escaping ([Account]?) -> Void) {
        
        guard let url = URL(string: "https://fssservices.bookxpert.co/api/Fillaccounts/nadc/2024-2025") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // Convert the data to a string
            if let jsonString = String(data: data, encoding: .utf8) {
                    let jsonStringWithoutTags = jsonString
                        .replacingOccurrences(of: "<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">", with: "")
                        .replacingOccurrences(of: "</string>", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                if var cleanedJson = self.cleanJsonString(jsonStringWithoutTags) {
                       if cleanedJson.first == "\"" && cleanedJson.last == "\""{
                           cleanedJson.removeFirst()
                           cleanedJson.removeLast()
                       }

                       cleanedJson = cleanedJson.replacingOccurrences(of: "\\\"", with: "\"")

                       guard let jsonData = cleanedJson.data(using: .utf8) else {
                           print("Failed to convert cleaned string to Data")
                           completion(nil)
                           return
                       }

                        do {
                            let accounts = try JSONDecoder().decode([Account].self, from: jsonData)
                            completion(accounts)
                        } catch {
                            print("Error decoding JSON: \(error)")
                            completion(nil)
                        }
                    } else {
                        print("Failed to clean JSON string")
                        completion(nil)
                    }
                } else {
                print("Failed to convert data to string")
                completion(nil)
            }
        }

        task.resume()
    }

    private func saveAccountsToCoreData(_ accounts: [Account]) {
        DispatchQueue.main.async {  // Ensure execution on the main thread
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "AccountEntity", in: context)

            for account in accounts {
                if !self.checkAccountIsInCoreData(with: Int(account.actid) ?? 0) {
                    let data = NSManagedObject(entity: entity!, insertInto: context)
                    data.setValue(account.actid, forKey: "accountID")
                    data.setValue(account.actName, forKey: "accountName")
                }
            }

            do {
                try context.save()
            } catch {
                print("Failed to save data: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAccountIsInCoreData(with id: Int) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AccountEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "accountID == %d", id)
        
        do {
            let result = try context.fetch(request)
            return !result.isEmpty
        } catch {
            print("Error fetching account:", error.localizedDescription)
            return false
        }
    }
    
    func deleteAccount(at index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            guard index < results.count else { return }  // Prevents out-of-bounds crash
            
            context.delete(results[index])
            try context.save()
            
            DispatchQueue.main.async {
                self.accounts.remove(at: index)
                self.onAccountsFetched?()
            }
        } catch {
            print("Error deleting account: \(error.localizedDescription)")
        }
    }
    
    func updateAccountName(at index: Int, newName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            guard index < results.count else { return }
            
            results[index].accountName = newName
            try context.save()
            
            DispatchQueue.main.async {
                self.accounts[index].actName = newName
                self.onAccountsFetched?()
            }
        } catch {
            print("Error updating account: \(error.localizedDescription)")
        }
    }

}
