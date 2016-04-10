//
//  MailViewController.swift
//  CMTestApp
//
//  Created by Karti on 09/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit
import CoreData

class MailViewController: BaseViewController {
    
    var mail: NSManagedObject!
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var textViewParticipants: UITextView!
    @IBOutlet weak var labelBody: UILabel!
    @IBOutlet weak var buttonStar: UIButton!
    @IBOutlet weak var constraintHeightParticipantsLabel: NSLayoutConstraint!
    @IBOutlet weak var constarintHeightSubjectLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightBodyLabel: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func itemsForNavigationBar() -> NavigationBarItems {
        return [.Back, .Delete]
    }
    
    override func titleForNavigationBar() -> String {
        return ""
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        populateMail()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLabelHeights()
    }
    
    func updateLabelHeights(){
        
        constarintHeightSubjectLabel.constant = labelSubject.sizeThatFits(labelSubject.frame.size).height
        constraintHeightParticipantsLabel.constant = textViewParticipants.sizeThatFits(textViewParticipants.frame.size).height
        constraintHeightBodyLabel.constant = labelBody.sizeThatFits(labelBody.frame.size).height
    }
    
    func populateMail(){
        guard let _ = mail else { return }
        populateBasicMailInfo()
        guard let id = mail.valueForKey("id")  as? Int else { return }
        fetchEmailDetails(id)
    }
    
    func fetchEmailDetails(id: Int){
        
        let fetchMailById = String(format: CMServiceList.GetMessageById, id)
        CMServiceManager.sharedInstance.fetchRequest(url: fetchMailById, successHandler: { (response: MailDetailModel) in
            dispatch_async(dispatch_get_main_queue(), {
                self.populateDetailMailInfo(response)
            })
            }) { (error) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.showSimpleAlert(error.title, message: error.message, cancel: "OK", handler: { (_) in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                })
        }
    }
    
    @IBAction func starButtonClicked(sender: UIButton) {
        
        buttonStar.selected = !buttonStar.selected
        mail.setValue(buttonStar.selected, forKey: "isStarred")
        saveContext()
    }
    
    func populateBasicMailInfo(){
        if let subject = mail.valueForKey("subject") as? String{
            labelSubject.text = subject
        }
        if let isStarred = mail.valueForKey("isStarred") as? Bool{
            buttonStar.selected = isStarred
        }
        if let participants = mail.valueForKey("participants") as? NSSet {
            updateParticipantsInfo(getBasicParticipantsContent(participants))
        }
        if let date = mail.valueForKey("date") as? NSDate {
            labelDate.text = date.toString(format: .Custom("dd/MM/yyyy hh:mm a"))
        }
    }
    
    func populateDetailMailInfo(detail: MailDetailModel){
        if let participants = detail.participants{
            updateParticipantsInfo(getDetailedParticipantsContent(participants))
        }
        labelBody.text = detail.body
        updateReadStatus()
        view.setNeedsDisplay()
    }
    
    func updateReadStatus(){
        guard let isRead = mail?.valueForKey("isRead") as? Bool where !isRead else { return }
        mail.setValue(true, forKey: "isRead")
        saveContext()
    }
    
    override func deleteButtonClicked() {
        mail.setValue(true, forKey: "isMailDeleted")
        saveContext()
        backButtonClicked()
    }
}

extension MailViewController: UITextViewDelegate{
    
    func getBasicParticipantsContent(participants: NSSet) -> String{
        var str = ""
        for participant in participants{
            if let name = participant.valueForKey("name") as? String{
                str += "<span>" + name + "; </span>"
            }
        }
        return str
    }
    
    func getDetailedParticipantsContent(participants: [ParticipantModel]) -> String{
        var str = ""
        for participant in participants{
            str += "<a href='mailto:" + participant.email + "'>" + participant.name + "</a><span>; </span>"
        }
        return str
    }
    
    func updateParticipantsInfo(str: String){
        
        textViewParticipants.contentInset = UIEdgeInsetsMake(-4,-4,0,0)
        do{
            let attrString = try NSMutableAttributedString(data: (str as NSString).dataUsingEncoding(NSUnicodeStringEncoding)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            attrString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSMakeRange(0, attrString.length))
            textViewParticipants.attributedText = attrString
        }catch{
            textViewParticipants.text = ""
        }
        textViewParticipants.delegate = self
        textViewParticipants.selectable = true
        textViewParticipants.delaysContentTouches = false
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
}
