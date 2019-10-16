//
//  LeagueMatchViewCell.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/30/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

protocol LeagueMatchDelegate: AnyObject {
    func btnSelectTeam1(cell: LeagueMatchViewCell)
    func btnSelectTeam2(cell: LeagueMatchViewCell)
}


class LeagueMatchViewCell: UITableViewCell {

        @IBOutlet weak var progressView: UIProgressView!
        @IBOutlet weak var btnTeam1: UIButton!
        @IBOutlet weak var btnTeam2: UIButton!
        
        @IBOutlet weak var lblTeamName1: UILabel!
        @IBOutlet weak var lblTeamName2: UILabel!
        
        @IBOutlet weak var imvTeam1Flag: UIImageView!
        @IBOutlet weak var imvTeam2Flag: UIImageView!
        
        @IBOutlet weak var lblTeam1Point: UILabel!
        @IBOutlet weak var lblTeam2Point: UILabel!
        
        @IBOutlet weak var lblVenue: UILabel!
        @IBOutlet weak var lblWinLoseTeam: UILabel!
        @IBOutlet weak var lblChakDe: UILabel!
        @IBOutlet weak var lblWinLosePercent: UILabel!
        @IBOutlet weak var lblTeam1Percent: UILabel!
        @IBOutlet weak var lblTeam2Percent: UILabel!
        @IBOutlet weak var lblMatchNo: UILabel!
    
        weak var delegate: LeagueMatchDelegate?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            
        }
        
        @IBAction func Team1Selected(_ sender: UIButton) {
            delegate?.btnSelectTeam1(cell: self)
        }
        
        @IBAction func Team2Selected(_ sender: UIButton) {
            delegate?.btnSelectTeam2(cell: self)
        }
        
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Configure the view for the selected state
        }
        
}
