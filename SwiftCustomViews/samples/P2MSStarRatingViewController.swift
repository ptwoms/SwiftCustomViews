//
//  P2MSStarRatingViewController.swift
//  SwiftCustomViews
//
//  Created by Pyae Phyo Myint Soe on 1/7/18.
//  Copyright © 2018 Pyae Phyo Myint Soe. All rights reserved.
//

import UIKit

class P2MSStarRatingViewController: UIViewController {
    
    @IBOutlet weak var starRatingView: P2MSStarRatingView!
    @IBOutlet weak var topMessage: UILabel!
    @IBOutlet weak var ratingInfo: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        topMessage.text = NSLocalizedString("star_rating_inital_top_msg", comment: "")
        ratingChanged(count: 0)
        starRatingView.setListener(ratingChanged: { [weak self] (count) in
            self?.ratingInfo.text = String.localizedStringWithFormat(NSLocalizedString("rating_count_template", comment: ""), count)
        }) { [weak self] (count) in
            if count == 0 {
                self?.topMessage.text = NSLocalizedString("star_rating_inital_top_msg", comment: "")
            }else{
                self?.topMessage.text = NSLocalizedString("rating_thank_you_msg", comment: "")
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//alertnative way to setListener
extension P2MSStarRatingViewController: P2MSStarRatingViewDelegate{
    func ratingChanged(count: Int) {
    }
    
    func ratingDone(count: Int) {
        
    }
}
