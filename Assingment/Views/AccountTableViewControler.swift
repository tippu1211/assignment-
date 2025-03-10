//
//  AccountTableViewControler.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import UIKit

class AccountTableViewControler: UIViewController {

    
    @IBOutlet weak var table: UITableView!
    var viewModel = AccountsViewModel()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        table.delegate = self
        // Fetch accounts and reload data when done
        viewModel.onAccountsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.table.reloadData()
            }
        }
        
        viewModel.fetchAccounts()
    }
}

extension AccountTableViewControler: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableCell", for: indexPath) as! AccountTableCell
        let account = viewModel.accounts[indexPath.row]

        cell.accountIdLbl.text = account.actid
        cell.accountNameLbl.text = account.actName

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.viewModel.deleteAccount(at: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completionHandler in
            self?.editAccount(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func editAccount(at indexPath: IndexPath) {
        let account = viewModel.accounts[indexPath.row]
        let alert = UIAlertController(title: "Edit Account", message: "Modify account details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = account.actName
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let updatedName = alert.textFields?.first?.text, !updatedName.isEmpty {
                self?.viewModel.updateAccountName(at: indexPath.row, newName: updatedName)
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}

