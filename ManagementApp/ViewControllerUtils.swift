//
//  ViewControllerUtils.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/26/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerUtils: NSObject {
    
    static let sharedInstance = ViewControllerUtils()
    private var activityIndicator = UIActivityIndicatorView()
    
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    //MARK: - Private Methods -
    private func setupLoader() {
        removeLoader()
        
        activityIndicator.hidesWhenStopped = true
        // activityIndicator.activityIndicatorViewStyle = .whiteLarge
        //        if #available(iOS 11.0, *) {
        //            activityIndicator.color = UIColor.init(named: "FontDarkText")
        //        } else {
        //            activityIndicator.color = UIColor.darkGray
        //        }
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = "Loading..."
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
    }
    
    
    
    //MARK: - Public Methods -
    func showLoader() {
        setupLoader()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let holdingView = appDel.window!.rootViewController!.view!
        
        DispatchQueue.main.async {
            self.strLabel.removeFromSuperview()
            self.activityIndicator.removeFromSuperview()
            self.effectView.removeFromSuperview()
            
            self.strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
            self.strLabel.text = "Loading..."
            self.strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
            self.strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            
            self.effectView.frame = CGRect(x: holdingView.frame.midX - self.strLabel.frame.width/2, y: holdingView.frame.midY - self.strLabel.frame.height/2 , width: 160, height: 46)
            self.effectView.layer.cornerRadius = 15
            self.effectView.layer.masksToBounds = true
            
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            self.activityIndicator.startAnimating()
            
            self.effectView.contentView.addSubview(self.activityIndicator)
            self.effectView.contentView.addSubview(self.strLabel)
            holdingView.addSubview(self.effectView)
//            self.activityIndicator.center = holdingView.center
//            self.activityIndicator.startAnimating()
//
//            self.effectView.frame = CGRect(x: holdingView.frame.midX - self.strLabel.frame.width/2, y: holdingView.frame.midY - self.strLabel.frame.height/2 , width: 160, height: 46)
//
//            self.effectView.contentView.addSubview(self.strLabel)
//            self.effectView.contentView.addSubview(self.activityIndicator)
//            holdingView.addSubview(self.effectView)
            
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    
    func showViewLoader(view: UIView) {
        setupLoader()
        
        DispatchQueue.main.async {
            self.activityIndicator.center = view.center
            self.activityIndicator.startAnimating()
            view.addSubview(self.activityIndicator)
            
            self.activityIndicator.center = view.center
            self.activityIndicator.startAnimating()
            
            self.effectView.frame = CGRect(x: view.frame.midX - self.strLabel.frame.width/2, y: view.frame.midY - self.strLabel.frame.height/2 , width: 160, height: 46)
            
            self.effectView.contentView.addSubview(self.strLabel)
            self.effectView.contentView.addSubview(self.activityIndicator)
            view.addSubview(self.effectView)
        }
    }
    
    func removeLoader(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            
            self.strLabel.removeFromSuperview()
            self.effectView.removeFromSuperview()
            
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    
    //For no internet connection and no data check
    func showNoData(view: UIView,from:String) {
        
        var viewNoData = UIView()
        
        if(from.isEqual("NDA"))
        {
            var tmp = Bundle.main.loadNibNamed("NoDataView", owner: nil, options: nil);
            viewNoData = tmp?[0] as! UIView;
        }
        else if(from.isEqual("ERR"))
        {
            var tmp = Bundle.main.loadNibNamed("ErrorView", owner: nil, options: nil);
            viewNoData = tmp?[0] as! UIView;
        }
        else if(from.isEqual("NET"))
        {
            var tmp = Bundle.main.loadNibNamed("NoInternetView", owner: nil, options: nil);
            viewNoData = tmp?[0] as! UIView;
        }
        viewNoData.center = CGPoint(x: view.bounds.size.width / 2.0, y: viewNoData.bounds.size.height / 2.0);
        view.addSubview(viewNoData)
        view.isHidden = false
    }
    
    func removeNoData(view: UIView){
        view.isHidden = true
    }
    
}


public class NoDataView : UIView {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var imvNoData: UIImageView!
    @IBOutlet weak var btnRetry: UIButton!
    var delegate: RetryApi?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init (from:String) {
        self.init(frame:CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let _ = loadViewFromNib()
        
    }
    
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle.init(for: type(of: self))
        let nib = UINib(nibName: "NoDataView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
        return view
        
    }
    
    
    func showView(view:UIView,from:String){
        view.isHidden = false
        
        if(from.isEqual("NDA")){
            lblNoData.text = "No Data Available"
            imvNoData.image = UIImage(named:"icon_no_data")
            loader.isHidden = true
        }else if(from.isEqual("ERR")){
            lblNoData.text = "Server Error"
            imvNoData.image = UIImage(named:"icon_error")
            loader.isHidden = true
        }else if(from.isEqual("NET")){
            lblNoData.text = "No Internet Connection"
            imvNoData.image = UIImage(named:"icon_no_internet")
            loader.isHidden = true
        }else if(from.isEqual("LOADER")){
            loader.isHidden = false
            imvNoData.image = nil
            lblNoData.text = ""
        }
    }
    
    func hideView(view:UIView){
        view.isHidden = true
        loader.isHidden = true
    }
    
    
    func showTransparentView(view:UIView,from:String){
        viewNoData.backgroundColor = UIColor.clear
        view.isHidden = false
        
        if(from.isEqual("LOADER")){
            loader.isHidden = false
            imvNoData.image = nil
            lblNoData.text = ""
        }
    }
    
}

