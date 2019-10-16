//
//  LeftMenuLayout.swift
//  G-Management
//
//  Created by Goldmedal on 12/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import Foundation
import UIKit

enum ProfileViewModelItemType {
    case reports
}

protocol ProfileViewModelItem {
    var type: ProfileViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
    var isCollapsible: Bool { get }
    var isCollapsed: Bool { get set }
}

extension ProfileViewModelItem {
    var rowCount: Int {
        return 1
    }
    
    var isCollapsible: Bool {
        return true
    }
}

class ProfileViewModel: NSObject {
    var items = [ProfileViewModelItem]()
    
    var reloadSections: ((_ section: Int) -> Void)?
    
    override init() {
        super.init()
        guard let data = dataFromFile("LeftMenuData"), let leftmenu = LeftMenu(data: data) else {
            return
        }
        
        let reports = leftmenu.reports
        if !leftmenu.reports.isEmpty {
            let reportsItem = ProfileViewModeFriendsItem(report: reports)
            items.append(reportsItem)
        }
    }
}

extension ProfileViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = items[section]
        guard item.isCollapsible else {
            return item.rowCount
        }
        
        if item.isCollapsed {
            return 0
        } else {
            return item.rowCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        
        case .reports:
            if let item = item as? ProfileViewModeFriendsItem, let cell = tableView.dequeueReusableCell(withIdentifier: listCell.identifier, for: indexPath) as? listCell {
                let reports = item.report[indexPath.row]
                cell.item = reports
                return cell
            }
        
        }
        return UITableViewCell()
    }
}

extension ProfileViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderView.identifier) as? HeaderView {
            let item = items[section]
            
            headerView.item = item
            headerView.section = section
            headerView.delegate = self
            return headerView
        }
        return UIView()
    }
}

extension ProfileViewModel: HeaderViewDelegate {
    func toggleSection(header: HeaderView, section: Int) {
        var item = items[section]
        if item.isCollapsible {
            
            // Toggle collapse
            let collapsed = !item.isCollapsed
            item.isCollapsed = collapsed
            header.setCollapsed(collapsed: collapsed)
            
            // Adjust the number of the rows inside the section
            reloadSections?(section)
        }
    }
}

class ProfileViewModeFriendsItem: ProfileViewModelItem {
    
    var type: ProfileViewModelItemType {
        return .reports
    }
    
    var sectionTitle: String {
        return "Reports"
    }
    
    var rowCount: Int {
        return report.count
    }
    
    var isCollapsed = true
    
    var report: [Reports]
    
    init(report: [Reports]) {
        self.report = report
    }
}
