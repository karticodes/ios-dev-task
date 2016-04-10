//
//  BaseViewController.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit
import CoreData

struct NavigationBarItems: OptionSetType{
    
    let rawValue: Int
    
    static let None         = NavigationBarItems(rawValue: 0)
    static let Back         = NavigationBarItems(rawValue: 1 << 0)
    static let Edit         = NavigationBarItems(rawValue: 1 << 1)
    static let Done         = NavigationBarItems(rawValue: 1 << 2)
    static let Delete       = NavigationBarItems(rawValue: 1 << 3)
}

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {

    var navigationBarItems: NavigationBarItems = .None
    override func viewDidLoad() {
        super.viewDidLoad()

        updateNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showSimpleAlert(title: String?, message: String?, cancel: String, handler: ((UIAlertAction) -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: handler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func itemsForNavigationBar() -> NavigationBarItems{
        
        return .None
    }
    
    func titleForNavigationBar() -> String{
        
        return "VC"
    }
    
    func viewForNavigationBar() -> UIView?{
        return nil
    }
    
    func instanciateWithIdentifier<T>(identifier: String) -> T?{
        
        return Utility.instanciateWithIdentifier(identifier)
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    
    func saveContext(){
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }

}

//MARK: - Navigation Bar
extension BaseViewController{
    
    func updateNavigationBar(){
        
        updateNavigationTitle()
        updateNavigationItems()
    }
    
    func updateNavigationTitle(){
        if let view = viewForNavigationBar(){
            self.navigationItem.titleView = view
        }else{
            self.navigationItem.titleView = nil
            self.navigationItem.title = self.titleForNavigationBar()
        }
    }
    
    func updateNavigationItems(){
        
        navigationBarItems = self.itemsForNavigationBar()
        
        var leftBarItems = [UIBarButtonItem]()
        var rightBarItems = [UIBarButtonItem]()
        
        if navigationBarItems.contains(.Back){
            leftBarItems.append(UIBarButtonItem(image: UIImage(named: "Back"), style: .Done, target: self, action: #selector(backButtonClicked)))
        }
        if navigationBarItems.contains(.Edit){
            rightBarItems.append(UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editButtonClicked)))
        }else if navigationBarItems.contains(.Done){
            rightBarItems.append(UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonClicked)))
        }
        
        if navigationBarItems.contains(.Delete){
            rightBarItems.append(UIBarButtonItem(image: UIImage(named: "Delete"), style: .Done, target: self, action: #selector(deleteButtonClicked)))
        }
        
        self.navigationItem.leftBarButtonItems = leftBarItems
        self.navigationItem.rightBarButtonItems = rightBarItems
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.enabled = navigationBarItems.contains(.Back)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func deleteButtonClicked(){
        
    }
    
    func editButtonClicked(){
        
    }
    
    func doneButtonClicked(){
        
    }
    
    func backButtonClicked(){
        self.navigationController?.popViewControllerAnimated(true)
    }
}
