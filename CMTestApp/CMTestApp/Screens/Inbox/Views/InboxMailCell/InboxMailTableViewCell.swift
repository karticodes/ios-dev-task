//
//  InboxMailTableViewCell.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit
import MGSwipeTableCell

protocol InboxMailTableViewCellDelegate{
    
    func didClickStarButtonInCell(cell: InboxMailTableViewCell)
}

class InboxMailTableViewCell: MGSwipeTableCell {

    var mailDelegate: InboxMailTableViewCellDelegate?
    
    @IBOutlet weak var viewIndicator: CircularIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var labelParticipants: UILabel!
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var labelPreview: UILabel!
    @IBOutlet weak var buttonStar: UIButton!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var leadingSpaceParticipantsLabel: NSLayoutConstraint!
    
    var isRead: Bool = false{
        didSet{
            backgroundColor = isRead ? UIColor(r: 243, g: 243, b: 243) : UIColor.whiteColor()
            leadingSpaceParticipantsLabel.constant = isRead ? 0 : 18
            viewIndicator.hidden = isRead
            layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func starButtonClicked(sender: UIButton) {
        guard let mailDelegate = mailDelegate else { return }
        mailDelegate.didClickStarButtonInCell(self)
    }
}
