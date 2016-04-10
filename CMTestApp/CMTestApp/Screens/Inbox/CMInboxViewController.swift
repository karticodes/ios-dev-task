//
//  CMInboxViewController.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit
import CoreData
import MGSwipeTableCell
import AFDateHelper

class CMInboxViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintEdittingToolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var barButtonItemMark: UIBarButtonItem!
    @IBOutlet weak var barButtonItemArchive: UIBarButtonItem!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Mail")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "isMailDeleted", false)
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    var isEditting: Bool = false
    var selectedMailIds: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseFetchResultsController()
        fetchEmails()
        registerTableViewCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func itemsForNavigationBar() -> NavigationBarItems {
        return isEditting ? .Done : .Edit
    }
    
    override func titleForNavigationBar() -> String {
        return "Inbox"
    }
    
    func registerTableViewCells(){
        
        tableView.registerNib(UINib(nibName: "InboxMailTableViewCell", bundle: nil), forCellReuseIdentifier: "InboxMailTableViewCellIdentifier")
        tableView.tableFooterView = UIView()
    }
    
    func fetchEmails(){
        CMServiceManager.sharedInstance.fetchArrayRequest(.GET, url: CMServiceList.GetMessages, successHandler: { (mails: [MailModel]) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateInCoreData(mails)
                })
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.showSimpleAlert(error.title, message: error.message, cancel: "OK")
                })
        }
    }
    
    func updateInCoreData(mails: [MailModel]){
        
        for mail in mails{
            let fetchRequest = NSFetchRequest(entityName: "Mail")
            fetchRequest.predicate = NSPredicate(format: "%K == %d", "id", mail.id)
            
            do {
                let result = try managedObjectContext.executeFetchRequest(fetchRequest)
                guard result.count == 0 else { return }
                
                let entityDescription = NSEntityDescription.entityForName("Mail", inManagedObjectContext: managedObjectContext)
                let newMail = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                
                newMail.setValue(mail.subject, forKey: "subject")
                newMail.setValue(mail.preview, forKey: "preview")
                newMail.setValue(mail.isRead, forKey: "isRead")
                newMail.setValue(mail.isStarred, forKey: "isStarred")
                newMail.setValue(mail.id, forKey: "id")
                newMail.setValue(mail.date, forKey: "date")
                var set = Set<NSManagedObject>()
                for participant in mail.participants{
                    let entityDescription = NSEntityDescription.entityForName("Participant", inManagedObjectContext: managedObjectContext)
                    let newParticipant = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                    newParticipant.setValue(participant, forKey: "name")
                    set.insert(newParticipant)
                }
                newMail.setValue(set, forKey: "participants")
                
            } catch {
                print(error)
            }
        }
    }
}

//MARK: - Editting
extension CMInboxViewController{
    
    override func editButtonClicked() {
        isEditting = true
        updateNavigationItems()
        performEditAction()
    }
    
    override func doneButtonClicked() {
        isEditting = false
        updateNavigationItems()
        cancelEditAction()
    }
    
    func shouldMarkAsRead() -> Bool{
        guard let objects = fetchedResultsController.sections?[0].objects else { return true }

        if selectedMailIds.count == 0{
            for mail in objects{
                if let isRead = mail.valueForKey("isRead") as? Bool where !isRead{
                    return true
                }
            }
        }else{
            for mail in objects{
                if let mailId = mail.valueForKey("id") as? Int where selectedMailIds.contains(mailId){
                    if let isRead = mail.valueForKey("isRead") as? Bool where !isRead{
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func performEditAction(){
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 0, 44))
        constraintEdittingToolbarHeight.constant = 0
        UIView.animateWithDuration(0.2) { 
            self.view.layoutIfNeeded()
        }
        mailSelectionChanged()
    }
    
    func cancelEditAction(){
        tableView.tableFooterView = UIView()
        constraintEdittingToolbarHeight.constant = -44
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
        selectedMailIds.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func markButtonClicked(sender: UIBarButtonItem) {
        
        guard let objects = fetchedResultsController.sections?[0].objects else { return }
        let markAsRead = shouldMarkAsRead()
        
        if selectedMailIds.count == 0{
            for mail in objects{
                mail.setValue(markAsRead, forKey: "isRead")
            }
        }else{
            for mail in objects{
                if let mailId = mail.valueForKey("id") as? Int where selectedMailIds.contains(mailId){
                    mail.setValue(markAsRead, forKey: "isRead")
                }
            }
        }
        saveContext()
        doneButtonClicked()
    }
    
    @IBAction func archiveButtonClicked(sender: AnyObject) {
        guard let objects = fetchedResultsController.sections?[0].objects else { return }
        
        if selectedMailIds.count == 0{
            for mail in objects{
                mail.setValue(true, forKey: "isMailDeleted")
            }
        }else{
            for mail in objects{
                if let mailId = mail.valueForKey("id") as? Int where selectedMailIds.contains(mailId){
                    mail.setValue(true, forKey: "isMailDeleted")
                }
            }
        }
        saveContext()
        doneButtonClicked()
    }
    
    func getReadButtonTitle() -> String{
        return shouldMarkAsRead() ? "Read" : "Unread"
    }
    
    func mailSelectionChanged(){
        
        if selectedMailIds.count == 0{
            barButtonItemMark.title = "Mark all as " + getReadButtonTitle()
            barButtonItemArchive.title = "Archive all"
        }else{
            barButtonItemMark.title = "Mark as " + getReadButtonTitle()
            barButtonItemArchive.title = "Archive"
        }
    }
}

//MARK: - TableView Delegate and Datasource
extension CMInboxViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxMailTableViewCellIdentifier") as! InboxMailTableViewCell
        configureMailCell(cell, atIndexPath: indexPath)
        cell.delegate = self
        cell.mailDelegate = self
        return cell
    }
    
    func configureMailCell(cell: InboxMailTableViewCell, atIndexPath indexPath: NSIndexPath){
        
        let mail = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let participantsObj = mail.valueForKey("participants") as? NSSet {
            var participants = [String]()
            for participantObj in participantsObj{
                if let name = participantObj.valueForKey("name") as? String{
                    participants.append(name)
                }
            }
            cell.labelParticipants?.text = participants.joinWithSeparator(", ")
        }
        
        if let subject = mail.valueForKey("subject") as? String {
            cell.labelSubject.text = subject
        }
        
        if let preview = mail.valueForKey("preview") as? String {
            cell.labelPreview.text = preview
        }
        
        if let isRead = mail.valueForKey("isRead") as? Bool {
            cell.isRead = isRead
        }

        if let isStarred = mail.valueForKey("isStarred") as? Bool {
            cell.buttonStar.selected = isStarred
        }
        
        if let date = mail.valueForKey("date") as? NSDate {
            cell.labelDate.text = date.isToday() ? date.toString(format: .Custom("hh:mm a")) : date.toString(format: .Custom("dd/MM"))
        }
        
        if isEditting, let mailId = mail.valueForKey("id") as? Int where selectedMailIds.contains(mailId) {
            cell.backgroundColor = UIColor(r: 197, g: 239, b: 247, a: 0.5)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let mail = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject else { return }
        
        if isEditting{
            
            guard let id = mail.valueForKey("id") as? Int else { return }
            if selectedMailIds.contains(id){
                selectedMailIds.removeObject(id)
            }else{
                selectedMailIds.append(id)
            }
            mailSelectionChanged()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }else{
            
            guard let mailVC: MailViewController = instanciateWithIdentifier("MailViewController") else { return }
            
            mailVC.mail = mail
            self.navigationController?.pushViewController(mailVC, animated: true)
        }
    }
}

//MARK: - Swipe TableCell Delegate
extension CMInboxViewController: MGSwipeTableCellDelegate, InboxMailTableViewCellDelegate{
    
    func didClickStarButtonInCell(cell: InboxMailTableViewCell) {
        guard let indexPath = tableView.indexPathForCell(cell) else { return }
        guard let mail = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject else { return }
        guard let isStarred = mail.valueForKey("isStarred") as? Bool else { return }
        mail.setValue(!isStarred, forKey: "isStarred")
        saveContext()
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return !isEditting
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        
        guard let cell = cell as? InboxMailTableViewCell else { return [] }
        
        swipeSettings.transition = .Border;
        expansionSettings.buttonIndex = 0;
        expansionSettings.fillOnTrigger = true
        expansionSettings.threshold = 1.0
        
        switch direction {
        case .LeftToRight:
            return [MGSwipeButton(title: cell.isRead ? "Mark as Unread" : "Mark as Read", backgroundColor: UIColor(r: 52, g: 152, b: 219))]
        case .RightToLeft:
            return [MGSwipeButton(title: "Archive", backgroundColor: UIColor.redColor())]
        }
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        guard let cell = cell as? InboxMailTableViewCell else { return false }
        guard let indexPath = tableView.indexPathForCell(cell) else { return false }
        guard let mail = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject else { return false }
        
        switch direction {
        case .LeftToRight:
            guard let isRead = mail.valueForKey("isRead") as? Bool else { return false }
            mail.setValue(!isRead, forKey: "isRead")
            if let markReadButton = cell.leftButtons[0] as? UIButton{
                markReadButton.setTitle(!isRead ? "Mark as Unread" : "Mark as Read", forState: .Normal)
            }
        case .RightToLeft:
            mail.setValue(true, forKey: "isMailDeleted")
        }
        saveContext()
        return true
    }
}

//MARK: - Fetch Results Controller Delegate
extension CMInboxViewController: NSFetchedResultsControllerDelegate{
    
    func initialiseFetchResultsController(){
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch (type) {
        case .Insert:
            guard let indexPath = newIndexPath else { return }
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            guard let indexPath = indexPath else { return }
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? InboxMailTableViewCell else { return }
            configureMailCell(cell, atIndexPath: indexPath)
        default: break
        }
    }
}
