//
//  TODController.swift
//  GStar
//
//  Created by Goldmedal on 18/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit





class TODSpreadsheetCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    
}


struct DecorationViewNames {
    static let topLeft = "SpreadsheetTopLeftDecorationView"
    static let topLeftExecutive = "SpreadsheetTopLeftExecutiveDecorationView"
    static let topRight = "SpreadsheetTopRightDecorationView"
    static let topRightAdjustment = "SpreadsheetTopRightAdjustmentDecorationView"
    static let bottomLeft = "SpreadsheetBottomLeftDecorationView"
    static let bottomRight = "SpreadsheetBottomRightDecorationView"
}

class TODController: BaseViewController {
    
    let defaultCellIdentifier = "DefaultCellIdentifier"
    let defaultSupplementaryViewIdentifier = "DefaultSupplementaryViewIdentifier"
    
    
    
    @IBOutlet weak var collectionView: IntrinsicCollectionView!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var cinViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cinView: CINView!
    @IBOutlet weak var lblHeader: UILabel!
    
    var TodSalesElementMain = [TodSalesElement]()
    //var AgingReportDataMain = [ExecutiveAgingReportData]()
    var TodSalesArray = [TodSalesData]()
    
    
    var twoDimensionalTodSalesArray = [[String?]]()
    
    
    
    var TodGroupsElementMain = [TodGroupsElement]()
    
    var TodGroupsArray = [TodGroupsData]()
    
    var divisionName = [DivisionName]()
    var divisionNameObj = [DivisionNameObj]()
    
    //var AgingurlsArray = [Agingurls]()
    
    
    //  var fromIndex = 0
    // let batchSize = 20
    var exid = 0
    var strCin = ""
    var strGroupId = "7"
    var strTodAccepted = "1"
    //  var ismore = true
    
    var todSalesApi = ""
    var todGrpsApi = ""
    var layout : SpreadsheetLayout!
    
    
    let topHeaderLabels = ["","Monthly","","","Quarterly",""]
    
    let topHeaderDescLabels = ["Target","Sales","Short Fall","Target","Sales","Short Fall"]
    
    
    
   var viewAs = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        
        //addSearchMenuButton()
        addBackButton()
        
        cinView.delegate = self
        cinViewHeight.constant = 0
        
        
        
        lblHeader.text = "Wiring Devices"
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        exid = loginData["slno"] as? Int ?? 0
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        todSalesApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["todSalesExecutive"] as? String ?? "")
        
        todGrpsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["todGroupSalesExecutive"] as? String ?? "")
        
         viewAs =  UserDefaults.standard.value(forKey: "viewAs") as? Bool ?? true
        
        
        setupCollectionView()
        
        
        apiTodDivisions()
        apiTodSales(partySelected: false)
    }
    
    
    func setupCollectionView(){
        
        //DecorationView Nibs
        let topLeftDecorationViewNib = UINib(nibName: DecorationViewNames.topLeft, bundle: nil)
        
        //SupplementaryView Nibs
        let topSupplementaryViewNib = UINib(nibName: "TODSpreadsheetTopColumnView", bundle: nil)
        let leftSupplementaryViewNib = UINib(nibName: "TODSpreadsheetLeftRowView", bundle: nil)
        
        
        //Setup Layout
        layout = SpreadsheetLayout(delegate: self,
                                   topLeftDecorationViewType: .asNib(topLeftDecorationViewNib),
                                   topRightDecorationViewType: nil,
                                   bottomLeftDecorationViewType: nil,
                                   bottomRightDecorationViewType: nil)
        
        //Default is true, set false here if you do not want some of these sides to remain sticky
        layout.stickyLeftRowHeader = true
        layout.stickyRightRowHeader = false
        layout.stickyTopColumnHeader = true
        layout.stickyBottomColumnFooter = true
        
        self.collectionView.collectionViewLayout = layout
        
        //Register Supplementary-View nibs for the given ViewKindTypes
        self.collectionView.register(leftSupplementaryViewNib, forSupplementaryViewOfKind: SpreadsheetLayout.ViewKindType.leftRowHeadline.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier)
        
        self.collectionView.register(topSupplementaryViewNib, forSupplementaryViewOfKind: SpreadsheetLayout.ViewKindType.topColumnHeader.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier)
        
    }
    
    
    
    @IBAction func btnFilterTapped(_ sender: UIButton) {
        
        
        let sb = UIStoryboard(name: "TodGroupFilterPopup", bundle: nil)
        let popup = sb.instantiateInitialViewController() as? TodGroupFilterPopupController
        
        popup?.delegate = self
        popup?.TodGroupsArray = self.TodGroupsArray
        popup?.strGroupId = self.strGroupId
        popup?.strTodAccepted = self.strTodAccepted
        self.present(popup!, animated: true)
        
        
    }
    
    
    func showParty(value: String, cin: String) {
        
        
        self.title = value
        strCin = cin
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.filterSearch(partySelected: true)
                self.cinView.lblCIN.text = cin
                self.cinViewHeight.constant = 50
                self.noDataView.hideView(view: self.noDataView)
            }
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
    }
    
    func popViewController() {
        
    }
    
    func refreshApi() {
           
           self.title = "TOD"
           strCin = ""
           
           if (Utility.isConnectedToNetwork()) {
               print("Internet connection available")
               OperationQueue.main.addOperation {
                   self.filterSearch(partySelected: false)
                   self.cinViewHeight.constant = 0
                   //self.noDataView.hideView(view: self.noDataView)
               }
           }
           else {
               print("No internet connection available")
               var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
               alert.show()
               self.noDataView.showView(view: self.noDataView, from: "NET")
           }
           
           
       }
    
    
    //search filter
    func filterSearch(partySelected: Bool){
        // fromIndex = 0
        self.TodSalesArray.removeAll()
        self.twoDimensionalTodSalesArray.removeAll()
        
        
        apiTodSales(partySelected: partySelected)
    }
    
    
    func apiTodSales(partySelected: Bool){
        //   ViewControllerUtils.sharedInstance.showLoader()
        let hierarchy = Utility.setupHierarchy(strCin: strCin, viewAs: viewAs)
        //  if(fromIndex == 0){
        self.noDataView.showView(view: self.noDataView, from: "LOADER")
        
        self.collectionView.showNoData = true
        let json: [String: Any] =
            ["CIN":strCin,"ExId":"16","Hierarchy":hierarchy,"ClientSecret":"ClientSecret"
                ,"groupId":strGroupId,"isTODAccepted":0]
        
        
        
        DataManager.shared.makeAPICall(url: "https://api.goldmedalindia.in/api/getTODSalesExecutive", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("agingReportApi - - - ","https://api.goldmedalindia.in/api/getTODSalesExecutive","------",json)
            
            
            DispatchQueue.main.async {
                do {
                    self.TodSalesElementMain = try JSONDecoder().decode([TodSalesElement].self, from: data!)
                    
                    let result = (self.TodSalesElementMain[0].result ?? false)!
                    
                    if(result){
                        
                        self.TodSalesArray = self.TodSalesElementMain[0].data ?? []
                        
                        
                        
                        
                        var finalArray = [[String]]()
                        for i in 0 ..< self.TodSalesArray.count {
                            var subArray = [String]()
                            
                            let monthlyTarget:String = self.TodSalesArray[i].curmnthtarget!
                            let monthlySales:String = self.TodSalesArray[i].curmnthsale!
                            let monthlyShortfall:String = self.TodSalesArray[i].curmnthshortamt!
                            
                            
                            let quarterlyTarget:String = self.TodSalesArray[i].qtytarget!
                            let quarterlySales:String = self.TodSalesArray[i].qtysale!
                            let quarterlyShortfall:String = self.TodSalesArray[i].qtyshortamt!
                            
                            
                            
                            
                            subArray.append(monthlyTarget)
                            subArray.append(monthlySales)
                            subArray.append(monthlyShortfall)
                            
                            
                            subArray.append(quarterlyTarget)
                            subArray.append(quarterlySales)
                            subArray.append(quarterlyShortfall)
                            
                            
                            finalArray.append(subArray)
                        }
                        
                        self.twoDimensionalTodSalesArray.append(contentsOf:finalArray)
                        
                        
                        
                        
                        //    self.AgingurlsArray = self.AgingReportDataMain[0].agingurls ?? []
                        
                        
                        if self.twoDimensionalTodSalesArray.count > 0, partySelected {
                            self.layout.resetLayoutCache()
                            self.collectionView.reloadDataAndSpreadsheetLayout()
                            self.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
                        }
                    }else{
                        Utility.showAlertMsg(_title: "Error", _message: self.TodSalesElementMain[0].message ?? "Something doesn't seem right",_cancelButtonTitle: "OK")
                    }
                    
                    
                    
                    // ViewControllerUtils.sharedInstance.removeLoader()
                } catch let errorData {
                    print(errorData.localizedDescription)
                    //  ViewControllerUtils.sharedInstance.removeLoader()
                    // self.noDataView.showView(view: self.noDataView, from: "ERR")
                    //  self.collectionView.showNoData = true
                }
                
                if(self.collectionView != nil)
                {
                    //On Layout:
                    self.layout.resetLayoutCache()
                    //Helper Method for collection view
                    self.collectionView.reloadDataAndSpreadsheetLayout()
                }
                
                if(self.twoDimensionalTodSalesArray.count > 0)
                {
                    self.noDataView.hideView(view: self.noDataView)
                    self.collectionView.showNoData = false
                }
                else
                {
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                    self.collectionView.showNoData = true
                }
                
            }
        }) { (Error) in
            
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
            self.collectionView.showNoData = true
            //   ViewControllerUtils.sharedInstance.removeLoader()
            
        }
    }
    
//    func apiDivisionNames(){
//
//        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN") as! String,"Category":UserDefaults.standard.value(forKey: "userCategory") as! String,"ClientSecret":"ClientSecret"]
//        print("Division : \(json)")
//        let manager =  DataManager.shared
//
//        manager.makeAPICall(url: "https://api.goldmedalindia.in/api/GetDivisionListManagement", params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            do {
//                self.divisionName = try JSONDecoder().decode([DivisionName].self, from: data!)
//                self.divisionNameObj = self.divisionName[0].data
//
//                ViewControllerUtils.sharedInstance.removeLoader()
//            } catch let errorData {
//                print(errorData.localizedDescription)
//                ViewControllerUtils.sharedInstance.removeLoader()
//            }
//        }) { (Error) in
//            print(Error?.localizedDescription as Any)
//            ViewControllerUtils.sharedInstance.removeLoader()
//        }
//
//    }
    
    func apiTodDivisions(){
        
        let json: [String: Any] = ["ClientSecret":"1170004","ExId":
            "16"]
        
        print("TodDivisions - - - -", json)
        
        DataManager.shared.makeAPICall(url: "https://api.goldmedalindia.in/api/getTODGroupSalesExecutive", params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("todGrpsApi - - - - - ","http://api.goldmedalindia.in/api/getTODGroupSalesExecutive","-----",json)
            
            DispatchQueue.main.async {
                do {
                    self.TodGroupsElementMain = try JSONDecoder().decode([TodGroupsElement].self, from: data!)
                    self.TodGroupsArray = self.TodGroupsElementMain[0].data ?? []
                    
                    if(self.TodGroupsElementMain[0].result ?? false){
                        
                        
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
            }
            
        }) { (Error) in
            print(Error?.localizedDescription)
        }
    }
}



extension TODController : TodFilterDelegate{
    func updateTod(strGroupTitle: String, strGroupId: String, strTodAccepted: String) {
        
        
        self.lblHeader.text = strGroupTitle
        
        self.strGroupId = strGroupId
        self.strTodAccepted = strTodAccepted
        
        
        //Refresh new data set
        apiTodSales(partySelected: true)
    }
    
    
    
    
}

extension TODController: UICollectionViewDataSource,YourHeaderViewDelegate {
    
    
    
    
    func showPartyDetail(index: Int) {
        
        let partyName =  self.TodSalesArray[index].dealernm ?? ""
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Sales", bundle: nil)
        let vcTodAgreement = storyBoard.instantiateViewController(withIdentifier: "TodAgreement") as! TodAgreementController
        vcTodAgreement.strCin = self.TodSalesArray[index].cin ?? ""
        vcTodAgreement.selectedGrpId = strGroupId
        vcTodAgreement.strPartyName = partyName
        self.navigationController!.pushViewController(vcTodAgreement, animated: true)
        
        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        
        
        return self.twoDimensionalTodSalesArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        return self.twoDimensionalTodSalesArray[section].count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.defaultCellIdentifier, for: indexPath) as? DefaultCollectionViewCell else { fatalError("Invalid cell dequeued") }
        
        
        if let amount = self.twoDimensionalTodSalesArray[indexPath.section][indexPath.item] {
            cell.infoLabel.text = Utility.formatRupee(amount: Double(amount)!)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let viewKind = SpreadsheetLayout.ViewKindType(rawValue: kind) else { fatalError("View Kind not available for string: \(kind)") }
        
        
        
        
        switch viewKind {
        case .leftRowHeadline:
            
            let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: viewKind.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier, for: indexPath) as! SpreadsheetCollectionReusableView
            
            supplementaryView.btnPartyText.tag = indexPath.section
            supplementaryView.headerDelegate = self
            
            
            if indexPath.section >= 0 && indexPath.section < self.TodSalesArray.count {
                
                
                let yourAttributes: [NSAttributedString.Key: Any] = [
                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                    NSAttributedString.Key.foregroundColor: UIColor.init(named: "ColorRed")!]
                
                
                //Underline effect here
                let attributeString = NSMutableAttributedString(string: (self.TodSalesArray[indexPath.section].cin ?? "") + "-" + (self.TodSalesArray[indexPath.section].dealernm ?? ""),
                                                                attributes: yourAttributes)
                supplementaryView.btnPartyText.setAttributedTitle(attributeString, for: .normal)
                
                return supplementaryView
            }
            
            
            
        case .topColumnHeader:
            let topColumnView = collectionView.dequeueReusableSupplementaryView(ofKind: viewKind.rawValue, withReuseIdentifier: self.defaultSupplementaryViewIdentifier, for: indexPath) as! TODSpreadsheetCollectionReusableView
            
            
            topColumnView.lblHeader.text = self.topHeaderLabels[indexPath.item]
            
            topColumnView.lblDescription.text = self.topHeaderDescLabels[indexPath.item]
            return topColumnView
            
            
            
        default:
            break
        }
        
        return UICollectionReusableView()
    }
    
}

//MARK: - Spreadsheet Layout Delegate


extension TODController: UICollectionViewDelegate{
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("index: \(indexPath.item) section : \(indexPath.section)")
    }
}


extension TODController: SpreadsheetLayoutDelegate {
    func spreadsheet(layout: SpreadsheetLayout, heightForRowsInSection section: Int) -> CGFloat {
        return 50
    }
    
    func widthsOfSideRowsInSpreadsheet(layout: SpreadsheetLayout) -> (left: CGFloat?, right: CGFloat?) {
        return (150, nil)
    }
    
    func spreadsheet(layout: SpreadsheetLayout, widthForColumnAtIndex index: Int) -> CGFloat {
        
        return 100
    }
    
    func heightsOfHeaderAndFooterColumnsInSpreadsheet(layout: SpreadsheetLayout) -> (headerHeight: CGFloat?, footerHeight: CGFloat?) {
        return (70, nil)
    }
}
