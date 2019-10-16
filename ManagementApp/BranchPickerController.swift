//
//  BranchPickerController.swift
//  ManagementApp
//
//  Created by Goldmedal on 04/04/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
struct BranchData: Codable {
    let result, message, servertime: String?
    let data: [BranchObj]
}

struct BranchObj: Codable {
    let branchid: Int?
    let branchnm: String?
}
class BranchPickerController: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var lblPickerHeader: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    var branchData = [BranchData]()
    var branchObj = [BranchObj]()
    var strSelectedValue = ""
    var rowPosition = 0
    var delegate: PopupDateDelegate?
    var apiGetBranchUrl = ""
    
    var pickerDataSource = ["All"]
    var showPicker = Int()
    
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        if(strSelectedValue.isEmpty){
            strSelectedValue = pickerDataSource[0]
        }
        delegate?.updateBranch!(value: strSelectedValue, position: rowPosition)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.dataSource = self;
        self.picker.delegate = self;
        specialEffects()
        apiGetBranchUrl = "https://api.goldmedalindia.in/api/getListsofAllBranch"
        apiGetBranch()
    }
    
    //Corner Radius and Blurr Effect...
    func specialEffects(){
        //Corner Radius [Selective]...
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.topView.frame
        rectShape.position = self.topView.center
        rectShape.path = UIBezierPath(roundedRect: self.topView.bounds, byRoundingCorners: [.topRight , .topLeft], cornerRadii: CGSize(width: 14, height: 14)).cgPath
        self.topView.layer.mask = rectShape
        let roundCorner = CAShapeLayer()
        roundCorner.bounds = self.bottomView.frame
        roundCorner.position = self.bottomView.center
        roundCorner.path = UIBezierPath(roundedRect: self.bottomView.bounds, byRoundingCorners: [.bottomRight , .bottomLeft], cornerRadii: CGSize(width: 14, height: 14)).cgPath
        self.bottomView.layer.mask = roundCorner
        
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strSelectedValue = pickerDataSource[row]
        rowPosition = row
    }
    
    func apiGetBranch(){
        
        let json: [String: Any] = ["ClientSecret":"clientsecret","CIN":"sa@sa.com","Category":"Management"]
        
        let manager =  DataManager.shared
        
        manager.makeAPICall(url: apiGetBranchUrl, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.branchData = try JSONDecoder().decode([BranchData].self, from: data!)
                self.branchObj  = self.branchData[0].data
                if self.showPicker == 1 {
                    for qty in self.branchObj{
                        self.pickerDataSource.append(qty.branchnm!)
                    }
                }
                self.picker.reloadAllComponents()
                
            } catch let errorData {
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            print(Error?.localizedDescription as Any)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
