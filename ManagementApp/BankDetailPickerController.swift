//
//  BankDetailPickerController.swift
//  DealorsApp
//
//  Created by Goldmedal on 2/26/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class BankDetailPickerController: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerBankName: UIPickerView!
    @IBOutlet weak var lblBankHeader: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var delegate: PopupDateDelegate?
    
    var BankNameElement = [BankNameDetailElement]()
    var BankNameArray = [BankNameDetailArray]()
    
    var strBankName = ""
    var strBankUtrn = ""
    var strCin = ""
    var strBankMaxAmount = ""
    var cinReceived = ""
    var bankListApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        cinReceived = appDelegate.sendCin
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
      //  bankListApi = "https://api.goldmedalindia.in/api/GetDealerBankDetails"
        bankListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["dealerBankDetails"] as? String ?? "")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        if (Utility.isConnectedToNetwork()) {
            apiBankListData()
        }
        
        // Do any additional setup after loading the view.
        self.pickerBankName.dataSource = self;
        self.pickerBankName.delegate = self;
    }
    
    func apiBankListData(){
        
        let json: [String: Any] = ["CIN":cinReceived,"ClientSecret":"ClientSecret"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: bankListApi)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    self.BankNameElement = try JSONDecoder().decode([BankNameDetailElement].self, from: data)
                    
                    let firstElement = BankNameDetailArray(bankname:"SELECT", utrn:"", amount:"0")
                    
                    self.BankNameArray.append(firstElement)
                    self.BankNameArray.append(contentsOf: self.BankNameElement[0].data)
                    
                    DispatchQueue.main.async {
                        if(self.pickerBankName != nil)
                        { self.pickerBankName.reloadAllComponents()}
                    }
                }catch {
                    print(error)
                }
                
                if(self.BankNameArray.count == 0){
                    var alert = UIAlertView(title: "No Data Available", message: "No Data Available", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.dismiss(animated: true)
                }
            }
        }
        
        task.resume()
        
    }
    
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func ok_clicked(_ sender: UIButton) {
        if (Utility.isConnectedToNetwork()) {
            if(strBankName.elementsEqual("")){
               
            }else{
                delegate?.updateBankList!(value: strBankName, utrn: strBankUtrn, amount: strBankMaxAmount)
            }
          
        }
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BankNameArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return BankNameArray[row].bankname
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strBankName = BankNameArray[row].bankname ?? "-"
        strBankUtrn = BankNameArray[row].utrn ?? "-"
        strBankMaxAmount = BankNameArray[row].amount ?? "0"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
