//
//  DeviceTableViewCell.swift
//  HitList
//
//  Created by Lawrence on 2018-11-12.
//  Copyright © 2018 Lawrence. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        addSubview(ownerLabel)
        
        ownerLabel.leadingAnchor.constraint(equalTo: textLabel!.trailingAnchor).isActive = true
    
    }

    public let ownerLabel : UILabel = { () -> UILabel in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
