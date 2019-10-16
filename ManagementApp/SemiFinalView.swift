//
//  SemiFinalView.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/22/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

@IBDesignable class SemiFinalView: BaseCustomView, iCarouselDataSource, iCarouselDelegate {
    
    
    @IBOutlet weak var svSelectSemisMain: UIStackView!
    @IBOutlet weak var svModifySemisMain: UIStackView!
    
    @IBOutlet weak var btnSubmitSemis: UIButton!
    @IBOutlet weak var imvTeam1: UIImageView!
    
    @IBOutlet var vwCarousel1: iCarousel!
    @IBOutlet var vwCarousel2: iCarousel!
    @IBOutlet var vwCarousel3: iCarousel!
    
    @IBOutlet weak var btnModifySemis: UIButton!
    @IBOutlet weak var imvModifyTeam1: UIImageView!
    @IBOutlet weak var imvModifyTeam2: UIImageView!
    @IBOutlet weak var imvModifyTeam3: UIImageView!
    @IBOutlet weak var imvModifyTeam4: UIImageView!
    
    @IBOutlet weak var lblSemiResultTeam1: UILabel!
    @IBOutlet weak var lblSemiResultTeam2: UILabel!
    @IBOutlet weak var lblSemiResultTeam3: UILabel!
    @IBOutlet weak var lblSemiResultTeam4: UILabel!
    
    @IBOutlet weak var lblSemiTeam1: UILabel!
    @IBOutlet weak var lblSemiTeam2: UILabel!
    @IBOutlet weak var lblSemiTeam3: UILabel!
    
    @IBOutlet weak var lblQualifySemiTeam1: UILabel!
    @IBOutlet weak var lblQualifySemiTeam2: UILabel!
    @IBOutlet weak var lblQualifySemiTeam3: UILabel!
    
    
    @IBOutlet weak var noDataView: NoDataView!
    
    var strGetAllTeams = ""
    var strCin = ""
    
    var teamIdArr = [Int]()
    var teamId = ""
    
    var GetAllTeamElementMain = [GetAllTeam]()
    var GetAllTeamObjMain = [GetAllTeamObj]()
    var GetSemiFinaListTeamObj = [FlagData]()
    
    var AddSemisDetailElementMain = [AddLeagueMatchDetailElement]()
    var AddSemisDetailObjMain = [AddLeagueMatchDetailObj]()
    
    var FlagsArr1 = [FlagData]()
    var FlagsArr2 = [FlagData]()
    var FlagsArr3 = [FlagData]()
    
    var strAddSemisTeamApi = ""
    
    var selectedIndex : Int!
    
    var isSelectSemis = false
    
    var initIndex1 = 0
    var initIndex2 = 0
    var initIndex3 = 0
  
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func xibSetup() {
        super.xibSetup()
        
        for i in 0...3{
            self.GetSemiFinaListTeamObj.append(FlagData(flag: "", teamName: "", teamId: 0, points:0))
            self.teamIdArr.append(0)
        }
        
        self.GetSemiFinaListTeamObj[0] = FlagData(flag: "", teamName: "INDIA", teamId: 1 , points:0)
        self.teamIdArr[0] = 1
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        strGetAllTeams = (initialData["baseApi"] as? String ?? "")+""+(initialData["team"] as? String ?? "")
        strAddSemisTeamApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["addPartySemiFinalMatchSummary"] as? String ?? "")
        
//        strGetAllTeams = "https://test2.goldmedalindia.in/api/GetTeam"
//        strAddSemisTeamApi = "https://test2.goldmedalindia.in/api/AddPartySemiFinalMatchSummary"
        
        FlagsArr1 = Utility.getFlags()
        FlagsArr2 = Utility.getFlags()
        FlagsArr3 = Utility.getFlags()
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        vwCarousel1.type = iCarouselType.coverFlow
        vwCarousel2.type = iCarouselType.coverFlow
        vwCarousel3.type = iCarouselType.coverFlow
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiGetAllTeams()
           //     self.noDataView.hideView(view: self.noDataView)
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
    }
    
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return FlagsArr1.count
    }
    
   
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView
    {
        print("selected view ---- -- - - -  -- ")
        var itemView: UIImageView
        var viewMain: UIView
        var label: UILabel
        
        if (view == nil)
        {
            
            viewMain = UIView(frame:CGRect(x:0, y:0, width:120, height:120))
            
            itemView = UIImageView(frame:CGRect(x:15, y:30, width:90, height:90))
            itemView.contentMode = .scaleAspectFit
            itemView.tag = 1
            
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = UIFont(name: "Roboto-Medium", size: 13)
            label.tag = 2
            
            viewMain.addSubview(itemView)
            viewMain.addSubview(label)
       
        }
        else
        {
            viewMain = view as! UIView
            //itemView = view as! UIImageView;
            itemView = viewMain.viewWithTag(1) as! UIImageView!
            label = viewMain.viewWithTag(2) as! UILabel!
        }
        
        if(carousel.tag == 1){
            itemView.image = UIImage(named: FlagsArr1[index].flag ?? "")
            label.text = (FlagsArr1[index].teamName ?? "")?.capitalized
        
        }else  if(carousel.tag == 2){
            itemView.image = UIImage(named: FlagsArr2[index].flag ?? "")
            label.text = (FlagsArr2[index].teamName ?? "")?.capitalized
           
        }else  if(carousel.tag == 3){
            itemView.image = UIImage(named: FlagsArr3[index].flag ?? "")
            label.text = (FlagsArr3[index].teamName ?? "")?.capitalized
        }
        
        
        return viewMain
    }
    
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        var currentIndex1 = 0
        var currentIndex2 = 0
        var currentIndex3 = 0
        
        if(carousel.tag == 1){
            currentIndex1 = carousel.currentItemIndex
            if(currentIndex1 == -1){
                currentIndex1 = 0
            }
            teamIdArr[1] = (self.FlagsArr1[currentIndex1].teamId ?? 0)!
            self.GetSemiFinaListTeamObj[1].flag = self.FlagsArr1[currentIndex1].flag
            self.GetSemiFinaListTeamObj[1].teamName = self.FlagsArr1[currentIndex1].teamName
            print("current index 1 - - - - - - ",currentIndex1)
        }else if(carousel.tag == 2){
            currentIndex2 = carousel.currentItemIndex
            if(currentIndex2 == -1){
                currentIndex2 = 0
            }
            teamIdArr[2] = (self.FlagsArr2[currentIndex2].teamId ?? 0)!
            self.GetSemiFinaListTeamObj[2].flag = self.FlagsArr2[currentIndex2].flag
            self.GetSemiFinaListTeamObj[2].teamName = self.FlagsArr2[currentIndex2].teamName
            print("current index 2 - - - - - - ",currentIndex2)
        }else if(carousel.tag == 3){
            currentIndex3 = carousel.currentItemIndex
            if(currentIndex3 == -1){
                currentIndex3 = 0
            }
            teamIdArr[3] = (self.FlagsArr3[currentIndex3].teamId ?? 0)!
            self.GetSemiFinaListTeamObj[3].flag = self.FlagsArr3[currentIndex3].flag
            self.GetSemiFinaListTeamObj[3].teamName = self.FlagsArr3[currentIndex3].teamName
            print("current index 3 - - - - - - ",currentIndex3)
        }
        
        print("ARR Team  - - - ",teamIdArr)
        
    }
    
    
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        switch (option) {
        case .spacing: return 1
        default: return value
        }
    }
    
    
    // - - - - - - - Logic for semi final with corresponding api's - - - - - - - - --  - -
    // - - - - - -  Api to show all teams for semis screen  - - - - - - - -
    func apiGetAllTeams(){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"fefef"]
        var count = 0
        
        DataManager.shared.makeAPICall(url: strGetAllTeams, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                
                do {
                    self.GetAllTeamElementMain = try JSONDecoder().decode([GetAllTeam].self, from: data!)
                    self.GetAllTeamObjMain = self.GetAllTeamElementMain[0].data
                    
                    for i in 1...(self.GetAllTeamObjMain.count - 1){
                        
                        if(self.GetAllTeamObjMain[i].issemifinal == 1){
                            count+=1
                            if(count < 4){
                                self.GetSemiFinaListTeamObj[count] = FlagData(flag: "", teamName: self.GetAllTeamObjMain[i].teamName, teamId: self.GetAllTeamObjMain[i].teamId , points: self.GetAllTeamObjMain[i].point)
                                
                                self.teamIdArr[count] = (self.GetSemiFinaListTeamObj[count].teamId ?? 0)!
                            }
                            print("MATCH - - - - - ",self.GetAllTeamObjMain[i].teamName)
                        }
                        else{
                            print("MATCH NOT - - - - - ",self.GetAllTeamObjMain[i].teamName)
                        }
                    }
                    
                    
                    print("count - - - - ",count)
                    
                    if(!(self.appDelegate.isSemiFinalOpen)){
                     //   self.noDataView.showView(view: self.noDataView, from: "NDA")
                        
                        self.btnSubmitSemis.isHidden = true

                        var alert = UIAlertView(title: "Invalid", message: "Please select league matches first", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()

                     //   return
                    }
                    
                    var SemiTeam1Id = (self.GetSemiFinaListTeamObj[1].teamId ?? 0)!
                    var SemiTeam2Id = (self.GetSemiFinaListTeamObj[2].teamId ?? 0)!
                    var SemiTeam3Id = (self.GetSemiFinaListTeamObj[3].teamId ?? 0)!
                    
                    print("ID - - - ",SemiTeam1Id,"- - - - -",SemiTeam2Id,"- - - - ",SemiTeam3Id)
                    
                    self.initIndex1 =  self.FlagsArr1.index(where: { $0.teamId == SemiTeam1Id }) ?? 1
                    self.initIndex2 =  self.FlagsArr2.index(where: { $0.teamId == SemiTeam2Id }) ?? 2
                    self.initIndex3 =  self.FlagsArr3.index(where: { $0.teamId == SemiTeam3Id }) ?? 3
                    
                    
                    print("INDEX - - - - - - ",self.initIndex1," - - - - - ",self.initIndex2,"--- - - ",self.initIndex3)
                    
                    
                    self.vwCarousel1 .reloadData()
                    self.vwCarousel2 .reloadData()
                    self.vwCarousel3 .reloadData()
                    
                    if(self.initIndex1 != -1){
                        self.vwCarousel1.scrollToItem(at: self.initIndex1, animated: true)
                    }
                    
                    if(self.initIndex2 != -1){
                        self.vwCarousel2.scrollToItem(at: self.initIndex2, animated: true)
                    }
                    
                    if(self.initIndex3 != -1){
                        self.vwCarousel3.scrollToItem(at: self.initIndex3, animated: true)
                    }
                    
                    
                    self.GetSemiFinaListTeamObj[1].flag = self.FlagsArr1[self.initIndex1].flag
                    self.GetSemiFinaListTeamObj[2].flag = self.FlagsArr2[self.initIndex2].flag
                    self.GetSemiFinaListTeamObj[3].flag = self.FlagsArr3[self.initIndex3].flag
                    
                    self.GetSemiFinaListTeamObj[1].teamName = self.FlagsArr1[self.initIndex1].teamName
                    self.GetSemiFinaListTeamObj[2].teamName = self.FlagsArr2[self.initIndex2].teamName
                    self.GetSemiFinaListTeamObj[3].teamName = self.FlagsArr3[self.initIndex3].teamName
                    
                    if(count == 3){
                        self.showModifySemis()
                    }else{
                        self.showSelectSemis()
                    }
                    
                    self.noDataView.hideView(view: self.noDataView)
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
               
                
            }
            
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            print(Error?.localizedDescription)
        }
        
    }
    
    
    // - - -  - - - - - - -  clicked submit for semis matches - - - -  - - - - -
    @IBAction func SubmitSemis(_ sender: UIButton) {
        print("ARR  - - - ",teamIdArr)
        
        var duplicateId = Array(Set(teamIdArr))
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                if(self.teamIdArr.contains(where: { $0 == 0 })){
                    var alert = UIAlertView(title: "Invalid", message: "Team Id is not Valid", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else if(duplicateId.count < self.teamIdArr.count){
                    var alert = UIAlertView(title: "Invalid", message: "Cannot have same team", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }else{
                    self.teamId = (self.teamIdArr.map{String($0)}).joined(separator: ",")
                    self.apiAddSemiFinalTeamsPrediction()
                }
                
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    // - - -  - - - - - - -  clicked modify for semis matches - - - -  - - - - -
    @IBAction func ModifySemis(_ sender: UIButton) {
        showSelectSemis()
    }
    
    
    // - - - - - -  Api to add semi final predicted teams  - - - - - - - -
    func apiAddSemiFinalTeamsPrediction(){
       ViewControllerUtils.sharedInstance.showLoader()
        
        teamId = (teamIdArr.map{String($0)}).joined(separator: ",")
        
        let json: [String: Any] = ["CIN":strCin,"TeamId":teamId,"ClientSecret":"fefef"]
        
        DataManager.shared.makeAPICall(url: strAddSemisTeamApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.AddSemisDetailElementMain = try JSONDecoder().decode([AddLeagueMatchDetailElement].self, from: data!)
                    self.AddSemisDetailObjMain = self.AddSemisDetailElementMain[0].data
                    
                    
                    let result = self.AddSemisDetailElementMain[0].result ?? false
                    
                    let message = self.AddSemisDetailObjMain[0].output ?? "-"
                    
                    if(result){
                        var alert = UIAlertView(title: "Success!!!", message: message, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.showModifySemis()
                    }
                    
                } catch let errorData {
                    
                    var alert = UIAlertView(title: "Failed!!!", message: "Unable to add data at this moment.Please try again later", delegate: nil, cancelButtonTitle: "OK")
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
    
    func showSelectSemis(){
        svSelectSemisMain.isHidden = false
        svModifySemisMain.isHidden = true
    }
    
    func showModifySemis(){
      
        imvModifyTeam2.image = UIImage(named: self.GetSemiFinaListTeamObj[1].flag ?? "")
        imvModifyTeam3.image = UIImage(named: self.GetSemiFinaListTeamObj[2].flag ?? "")
        imvModifyTeam4.image = UIImage(named: self.GetSemiFinaListTeamObj[3].flag ?? "")
        
        lblSemiTeam1.text = ((self.GetSemiFinaListTeamObj[1].teamName ?? "-")!).uppercased()
        lblSemiTeam2.text = ((self.GetSemiFinaListTeamObj[2].teamName ?? "-")!).uppercased()
        lblSemiTeam3.text = ((self.GetSemiFinaListTeamObj[3].teamName ?? "-")!).uppercased()
        
        lblQualifySemiTeam1.text = ((self.GetSemiFinaListTeamObj[1].teamName ?? "-")!).capitalized + " Qualify for Semi Final"
        lblQualifySemiTeam2.text = ((self.GetSemiFinaListTeamObj[2].teamName ?? "-")!).capitalized  + " Qualify for Semi Final"
        lblQualifySemiTeam3.text = ((self.GetSemiFinaListTeamObj[3].teamName ?? "-")!).capitalized + " Qualify for Semi Final"
        
        
        svSelectSemisMain.isHidden = true
        svModifySemisMain.isHidden = false
    }
    
}
