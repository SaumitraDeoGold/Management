//
//  TodGroupFilterPopupController.swift
//  GStar
//
//  Created by Goldmedal on 19/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import DropDown

protocol TodFilterDelegate: class {
    
    
    func updateTod(strGroupTitle : String,strGroupId : String,strTodAccepted : String)
    
    
}



class TodGroupFilterPopupController: UIViewController {
    
    let dropDown = DropDown()
    
    var TodGroupsArray = [TodGroupsData]()
    var strTodGroupsArray = [String]()
    
    
    @IBOutlet weak var switchTod: UISwitch!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var vwDropDown: RoundView!
    @IBOutlet weak var lblDivision: UILabel!
    
    
    weak var delegate: TodFilterDelegate?
    
    var strGroupId = ""
    var strGroupTitle = ""
    var strTodAccepted = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.clickDropdown))
        vwDropDown.isUserInteractionEnabled = true
        vwDropDown.addGestureRecognizer(gesture)
        
        setupDropDown()
        
        toggleSwitch()
        
        
    }
    
    @IBAction func switchTod(_ sender: UISwitch) {
        
        
        if(sender.isOn == true){
            strTodAccepted = "1"
            print("ON")
        }else{
            strTodAccepted = "0"
            print("OFF")
        }
    }
    
    
    func setupDropDown(){
        
        
        var divisionIndex = 0
        
        if(self.TodGroupsArray.count > 0){
            for i in 0...(self.TodGroupsArray.count-1)
            {
                
                self.strTodGroupsArray.append(self.TodGroupsArray[i].groupnm ?? "-")
                if(strGroupId.elementsEqual(self.TodGroupsArray[i].groupid ?? "-1")){
                    divisionIndex = i
                }
            }
            
            self.dropDown.dataSource = self.strTodGroupsArray
            dropDown.selectRow(at: divisionIndex)
            self.lblDivision.text = self.dropDown.dataSource[divisionIndex]
            self.strGroupId =  (self.TodGroupsArray[divisionIndex].groupid ?? "-1")!
            self.strGroupTitle =  (self.TodGroupsArray[divisionIndex].groupnm ?? "-1")!
            self.dropDown.dismissMode = .onTap
            
            
            
        }
    }
    
    
    func toggleSwitch(){
        
        if(strTodAccepted.elementsEqual("1")){
            
            switchTod.setOn(true, animated: false)
        }else{
            switchTod.setOn(false, animated: false)
        }
    }
    
    

@IBAction func cancel_clicked(_ sender: UIButton) {
    dismiss(animated: true)
}


@IBAction func ok_clicked(_ sender: UIButton) {
    
    
    delegate?.updateTod(strGroupTitle: strGroupTitle, strGroupId: strGroupId, strTodAccepted: strTodAccepted)
    dismiss(animated: true)
}


@objc func clickDropdown(_ sender:UITapGestureRecognizer){
    
    dropDown.show()
    
    // The view to which the drop down will appear on
    dropDown.anchorView = vwDropDown
    
    
    // Action triggered on selection
    dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
        print("Selected item: \(item) at index: \(index)")
        self.lblDivision.text = item
        
        // self.leaveReasonsIndex = index
        print("LEAVE REASONS INDEX - - -",index)
        self.strGroupId = (self.TodGroupsArray[index].groupid ?? "-1")!
        self.strGroupTitle = (self.TodGroupsArray[index].groupnm ?? "")!
        print("LEAVE REASONS ID - - -",self.strGroupId)
        
        
        self.dropDown.hide()
        
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

}
