//
//  AccountVC+Email.swift
//  Textor
//
//  Created by Eugene Golovanov on 6/6/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit
import MessageUI

extension AccountVC : MFMailComposeViewControllerDelegate {
    //--------------------------------------------------------------------------
    //MARK: - MFMailComposeViewControllerDelegate Setup
    
    func sendEmail() {
        let mailComposeViewController = configureMail()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            //NO Email Account Setup on iPhone
            mailAlert()
        }
    }
    
    func configureMail() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["textorapp@gmail.com"])
        mailComposeVC.setSubject("Subject")
        mailComposeVC.setMessageBody("Hi.\n I Have some feedback:\n", isHTML: false)
        return mailComposeVC
    }
    
    func mailAlert() {
        let alertController = UIAlertController(title: "Alert", message: "No e-mail account setup for iPhone", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action  in
            //do something
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //Mail Compose Delegate method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail Cancelled")
        case MFMailComposeResult.failed.rawValue:
            print("Mail Failed")
        case MFMailComposeResult.saved.rawValue:
            print("Mail Saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail Sent")
        default:
            print("Unknown Issue")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

