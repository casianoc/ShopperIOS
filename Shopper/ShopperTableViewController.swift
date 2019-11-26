//
//  ShopperTableViewController.swift
//  Shopper
//
//  Created by Casiano, Cameron Joseph on 11/5/19.
//  Copyright © 2019 Casiano, Cameron Joseph. All rights reserved.
//

import UIKit
import CoreData

class ShopperTableViewController: UITableViewController {
    
    // create a refernce to a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // create an array of shoppingList entities
    var shoppingLists = [ShoppingList] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadShoppingLists()
    }
    
    func deleteShoppingList (item: ShoppingList){
        context.delete(item)
        
        do {
            // use context to delete ShoppingList Item from Core Data
            try context.save()
        } catch {
            print("Error deleting ShoppingList from Core Data")
        }
        loadShoppingLists()
    }
    
    // fetch shopping lists from core data
    func loadShoppingLists(){
        
        // create an instance of a fetch request so that shopping lists can be fetched from core data
        let request: NSFetchRequest<ShoppingList> = ShoppingList.fetchRequest()
        
        do {
            // use context to execute fetch request to fetch ShoppingLists from Core Data store the fethed ShoppingLists in our array
            shoppingLists = try context.fetch(request)
        } catch {
            print("Error fetching ShoppingLists from Core Data!")
        }
        
        //reloading the fetched data in the table view controller
        tableView.reloadData()
    }
    
    // saves lists to core data
    func saveShopingLists(){
        do {
            try context.save()
        } catch {
            print("Error saving ShoppingLists to Core Data")
        }
        
        // reload the data in the Table View Controller
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // declare text fields variables for the input of the name store and date
        var nameTextField = UITextField()
        var storeTextField = UITextField()
        var dateTextField = UITextField()
        
        // create an Alert controller
        let alert = UIAlertController(title: "Add Shopping List", message: "", preferredStyle: .alert)
        
        // define an aciton that will occur whrn the Add List button is pushed
        let action = UIAlertAction(title: "Add List", style: .default, handler: { (action) in
            
            // create an instance of a shoppingLists entity
            let newShoppingList = ShoppingList(context: self.context)
            
            // get name, store, and date input by user and store them in ShoppingList entity
            newShoppingList.name = nameTextField.text!
            newShoppingList.store = storeTextField.text!
            newShoppingList.date = dateTextField.text!
            
            // add shoppinglist entity to array
            self.shoppingLists.append(newShoppingList)
            
            // save shoppingLists to CoreData
            self.saveShopingLists()
        })
        
        // disable the action that will let the user Add List
        action.isEnabled = false
        
        // define an aciton that will occur when the cancel button is pushed
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (cancelAction) in
            
        })
        
        // add actions into Alert Controller
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        // add the text fields into the alert controller
        alert.addTextField(configurationHandler: { (field) in
            nameTextField = field
            nameTextField.placeholder = "Enter Name"
            nameTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
        })
        alert.addTextField(configurationHandler: { (field) in
            storeTextField = field
            storeTextField.placeholder = "Enter Store"
            storeTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
        })
        alert.addTextField(configurationHandler: { (field) in
            dateTextField = field
            dateTextField.placeholder = "Enter Date"
            dateTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
        })
        
        // display the AlertController
        present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTextFieldDidChange (){
        
        // get reference to the Alert Controller
        let alertController = self.presentedViewController as! UIAlertController
        
        // get reference to the action that allos the user to add a shopping list
        let action = alertController.actions[0]
        
        // get references to the tect in the textFields
        if let name = alertController.textFields![0].text, let store = alertController.textFields![1].text, let date = alertController.textFields![2].text {
            
            // trim whitespace from the text
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            let trimmedStore = store.trimmingCharacters(in: .whitespaces)
            let trimmedDate = date.trimmingCharacters(in: .whitespaces)
            
            // check if the trimmed text isnt empty and if it isnt, we are going to enable the action that allows the user to add the shopping list
            if (!trimmedName.isEmpty && !trimmedStore.isEmpty && trimmedDate.isEmpty){
                action.isEnabled = true;
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath)

        // Configure the cell...
        let shoppingList = shoppingLists[indexPath.row]
        cell.textLabel?.text = shoppingList.name!
        cell.detailTextLabel?.text = shoppingList.store! + " " + shoppingList.date!
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = shoppingLists[indexPath.row]
            deleteShoppingList(item: item)
    }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if were segueing to the Shopping List Table View Controller
        if (segue.identifier == "ShoppingListItems"){
            
            // get the index path for the row that was selected
            // (0,0) (0,1) (0,2) etc
            let selectedRowIndex = self.tableView.indexPathForSelectedRow
            
            // create an instance of the shopping list table view controller
            let shoppingListItem = segue.destination as! ShoppingListTableViewController
            
            // set the selected shopping list property of the shopping list table view controller equal to the row of the index path
            shoppingListItem.selectedShoppingList = shoppingLists[selectedRowIndex!.row]
        }
    }
    

}

