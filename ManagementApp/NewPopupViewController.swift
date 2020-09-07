//
//  NewPopupViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 19/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//
struct PartyDetail: Codable {
    let result: Bool?
    let message, servertime: String?
    let data: [PartyDetailObj]
}

// MARK: - Datum
struct PartyDetailObj: Codable {
    let partyName, partyType, city, area: String?
    let executiveName, executivephno, extraCDDays: String?
}
import UIKit

class NewPopupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Outlets...
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var lblPickerHeader: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    //Declarations...
    var delegate: PopupDateDelegate?
    var cellContentIdentifier = "\(CollectionViewCell.self)"
    var partyDetail = [PartyDetail]()
    var partyDetailObj = [PartyDetailObj]()
    var filteredItems = [PartyDetailObj]()
    var apiPartyDetail = ""
    var partyId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        specialEffects()
        apiPartyDetail = "https://api.goldmedalindia.in/api/getcinwisepartydetail"
        apiGetPartyDetail()
        ViewControllerUtils.sharedInstance.showLoader()
    }
    
    //Corner Radius and Blurr Effect...
    func specialEffects(){
        //Corner Radius [Selective]...
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.topView.frame
        rectShape.position = self.topView.center
        rectShape.path = UIBezierPath(roundedRect: self.topView.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 14, height: 14)).cgPath
        //self.topView.layer.mask = rectShape
        let roundCorner = CAShapeLayer()
        roundCorner.bounds = self.bottomView.frame
        roundCorner.position = self.bottomView.center
        roundCorner.path = UIBezierPath(roundedRect: self.bottomView.bounds, byRoundingCorners: [.bottomRight , .bottomLeft], cornerRadii: CGSize(width: 14, height: 14)).cgPath
        //self.bottomView.layer.mask = roundCorner
        
        //Blur Effect...
        if !UIAccessibility.isReduceTransparencyEnabled {
            mainView.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mainView.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            mainView.sendSubview(toBack: blurEffectView)
        }
    }
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
    }
    
    func setNormalText(value: String) -> NSAttributedString{
        let attributedString = NSAttributedString(string: NSLocalizedString(value, comment: ""), attributes:[
            NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        return attributedString
    }
    
    //CollectionView Functions...
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: cellContentIdentifier,
                                                      for: indexPath) as! CollectionViewCell
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        cell.contentLabel.font = UIFont(name: "Roboto-Regular", size: 14)
        if #available(iOS 11.0, *) {
            cell.backgroundColor = UIColor.init(named: "primaryLight")
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        if filteredItems.count > 0{
            if indexPath.row == 0{
                switch indexPath.section{
                case 0:
                    cell.contentLabel.attributedText = setNormalText(value: "Party Name")
                case 1:
                    cell.contentLabel.attributedText = setNormalText(value: "Party Type")
                case 2:
                    cell.contentLabel.attributedText = setNormalText(value: "City")
                case 3:
                    cell.contentLabel.attributedText = setNormalText(value: "Area")
                case 4:
                    cell.contentLabel.attributedText = setNormalText(value: "Executive Name")
                case 5:
                    cell.contentLabel.attributedText = setNormalText(value: "Mobile")
                case 6:
                    cell.contentLabel.attributedText = setNormalText(value: "Extra CD Days")
                default:
                    break
                }
            } else if indexPath.row == 1{
                switch indexPath.section{
                case 0:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[0].partyName!)
                case 1:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[0].partyType!)
                case 2:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[0].city!)
                case 3:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[0].area!)
                case 4:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[0].executiveName!)
                case 5:
                    let attributedString = NSAttributedString(string: NSLocalizedString((filteredItems[0].executivephno!), comment: ""), attributes:[
                        NSAttributedString.Key.foregroundColor : UIColor(named: "ColorBlue")!,
                        NSAttributedString.Key.underlineStyle:1.0
                        ])
                    cell.contentLabel.attributedText = attributedString
                case 6:
                    cell.contentLabel.attributedText = setNormalText(value: filteredItems[0].extraCDDays!)
                default:
                    break
                }
            }
            return cell
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 1 && indexPath.section == 5{
            dialNumber(number: filteredItems[0].executivephno!)
        }
    }
    
    //API Function...
    func apiGetPartyDetail(){
        let json: [String: Any] = ["CIN":partyId,"ClientSecret":"ohdashfl"]
        let manager =  DataManager.shared
        print("apiGetPartyDetail Params \(json)")
        manager.makeAPICall(url: apiPartyDetail, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.partyDetail = try JSONDecoder().decode([PartyDetail].self, from: data!)
                self.partyDetailObj = self.partyDetail[0].data
                self.filteredItems = self.partyDetail[0].data
                self.CollectionView.reloadData()
                self.CollectionView.collectionViewLayout.invalidateLayout()
                ViewControllerUtils.sharedInstance.removeLoader()
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
            ViewControllerUtils.sharedInstance.removeLoader()
        }
    }
    

}
