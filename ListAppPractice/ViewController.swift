//
//  ViewController.swift
//  ListAppPractice
//
//  Created by Erkan Kızgın on 21.09.2022.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
    
    var alertController: UIAlertController!

    @IBOutlet weak var tableView: UITableView!
    
    let context = appDelegate.persistentContainer.viewContext
    
    var array: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate    = self
        tableView.dataSource  = self
        fetch()
    }
    @IBAction func addListItemTapped(_ sender: UIBarButtonItem) {
        addAlert()
    }
    @IBAction func didTrashTapped(_ sender: Any) {
        trashAllData()
    }
    

}
//MARK: TableView Source
extension ViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let listItem = array[indexPath.row]
        cell.textLabel?.text = (listItem.value(forKey: "title") as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete"){ _,_,_ in
            self.deleteSpecificItem(indeks: indexPath.row)
        }
        let updateAction = UIContextualAction(style: .normal, title: "Update"){ _,_,_ in
            self.updateAlert(indeks: indexPath.row)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,updateAction])
        
        return configuration
    }
    
}

//MARK: Alerts

extension ViewController {
    func addAlert(){
        presentAlert(title: "Add", message: "Add Item To List", preferredStyle: .alert, defaultButtonTitle: "Add", cancelButtonTitle: "Cancel", isAddInputField: true){_ in
            let input = self.alertController.textFields?.first?.text
            if input != "" {
                self.addItem(text: input!)
            }else{
                self.presentAlert(title: "Warning", message: "Your input must not be empty", preferredStyle: .alert, cancelButtonTitle: "Ok")
            }
        }
    }
    func updateAlert(indeks:Int){
        presentAlert(title: "update", message: "Update Item", preferredStyle: .alert, defaultButtonTitle: "Update", cancelButtonTitle: "Cancel", isAddInputField: true){_ in
            let input = self.alertController.textFields?.first?.text
            if input != "" {
                self.updateItem(indeks: indeks, text: input!)
            }else{
                self.presentAlert(title: "Warning", message: "Your input must not be empty", preferredStyle: .alert, cancelButtonTitle: "Ok")
            }
        }
        
    }
    func trashAllData(){
        presentAlert(title: "Trash All Data", message: "Are you sure to delete all records?", preferredStyle: .alert, defaultButtonTitle: "Delete All", cancelButtonTitle: "Cancel", isAddInputField: false){ _ in
            self.deleteAllItem()
            self.fetch()
        }
    }
    //MARK: Generic Alert
    func presentAlert(title: String,
                    message: String,
                    preferredStyle: UIAlertController.Style,
                    defaultButtonTitle: String? = nil,
                    cancelButtonTitle: String?,
                    isAddInputField: Bool = false,
                    defaultButtonHandler: ((UIAlertAction) -> Void)? = nil ){
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if isAddInputField {
            alertController.addTextField()
        }
        
        if let defaultButtonTitle = defaultButtonTitle {
            let defaultButtonAction = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButtonAction)
        }
        let cancelButtonAction = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        alertController.addAction(cancelButtonAction)
         
        present(alertController, animated: true, completion: nil)
        
    }
}


//MARK: CoreData CRUD operations

extension ViewController {
    
    func fetch(){
        do{
            self.array = try context.fetch(NSFetchRequest<NSManagedObject>(entityName: "ListItem"))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            print("Veriler çekilirken hata oluştu")
        }
        saveContext()
    }
    
    func updateItem(indeks: Int,text:String){
        let item = array[indeks]
        item.setValue(text, forKey: "title")
        saveContext()
        fetch()
    }
    
    func addItem(text: String){
        let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: context)
        let listItem = NSManagedObject(entity: entity!, insertInto: context)
        listItem.setValue(text, forKey: "title")
        saveContext()
        fetch()
    }
    
    func deleteSpecificItem(indeks: Int){
        context.delete(array[indeks])
        saveContext()
        fetch()
    }
    
    func deleteAllItem(){
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch  {
            print("Database silinirken hata alındı.")
        }
    }
    
    func saveContext(){
        do {
            try context.save()
        } catch  {
            print("Veriler kaydedilirken hata alındı.")
        }
    }
}

