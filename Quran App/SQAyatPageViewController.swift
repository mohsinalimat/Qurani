//
//  SQAyatPageViewController.swift
//  Quran App
//
//  Created by Hussein AlRyalat on 4/19/19.
//  Copyright © 2019 Sketch Studio. All rights reserved.
//

import UIKit

class SQAyatPageViewController: UIViewController {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: YYTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /* get the surah */
        let surah = SQQuranReader.shared.surah(at: 1)
        
        /* get the ayat */
        let ayat = surah?.ayat[5...15]
        
        /* generate a string */
        var contents = ayat?.reduce("", { (result, ayah) -> String in
            return result + ayah.text + " " + ayah.index.localized + " "
        })
        
        contents?.removeLast()
        label.text = contents
        
        print(label.font.pointSize)
        label.layoutIfNeeded()
        
        print(label.font.pointSize)
    }
}
