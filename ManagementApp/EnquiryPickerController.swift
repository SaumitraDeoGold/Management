//
//  EnquiryPickerController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/28/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class EnquiryPickerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerEnquiry: UIPickerView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var delegate: PopupDateDelegate?
    
    var enquiryMain = [enquiryElement]()
    var enquiryData = [EnquiryData]()
    var enquiryArray = [EnquiryData]()
    
    var strSlNo = ""
    var strEnquiry = ""
    var enquiryListApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        enquiryListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["subjectList"] as? String ?? "")
        
          if (Utility.isConnectedToNetwork()) {
            apiEnquiryData()
        }
        
        // Do any additional setup after loading the view.
        self.pickerEnquiry.dataSource = self;
        self.pickerEnquiry.delegate = self;
    }
    
    func apiEnquiryData(){

        guard UserDefaults.standard.value(forKey: "enquiryData") == nil else {
            self.enquiryArray = UserDefaults.standard.value(forKey: "enquiryData") as! [EnquiryData]
            pickerEnquiry.reloadAllComponents()
            return
        }
        
        let json: [String: Any] = ["Date":"02/17/2018"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: enquiryListApi)!
        
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
                    self.enquiryMain = try JSONDecoder().decode([enquiryElement].self, from: data)
                    
                    let firstElement = EnquiryData(slno: -1, subjectnm: "Select")
                    
                    self.enquiryArray.append(firstElement)
                    
                    self.enquiryData = self.enquiryMain[0].data
                    
                    for i in self.enquiryData
                    {
                        self.enquiryArray.append(i)
                    }
                    
                     //UserDefaults.standard.set(self.enquiryArray, forKey: "enquiryData")
                    DispatchQueue.main.async {
                        if(self.pickerEnquiry != nil)
                        { self.pickerEnquiry.reloadAllComponents()}
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
            if(strEnquiry == ""){
                strEnquiry =  enquiryArray[0].subjectnm ?? "-"
                strSlNo =  String(enquiryArray[0].slno ?? 0)
            }
            delegate?.updateEnquiry!(value: strEnquiry, slNo: strSlNo)
        }
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return enquiryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return enquiryArray[row].subjectnm
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strEnquiry = enquiryArray[row].subjectnm ?? "-"
        strSlNo = String(enquiryArray[row].slno ?? 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}