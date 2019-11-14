//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by Casiano, Cameron Joseph on 11/12/19.
//  Copyright © 2019 Casiano, Cameron Joseph. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    
    // create a refernce to a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // create a variable that will contain the row of the selected shoppping list
    var selectedShoppingList: ShoppingList?
    
    // create an array to store shopping list items
    var shoppingListItems = [ShoppingListItem] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadShoppingListItems()
        
        // if we have a valid Shopping List
        if let selectedShoppingList = selectedShoppingList {
            // get the Shopping List name and set the title
            title = selectedShoppingList.name!
        } else {
            // set the title to Shopping List Items
            title = "Shopping List Items"
        }
        
        // make row height larger
        self.tableView.rowHeight = 84.0
    }

    // fetch shoppig list items from core data
    func loadShoppingListItems() {
        // check if Shopper Table View Controller has passed a valid Shopping List
        if let list = selectedShoppingList {
            // if the shopping listhas items, cast them to an array of ShoppingListItems
            if let listItems = list.items?.allObjects as? [ShoppingListItem]{
                shoppingListItems = listItems
            }
        }
        
        // reload fetched data in Table View Controller
        tableView.reloadData()
    }
    
    func saveShopingListItems(){
        do {
            try context.save()
        } catch {
            print("Error saving ShoppingListItems to Core Data")
        }
        
        // reload the data in the Table View Controller
        tableView.reloadData()
    }
    
    @objc func alertTextFieldDidChange (){
        
        // get reference to the Alert Controller
        let alertController = self.presentedViewController as! UIAlertController
        
        // get reference to the action that allos the user to add a shopping list
        let action = alertController.actions[0]
        
        // get references to the tect in the textFields
        if let name = alertController.textFields![0].text, let price = alertController.textFields![1].text, let quantity = alertController.textFields![2].text {
            
            // trim whitespace from the text
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
            let trimmedQuantity = quantity.trimmingCharacters(in: .whitespaces)
            
            // check if the trimmed text isnt empty and if it isnt, we are going to enable the action that allows the user to add the shopping list
            if (!trimmedName.isEmpty && !trimmedPrice.isEmpty && trimmedQuantity.isEmpty){
                action.isEnabled = true;
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // declare text fields variables for the input of the name store and date
        var nameTextField = UITextField()
        var priceTextField = UITextField()
        var quantityTextField = UITextField()
        
        // create an Alert controller
        let alert = UIAlertController(title: "Add Shopping List Item", message: "", preferredStyle: .alert)
        
        // define an aciton that will occur whrn the Add List button is pushed
        let action = UIAlertAction(title: "Add Item", style: .default, handler: { (action) in
            
            // create an instance of a shoppingLists entity
            let newShoppingListItem = ShoppingListItem(context: self.context)
            
            // get name, store, and date input by user and store them in ShoppingList entity
            newShoppingListItem.name = nameTextField.text!
            newShoppingListItem.price = Double(priceTextField.text!)!
            newShoppingListItem.quantity = Int64(quantityTextField.text!)!
            newShoppingListItem.purchased = false
            newShoppingListItem.shoppingList = self.selectedShoppingList
            
            // add shoppinglist entity to array
            self.shoppingListItems.append(newShoppingListItem)
            
            // save shoppingLists to CoreData
            self.saveShopingListItems()
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
                priceTextField = field
                priceTextField.placeholder = "Enter Price"
                priceTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            alert.addTextField(configurationHandler: { (field) in
                quantityTextField = field
                quantityTextField.placeholder = "Enter Quantity"
                quantityTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            
            // display the AlertController
            present(alert, animated: true, completion: nil)
            
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        // we will have as many rows as we have shopping list items
        return shoppingListItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

        // Configure the cell...
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        // set the cell title equal to the shopping list item name
        cell.textLabel?.text = shoppingListItem.name!
        
        cell.detailTextLabel!.numberOfLines = 0
        // set the cell subtitle equal to the shopping list item quantity and price
        cell.detailTextLabel?.text = String(shoppingListItem.quantity) + "\n" + String(shoppingListItem.price)
        
        // set the cell accessory type to checkmark if purchased is true, else set it to none
        if (shoppingListItem.purchased == false){
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
