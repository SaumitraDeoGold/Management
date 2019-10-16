//
//  DivisionPicker.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/21/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class DivisionPicker: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var pickerDivision: UIPickerView!
    @IBOutlet weak var lblDivisionHeader: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var delegate: PopupDateDelegate?
    
    var divisionMain = [DivisionElement]()
    var divisionData = [DivisionData]()
    var divisionArray = [DivisionData]()
    
    var strDivision = ""
    var intSlNo = 0
    var divisionApi=""
  
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        divisionApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["divisionList"] as? String ?? "")
        
          if (Utility.isConnectedToNetwork()) {
            apiDivisionData()
        }

        // Do any additional setup after loading the view.
        self.pickerDivision.dataSource = self;
        self.pickerDivision.delegate = self;
    }
    
    func apiDivisionData(){
        
            let json: [String: Any] = ["Date":"02/17/2018"]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            // create post request
            let url = URL(string: divisionApi)!
            
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
                        self.divisionMain = try JSONDecoder().decode([DivisionElement].self, from: data)
                        
                        let firstElement = DivisionData(slno: 0, divisionnm: "ALL")
                        
                        self.divisionArray.append(firstElement)
                
                        self.divisionData = self.divisionMain[0].data
                        
                        for i in self.divisionData
                        {
                            self.divisionArray.append(i)
                        }
                        
                        
                        
                        DispatchQueue.main.async {
                            if(self.pickerDivision != nil)
                            { self.pickerDivision.reloadAllComponents()}
                        }
                        
                    }catch {
                        print(error)
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
            if(strDivision == ""){
                strDivision =  divisionArray[0].divisionnm ?? "-"
                intSlNo = divisionArray[0].slno ?? 0
            }
            delegate?.updatePositionValue!(value: strDivision, position: intSlNo, from: "DIVISION")
        }
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return divisionArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return divisionArray[row].divisionnm
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strDivision = divisionArray[row].divisionnm ?? "-"
        intSlNo = divisionArray[row].slno ?? 0
    }
    
}
