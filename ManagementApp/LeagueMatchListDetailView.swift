//
//  LeagueMatchListDetailView.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/30/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

@IBDesignable class LeagueMatchListDetailView: BaseCustomView,LeagueMatchDelegate {
    
    @IBOutlet weak var tableViewDetail: IntrinsicTableView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var noDataView: NoDataView!
    
    var matchIdArr = [Int]()
    var teamIdArr = [Int]()
    
    var flagArr = [FlagData]()
    
    var team1FlagArr = [String]()
    var team2FlagArr = [String]()
    
    var matchId = ""
    var teamId = ""
    
    var strCin = ""
    var strWorldCupLeagueDetailsApi = ""
    var strAddMatchSummaryApi = ""
    
    var LeagueMatchDetailElementMain = [LeagueMatchDetailElement]()
    var LeagueMatchDetailArr = [LeagueMatchDetailObj]()
    
    var AddLeagueMatchDetailElementMain = [AddLeagueMatchDetailElement]()
    var AddLeagueMatchDetailObjMain = [AddLeagueMatchDetailObj]()
    
    let cellIdentifier = "\(LeagueMatchViewCell.self)"
    
    var isSemiFinal = false
    var checkSemiFinal = true

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var count = 0
    
    
    override func xibSetup() {
        super.xibSetup()
        
        
        // Do any additional setup after loading the view.
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        strWorldCupLeagueDetailsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["matchSummary"] as? String ?? "")
        strAddMatchSummaryApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["addPartyMatchSummary"] as? String ?? "")
        
//        strWorldCupLeagueDetailsApi = "https://test2.goldmedalindia.in/api/GetMatchSummary"
//        strAddMatchSummaryApi = "https://test2.goldmedalindia.in/api/AddPartyMatchSummary"
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        flagArr =  Utility.getAllFlags()
        
        tableViewDetail.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        //        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiWorldCupdetails()
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
    }
    
    
    // - - - - - -  Api to show league match details  - - - - - - - -
    func apiWorldCupdetails(){
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"fefef"]
        
        DataManager.shared.makeAPICall(url: strWorldCupLeagueDetailsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.LeagueMatchDetailElementMain = try JSONDecoder().decode([LeagueMatchDetailElement].self, from: data!)
                    self.LeagueMatchDetailArr = self.LeagueMatchDetailElementMain[0].data
                    
                    print("league data - - - -",self.LeagueMatchDetailArr.count)
                    
                    self.team1FlagArr = Array(repeating:String(), count:self.LeagueMatchDetailArr.count)
                    self.team2FlagArr = Array(repeating:String(), count:self.LeagueMatchDetailArr.count)
                    
                    for i in 0...self.LeagueMatchDetailArr.count - 1{
                        if let index1 = self.flagArr.index(where: { $0.teamId == self.LeagueMatchDetailArr[i].team1id }) {
                            self.team1FlagArr[i] = self.flagArr[index1].flag ?? ""
                        }
                        
                        if let index2 = self.flagArr.index(where: { $0.teamId == self.LeagueMatchDetailArr[i].team2id }) {
                            self.team2FlagArr[i] = self.flagArr[index2].flag ?? ""
                        }
                        
                    }
                  

                    if(self.LeagueMatchDetailArr.contains(where: { $0.selectedteam == 0 })){
                        print("check semi 1 - - - -")
                        self.checkSemiFinal = false
                        self.appDelegate.isSemiFinalOpen = false
                    }else{
                        if(self.checkSemiFinal){
                             print("check semi 2 - - - -")
                            self.appDelegate.isSemiFinalOpen = true
                            self.btnSubmit.setTitle("Modify", for: .normal)
                        }
                    }
                    
                    
                    print("team1 arr - - - -",self.team1FlagArr)
                    print("team2 arr - - - -",self.team2FlagArr)
                    
                    self.matchIdArr = Array(repeating:Int(), count:self.LeagueMatchDetailArr.count)
                    self.teamIdArr = Array(repeating:Int(), count:self.LeagueMatchDetailArr.count)
                    
                    if(self.tableViewDetail != nil)
                    { self.tableViewDetail.reloadData() }
                    
                    if(self.team1FlagArr.count > 0){
                        //self.noDataView.hideView(view: self.noDataView)
                      
                    }else{
                        self.noDataView.showView(view: self.noDataView, from: "NDA")
                      
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                
                }
                
            }
            
            
        }) { (Error) in
            self.noDataView.showView(view: self.noDataView, from: "ERR")
       
        }
        
    }
    
    
    
    
    // - - - - -  Delegates method to show selected team - - - - - - - - -
    func btnSelectTeam1(cell: LeagueMatchViewCell) {
        print("btn 1")
        if(self.btnSubmit.currentTitle?.elementsEqual("Modify") ?? false){
            var alert = UIAlertView(title: "Modify", message: "Please make sure you click on Modify first", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
          
            return
        }else{
            let indexPath = self.tableViewDetail.indexPath(for: cell)
            
            if(cell.btnTeam1.backgroundColor == UIColor.green || LeagueMatchDetailArr[(indexPath?.row)!].winnerlock ?? false){
                return
            }
            
            if(cell.btnTeam1.backgroundColor != UIColor.green)
            {
                print("team 1 - - - -",LeagueMatchDetailArr[(indexPath?.row)!].team1)
                
                matchIdArr[(indexPath?.row)!] = LeagueMatchDetailArr[(indexPath?.row)!].matchsummaryid ?? 0
                teamIdArr[(indexPath?.row)!] = LeagueMatchDetailArr[(indexPath?.row)!].team1id ?? 0
                
                cell.btnTeam1.isSelected = true
                cell.btnTeam2.isSelected = false
                
                LeagueMatchDetailArr[(indexPath?.row)!].team1selected = true
                LeagueMatchDetailArr[(indexPath?.row)!].team2selected = false
            }
            
        }
        
        
    }
    
    func btnSelectTeam2(cell: LeagueMatchViewCell) {
        print("btn 2")
        
        if(self.btnSubmit.currentTitle?.elementsEqual("Modify") ?? false){
            var alert = UIAlertView(title: "Modify", message: "Please make sure you click on Modify first", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }else{
        
        let indexPath = self.tableViewDetail.indexPath(for: cell)
        
        
        if(cell.btnTeam2.backgroundColor == UIColor.green || LeagueMatchDetailArr[(indexPath?.row)!].winnerlock ?? false){
            return
        }
        
        if(cell.btnTeam2.backgroundColor != UIColor.green)
        {
            print("team 2 - - - -",LeagueMatchDetailArr[(indexPath?.row)!].team2)
            
            matchIdArr[(indexPath?.row)!] = LeagueMatchDetailArr[(indexPath?.row)!].matchsummaryid ?? 0
            teamIdArr[(indexPath?.row)!] = LeagueMatchDetailArr[(indexPath?.row)!].team2id ?? 0
            
            cell.btnTeam2.isSelected = true
            cell.btnTeam1.isSelected = false
            
            LeagueMatchDetailArr[(indexPath?.row)!].team1selected = false
            LeagueMatchDetailArr[(indexPath?.row)!].team2selected = true
        }
        
      }
    }
    
    
    // - - -  - - - - - - -  clicked submit for league matches - - - -  - - - - -
    @IBAction func onClick(_ sender: UIButton) {
        if(count == 0){
            self.tableViewDetail.scrollToRow(at: IndexPath(row: (self.LeagueMatchDetailArr.count - 1), section: 0), at: .top, animated: true)
            
             count = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.submitResult()
            }
            
           
        }else{
            self.submitResult()
        }
     
    }
    
    func submitResult(){
        if(self.btnSubmit.currentTitle?.elementsEqual("Modify") ?? false){
            var alert = UIAlertView(title: "Success!!!", message: "You can make League Team changes now", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            self.tableViewDetail.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.btnSubmit.setTitle("Submit", for: .normal)
        }else{
            
            print("ARR  - - - ",self.matchIdArr,"- - - ",self.teamIdArr)
            self.matchId = (self.matchIdArr.map{String($0)}).joined(separator: ",")
            self.teamId = (self.teamIdArr.map{String($0)}).joined(separator: ",")
            
            if (Utility.isConnectedToNetwork()) {
                print("Internet connection available")
                OperationQueue.main.addOperation {
                    var indexOfMatchId = -1
                    
                    indexOfMatchId = self.matchIdArr.index{$0 == 0} ?? -1
                    
                    print("Index - - - ",indexOfMatchId)
                    
                    if(indexOfMatchId != -1){
                        
                        self.tableViewDetail.scrollToRow(at: IndexPath(row: ((self.LeagueMatchDetailArr[indexOfMatchId].matchsummaryid ?? 1) - 1), section: 0), at: .top, animated: true)
                        
                        
                        var alert = UIAlertView(title: "Invalid", message:"Please Select Match \(String(self.LeagueMatchDetailArr[indexOfMatchId].matchsummaryid ?? 0)) and also ensure all other matches are selected.", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    else{
                        self.apiAddLeagueMatchesPrediction()
                    }
                    
                }
            }
            else{
                print("No internet connection available")
                
                var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
            }
        }
    }
    
    
    
    // - - - - - -  Api to show league match details  - - - - - - - -
    func apiAddLeagueMatchesPrediction(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        
        print("ID - - -",matchId," -- - - ",teamId)
        
        let json: [String: Any] = ["CIN":strCin,"MatchSummaryId":matchId,"TeamId":teamId,"ClientSecret":"fefef"]
        
        
        
        DataManager.shared.makeAPICall(url: strAddMatchSummaryApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.AddLeagueMatchDetailElementMain = try JSONDecoder().decode([AddLeagueMatchDetailElement].self, from: data!)
                    self.AddLeagueMatchDetailObjMain = self.AddLeagueMatchDetailElementMain[0].data
                    
                    let result = self.AddLeagueMatchDetailElementMain[0].result ?? false
                    
                    let message = self.AddLeagueMatchDetailObjMain[0].output ?? "-"
                    
                    if(result){
                        var alert = UIAlertView(title: "Success!!!", message: message, delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                        
                        self.tableViewDetail.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        
                        self.appDelegate.isSemiFinalOpen = true
                        self.btnSubmit.setTitle("Modify", for: .normal)
                        
                    }
                    
                } catch let errorData {
                    
                    var alert = UIAlertView(title: "Failed!!!", message: "Unable to add data at this moment.Please try again later", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    print(errorData.localizedDescription)
                }
                
                if(self.tableViewDetail != nil)
                {
                    self.tableViewDetail.reloadData()
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
    
    
}


extension LeagueMatchListDetailView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return LeagueMatchDetailArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LeagueMatchViewCell
        
        var team1percent = Float(LeagueMatchDetailArr[indexPath.row].team1per ?? 0)/100
        
        cell.lblMatchNo.text = "Match "+String(LeagueMatchDetailArr[indexPath.row].matchsummaryid ?? 0)
        
        cell.lblTeamName1.text = LeagueMatchDetailArr[indexPath.row].team1 ?? "-"
        cell.lblTeamName2.text = LeagueMatchDetailArr[indexPath.row].team2 ?? "-"
        
        cell.imvTeam1Flag.image = UIImage(named:team1FlagArr[indexPath.row] ?? "")
        cell.imvTeam2Flag.image = UIImage(named: team2FlagArr[indexPath.row] ?? "")
       
        var dateTime = (LeagueMatchDetailArr[indexPath.row].matchDate ?? "-") + " " + (LeagueMatchDetailArr[indexPath.row].matchTime ?? "-")
        
        print("Date Time - - - - -",dateTime)
      
        cell.lblVenue.text = (LeagueMatchDetailArr[indexPath.row].venue ?? "-") + " , " + Utility.formattedDateTimeWorldCup(dateString: dateTime, withFormat:"MMM d yyyy , h:mm a")!
        cell.lblTeam1Point.text = String(LeagueMatchDetailArr[indexPath.row].team1point ?? 0) + "%"
        cell.lblTeam2Point.text = String(LeagueMatchDetailArr[indexPath.row].team2point ?? 0) + "%"
        cell.progressView.setProgress(team1percent, animated: false)
        cell.lblTeam1Percent.text = String(LeagueMatchDetailArr[indexPath.row].team1per ?? 0) + "%"
        cell.lblTeam2Percent.text = String(LeagueMatchDetailArr[indexPath.row].team2per ?? 0) + "%"
       
        
        cell.btnTeam2.isSelected = false
        cell.btnTeam1.isSelected = false
        
        cell.btnTeam1.tag = LeagueMatchDetailArr[indexPath.row].team1id ?? 0
        cell.btnTeam2.tag = LeagueMatchDetailArr[indexPath.row].team2id ?? 0
        
        
        if(((LeagueMatchDetailArr[indexPath.row].result ?? "").isEmpty)){
            cell.lblWinLosePercent.isHidden = true
            cell.lblWinLoseTeam.isHidden = true
        }else{
            cell.lblWinLosePercent.isHidden = false
            cell.lblWinLoseTeam.isHidden = false
            
            if(LeagueMatchDetailArr[indexPath.row].prediction ?? false){
                if(cell.btnTeam1.isSelected){
                    cell.lblWinLosePercent.text = String(LeagueMatchDetailArr[indexPath.row].team1point ?? 0) + "%"
                }
                
                if(cell.btnTeam2.isSelected){
                    cell.lblWinLosePercent.text = String(LeagueMatchDetailArr[indexPath.row].team2point ?? 0) + "%"
                }
                
                cell.lblWinLosePercent.textColor = UIColor.green
            }else{
                cell.lblWinLosePercent.text = "You Lost: 0.0%"
                cell.lblWinLosePercent.textColor = UIColor.red
            }
        }
         cell.lblWinLoseTeam.text = LeagueMatchDetailArr[indexPath.row].result
    
      
        if(LeagueMatchDetailArr[indexPath.row].winnerlock ?? false){
            var winnerId = 1//LeagueMatchDetailArr[indexPath.row].winnerlockteamid
            
            if(cell.btnTeam1.tag == winnerId){
                cell.btnTeam1.isSelected = true
                cell.btnTeam2.isSelected = false
                
                matchIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].matchsummaryid ?? 0
                teamIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].team1id ?? 0
                
            }else{
                cell.btnTeam2.isSelected = true
                cell.btnTeam1.isSelected = false
                
                matchIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].matchsummaryid ?? 0
                teamIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].team2id ?? 0
            }
            
        }else{
            if(LeagueMatchDetailArr[indexPath.row].team1selected ?? false){
                matchIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].matchsummaryid ?? 0
                teamIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].team1id ?? 0
                
                cell.btnTeam1.isSelected = true
                cell.btnTeam2.isSelected = false
                
                LeagueMatchDetailArr[indexPath.row].team1selected = true
                LeagueMatchDetailArr[indexPath.row].team2selected = false
            }
            
            if(LeagueMatchDetailArr[indexPath.row].team2selected ?? false){
                matchIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].matchsummaryid ?? 0
                teamIdArr[indexPath.row] = LeagueMatchDetailArr[indexPath.row].team2id ?? 0
                
                cell.btnTeam2.isSelected = true
                cell.btnTeam1.isSelected = false
                
                LeagueMatchDetailArr[indexPath.row].team1selected = false
                LeagueMatchDetailArr[indexPath.row].team2selected = true
            }
          
            
        }
        
        cell.delegate = self
        
        return cell
    }
}

extension LeagueMatchListDetailView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
}
