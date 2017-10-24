//
//  StatusHistoryVC.swift
//  Textor
//
//  Created by Eugene Golovanov on 5/7/17.
//  Copyright © 2017 eugene golovanov. All rights reserved.
//

import UIKit

class StatusHistoryVC: UIViewController {
    
    static let WIDTH_OFFSET:CGFloat = 10
    static let HEIGHT_OFFSET:CGFloat = 10
    
    var message:Message?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var constraintLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoImageWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //BG Image
        if let patternImage = UIImage(named: "messageBG") {
            self.view.backgroundColor = UIColor(patternImage: patternImage)
        }
        
        self.textView.layer.cornerRadius = 12
        self.textView.clipsToBounds = true
        
        if let m = self.message {
            self.title = "\(m.type.capitalized) message"
            if m.type == MessageType.text.rawValue {
                
                self.photoImageView.isHidden = true//Hide Photo

                //Text Message
                var decodedText = ""
                if let d = m.text.base64Decoded() {
                    decodedText = d
                    self.textView.text = d
                }
                
                let maxWidth =  self.view.frame.width - self.view.frame.width/3
                let textFrame = StatusHistoryVC.rectForTextView(text: decodedText, font: UIFont.systemFont(ofSize: 17.0), maxWidth: maxWidth)
                self.constraintLabelHeight.constant = textFrame.height + StatusHistoryVC.HEIGHT_OFFSET/2
                self.constraintLabelWidth.constant = textFrame.width + StatusHistoryVC.WIDTH_OFFSET*2
                
                //If text message is super large
                if self.constraintLabelHeight.constant > self.view.frame.height - 200 {
                    self.constraintLabelHeight.constant = self.view.frame.height - 200
                }
                
                textView.textContainerInset = UIEdgeInsets(top: StatusHistoryVC.HEIGHT_OFFSET,
                                                           left: StatusHistoryVC.WIDTH_OFFSET,
                                                           bottom: StatusHistoryVC.HEIGHT_OFFSET,
                                                           right: StatusHistoryVC.WIDTH_OFFSET)
            } else if m.type == MessageType.photo.rawValue {
                //Photo Message
                self.textView.text = "Photo mess"
                if let m = self.message, let data = m.photoData, let image = UIImage(data: data) {
                    let maxSide:CGFloat = 200
                    
                    //Setup Image
                    self.photoImageView.image = image

                    //Calculate image size
                    let ratio = max(image.size.width, image.size.height)/min(image.size.width, image.size.height)
                    if image.size.width > image.size.height {
                        self.photoImageWidthConstraint.constant = maxSide
                        self.photoImageHeightConstraint.constant = maxSide/ratio
                    } else {
                        self.photoImageWidthConstraint.constant = maxSide/ratio
                        self.photoImageHeightConstraint.constant = maxSide
                    }
                    
                    //Setup label height and hide it
                    self.constraintLabelHeight.constant = self.photoImageHeightConstraint.constant
                    self.textView.isHidden = true//Hide Text
                }
            }
        }
    }
    
    //-------------------------------------------------------------------
    // MARK: - init and deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(StatusHistoryVC.refreshStatusHistory), name: NSNotification.Name(rawValue: "refreshStatusHistory"), object: nil)
    }
    
    deinit {
        if let m = self.message, let t = m.text.base64Decoded() {
            print("Deinit Status History with text: \(t)")
        } else {
            print("Deinit Status History EMPTY MESSAGE")
        }
        NotificationCenter.default.removeObserver(self)
    }

    //--------------------------------------------------------------------
    // MARK: - Helpers
    
    func refreshStatusHistory() {
        if let m = DataManager.model.currentUser?.getRealm().object(ofType: Message.self, forPrimaryKey: self.message?.creationId) {
            self.message = m
            self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
            print("Reloading tableView")
        }
    }

    class func rectForTextView(text: String, font: UIFont, maxWidth: CGFloat) -> CGRect {
        var txtView: UITextView = UITextView(frame: CGRect(x:0, y:0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        if txtView.frame.width > maxWidth - StatusHistoryVC.WIDTH_OFFSET {
            txtView = UITextView(frame: CGRect(x:0, y:0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        }
        txtView.font = font
        txtView.text = text
        txtView.sizeToFit()
        return txtView.frame
    }
}

extension StatusHistoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as? StatusHistoryCell else {
            magic("cell error")
            return UITableViewCell()
        }
        guard let m = self.message else { magic("no message"); return UITableViewCell() }
        let sh = m.statusHistory[indexPath.row]
        guard let c = self.getContact(readerId: sh.readerId) else { magic("no contact"); return UITableViewCell() }
        cell.configureCell(contact: c, statusHistory: sh)
        return cell
    }
    
    private func getContact(readerId:String) -> Contact? {
        guard let c = DataManager.model.currentUser?.getRealm().object(ofType: Contact.self, forPrimaryKey: readerId) else {
            magic("could not get contact")
           return nil
        }
        return c
    }
    
    
    //Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.message?.statusHistory.count == 0 {
            let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 30))
            headerLabel.font = UIFont.systemFont(ofSize: 12)
            headerLabel.text = "Message is not delivered yet"
            headerLabel.sizeToFit()
            headerLabel.backgroundColor = UIColor.clear
            headerLabel.textAlignment = NSTextAlignment.center
            return headerLabel
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.message?.statusHistory.count == 0 {
            return 50
        }
        return 20
    }
    
}

extension StatusHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let m = self.message {
            return m.statusHistory.count
        }
        return 0
    }
}



