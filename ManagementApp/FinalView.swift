//
//  FinalView.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/22/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

@IBDesignable class FinalView: BaseCustomView {
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var noDataView: NoDataView!
    
    @IBOutlet weak var lblFinalTeam1: UILabel!
    @IBOutlet weak var lblFinalTeam2: UILabel!
    @IBOutlet weak var lblFinalTeam3: UILabel!
    @IBOutlet weak var lblFinalTeam4: UILabel!
    
    @IBOutlet weak var imvFinalTeam1: UIImageView!
    @IBOutlet weak var imvFinalTeam2: UIImageView!
    @IBOutlet weak var imvFinalTeam3: UIImageView!
    @IBOutlet weak var imvFinalTeam4: UIImageView!
    
    @IBOutlet weak var lblFinalTeam1Points: UILabel!
    @IBOutlet weak var lblFinalTeam2Points: UILabel!
    @IBOutlet weak var lblFinalTeam3Points: UILabel!
    @IBOutlet weak var lblFinalTeam4Points: UILabel!
    
    @IBOutlet weak var btnFinalTeam1: UIButton!
    @IBOutlet weak var btnFinalTeam2: UIButton!
    @IBOutlet weak var btnFinalTeam3: UIButton!
    @IBOutlet weak var btnFinalTeam4: UIButton!
    
    var strGetFinalTeamsApi = ""
    var strCin = ""
    
    var GetAllTeamElementMain = [GetAllTeam]()
    var GetAllTeamObjMain = [GetAllTeamObj]()
    var GetSemiFinaListTeamObj = [FlagData]()
    
    var AddFinalDetailElementMain = [AddLeagueMatchDetailElement]()
    var AddFinalDetailObjMain = [AddLeagueMatchDetailObj]()
    
    var strAddFinalTeamApi = ""
    
    var teamId = ""
    var winnerId = 0
    var FlagsArr = [FlagData]()
    
    var initIndex1 = 0
    var initIndex2 = 0
    var initIndex3 = 0
    var initIndex4 = 0
    
    var isFinalOpen = false
    
    override func xibSetup() {
        super.xibSetup()
        
        for i in 0...3{
            self.GetSemiFinaListTeamObj.append(FlagData(flag: "", teamName: "", teamId: 0 , points: 0.0))
        }
        
        FlagsArr = Utility.getFlags()
        
        //   self.btnFinalTeam1.isSelected = true
        
        // Do any additional setup after loading the view.
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        strGetFinalTeamsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["team"] as? String ?? "")
        strAddFinalTeamApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["addPartyFinalMatchSummary"] as? String ?? "")
        
//        strGetFinalTeamsApi = "https://test2.goldmedalindia.in/api/GetTeam"
//        strAddFinalTeamApi = "https://test2.goldmedalindia.in/api/AddPartyFinalMatchSummary"
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiGetFinalTeams()
                self.noDataView.hideView(view: self.noDataView)
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
    }
    
    @IBAction func highlightTrack(button: UIButton) {
        
        print("select")
        if(self.btnSubmit.currentTitle?.elementsEqual("Modify") ?? false){
            var alert = UIAlertView(title: "Modify", message: "Please make sure you click on Modify first", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }else{
            if button.isSelected {
                return
            }
            
            btnFinalTeam1.isSelected = false
            btnFinalTeam2.isSelected = false
            btnFinalTeam3.isSelected = false
            btnFinalTeam4.isSelected = false
            
            button.isSelected = true
            
            self.winnerId = (self.GetSemiFinaListTeamObj[button.tag].teamId ?? 0)!
            print("winner id in btn - - - - ", self.winnerId)
        
        }
        
    }
    
    
    // - - - - - - - Logic for final with corresponding api's - - - - - - - - --  - -
    // - - - - - -  Api to show all teams for final screen  - - - - - - - -
    func apiGetFinalTeams(){
        var count = 0
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"fefef"]
        
        DataManager.shared.makeAPICall(url: strGetFinalTeamsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                
                do {
                    self.GetAllTeamElementMain = try JSONDecoder().decode([GetAllTeam].self, from: data!)
                    self.GetAllTeamObjMain = self.GetAllTeamElementMain[0].data
                    
                    for i in 0...(self.GetAllTeamObjMain.count - 1){
                        
                        if(i == 0){
                            self.GetSemiFinaListTeamObj[0] = FlagData(flag: "ind_flag", teamName: self.GetAllTeamObjMain[i].teamName, teamId: self.GetAllTeamObjMain[i].teamId , points: (self.GetAllTeamObjMain[i].point ?? 0.0)!)
                            
                            self.lblFinalTeam1Points.text = String((self.GetSemiFinaListTeamObj[0].points ?? 0.0)!)+"%"
                            
                        }else{
                            if(self.GetAllTeamObjMain[i].issemifinal == 1){
                                count+=1
                                if(count < 4){

                                    self.GetSemiFinaListTeamObj[count] = FlagData(flag: "country", teamName: self.GetAllTeamObjMain[i].teamName, teamId: self.GetAllTeamObjMain[i].teamId , points: (self.GetAllTeamObjMain[i].point ?? 0.0)!)
                                    
                                    self.lblFinalTeam2Points.text = String((self.GetSemiFinaListTeamObj[1].points ?? 0.0)!)+"%"
                                    self.lblFinalTeam3Points.text = String((self.GetSemiFinaListTeamObj[2].points ?? 0.0)!)+"%"
                                    self.lblFinalTeam4Points.text = String((self.GetSemiFinaListTeamObj[3].points ?? 0.0)!)+"%"
                                    
                                    print("MATCH inside - - - - - ",self.GetAllTeamObjMain[i].point)
                                    print("MATCH - - - - - ",self.GetSemiFinaListTeamObj[count].points)
                                    print("MATCH 1 - - - - - ",self.GetSemiFinaListTeamObj[1].points)
                                    print("MATCH 2 - - - - - ",self.GetSemiFinaListTeamObj[2].points)
                                    print("MATCH 3 - - - - - ",self.GetSemiFinaListTeamObj[3].points)
                                }
                                print("MATCH - - - - - ",self.GetAllTeamObjMain[i].point)
                            }
                        }
                        
                        if(self.GetAllTeamObjMain[i].iswinner == 1){
                            self.winnerId = (self.GetAllTeamObjMain[i].teamId ?? 1)!
                        }
                        
                        
                    }
                    
                    
                    print("count - - - - ",count)
                    
                    
                    var SemiTeam1Id = (self.GetSemiFinaListTeamObj[0].teamId ?? 0)!
                    var SemiTeam2Id = (self.GetSemiFinaListTeamObj[1].teamId ?? 0)!
                    var SemiTeam3Id = (self.GetSemiFinaListTeamObj[2].teamId ?? 0)!
                    var SemiTeam4Id = (self.GetSemiFinaListTeamObj[3].teamId ?? 0)!
                    
                    // self.initIndex1 =  self.FlagsArr.index(where: { $0.teamId == SemiTeam1Id }) ?? 0
                    self.initIndex2 =  self.FlagsArr.index(where: { $0.teamId == SemiTeam2Id }) ?? 0
                    self.initIndex3 =  self.FlagsArr.index(where: { $0.teamId == SemiTeam3Id }) ?? 0
                    self.initIndex4 =  self.FlagsArr.index(where: { $0.teamId == SemiTeam4Id }) ?? 0
                    
                    // self.GetSemiFinaListTeamObj[0] = self.FlagsArr[self.initIndex1]
                    self.GetSemiFinaListTeamObj[1] = self.FlagsArr[self.initIndex2]
                    self.GetSemiFinaListTeamObj[2] = self.FlagsArr[self.initIndex3]
                    self.GetSemiFinaListTeamObj[3] = self.FlagsArr[self.initIndex4]
                    
                    
                    self.imvFinalTeam1.image = UIImage(named: self.GetSemiFinaListTeamObj[0].flag ?? "")
                    self.imvFinalTeam2.image = UIImage(named: self.GetSemiFinaListTeamObj[1].flag ?? "")
                    self.imvFinalTeam3.image = UIImage(named: self.GetSemiFinaListTeamObj[2].flag ?? "")
                    self.imvFinalTeam4.image = UIImage(named: self.GetSemiFinaListTeamObj[3].flag ?? "")
                    
                    self.lblFinalTeam1.text = ((self.GetSemiFinaListTeamObj[0].teamName ?? "-")!).uppercased()
                    self.lblFinalTeam2.text = ((self.GetSemiFinaListTeamObj[1].teamName ?? "-")!).uppercased()
                    self.lblFinalTeam3.text = ((self.GetSemiFinaListTeamObj[2].teamName ?? "-")!).uppercased()
                    self.lblFinalTeam4.text = ((self.GetSemiFinaListTeamObj[3].teamName ?? "-")!).uppercased()
                    
                   
                   
                    
                    if(self.winnerId == self.GetSemiFinaListTeamObj[0].teamId){
                        self.btnFinalTeam1.isSelected = true
                    }else if(self.winnerId == self.GetSemiFinaListTeamObj[1].teamId){
                        self.btnFinalTeam2.isSelected = true
                    }else if(self.winnerId == self.GetSemiFinaListTeamObj[2].teamId){
                        self.btnFinalTeam3.isSelected = true
                    }else if(self.winnerId == self.GetSemiFinaListTeamObj[3].teamId){
                        self.btnFinalTeam4.isSelected = true
                    }
                    
                    if(self.btnFinalTeam1.isSelected || self.btnFinalTeam2.isSelected ||
                        self.btnFinalTeam3.isSelected || self.btnFinalTeam4.isSelected)
                    {
                        self.btnSubmit.setTitle("Modify", for: .normal)
                    }
                    
                    if(count < 3){
                        // self.noDataView.showView(view: self.noDataView, from: "NDA")
                        self.btnSubmit.isHidden = true
                        
                        var alert = UIAlertView(title: "Invalid", message: "Please select semi final teams first", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.btnFinalTeam1.isSelected = false
                        self.btnFinalTeam2.isSelected = false
                        self.btnFinalTeam3.isSelected = false
                        self.btnFinalTeam4.isSelected = false
                        
                        self.btnFinalTeam1.isUserInteractionEnabled = false
                        self.btnFinalTeam2.isUserInteractionEnabled = false
                        self.btnFinalTeam3.isUserInteractionEnabled = false
                        self.btnFinalTeam4.isUserInteractionEnabled = false
                        
                        
                        self.imvFinalTeam2.image = UIImage(named: "country")
                        self.imvFinalTeam3.image = UIImage(named: "country")
                        self.imvFinalTeam4.image = UIImage(named: "country")
                        
                        
                        self.lblFinalTeam2.text = ""
                        self.lblFinalTeam3.text = ""
                        self.lblFinalTeam4.text = ""
                        
                    }
                    
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
            }
            self.noDataView.hideView(view: self.noDataView)
        }) { (Error) in
            self.noDataView.hideView(view: self.noDataView)
            print(Error?.localizedDescription)
        }
        
    }
    
    // - - - - - - submit prediction for final - - - - - - -
    @IBAction func SubmitFinal(_ sender: UIButton) {
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            if(self.btnFinalTeam1.isSelected || self.btnFinalTeam2.isSelected || self.btnFinalTeam3.isSelected || self.btnFinalTeam4.isSelected){
                
                if(self.btnSubmit.currentTitle?.elementsEqual("Modify") ?? false){
                    var alert = UIAlertView(title: "Success!!!", message: "You can make Winner Prediction changes now", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                 
                    self.btnSubmit.setTitle("Submit", for: .normal)
                    return
                }else{
                    self.apiAddFinalTeamsPrediction()
                }
            }else{
                var alert = UIAlertView(title: "Failed!!", message: "Please select a team", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            }
            
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    
    // - - - - - -  Api to add  final predicted team  - - - - - - - -
    func apiAddFinalTeamsPrediction(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"TeamId":"0,0","Winner":String(winnerId),"ClientSecret":"fefef"]
        
        print("apiAddFinalTeamsPrediction",json)
        
        DataManager.shared.makeAPICall(url: strAddFinalTeamApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.AddFinalDetailElementMain = try JSONDecoder().decode([AddLeagueMatchDetailElement].self, from: data!)
                    self.AddFinalDetailObjMain = self.AddFinalDetailElementMain[0].data
                    
                    let result = self.AddFinalDetailElementMain[0].result ?? false
                    
                    let message = self.AddFinalDetailObjMain[0].output ?? "-"
                    
                    if(result){
                        var alert = UIAlertView(title: "Success!!!", message: message, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.btnSubmit.setTitle("Modify", for: .normal)
                    }
                    
                } catch let errorData {
                    
                    var alert = UIAlertView(title: "Failed!!!", message: "Server Error", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    print(errorData.localizedDescription)
                }
                
            }
            ViewControllerUtils.sharedInstance.removeLoader()
        }) { (Error) in
            var alert = UIAlertView(title: "Error", message: "Server Error", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    
    
    func updateButtionSelectionState(button: UIButton, isSelected: Bool) {
        button.isSelected = isSelected
        button.backgroundColor = isSelected ? UIColor.blue : UIColor.white
    }
    
    
    
}
