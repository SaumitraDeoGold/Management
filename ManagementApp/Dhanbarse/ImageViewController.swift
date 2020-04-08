//
//  ImageViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 06/04/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var lblPickerHeader: UILabel!
    
    var img = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImg()
    }
    
    //LoadImage...
    func loadImg(){
        if let url = URL(string: img) {
            do {
                let data: Data = try Data(contentsOf: url)
                coverImageView.image = UIImage(data: data)
            } catch {
                print("Error Loading Img \(error)")
            }
        }
    }
    
    @IBAction func cancel_clicked(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
