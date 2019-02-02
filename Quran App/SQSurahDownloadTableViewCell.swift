//
//  SQSurahDownloadTableViewCell.swift
//  Quran App
//
//  Created by Hussein Ryalat on 2/1/18.
//  Copyright © 2018 Sketch Studio. All rights reserved.
//

import UIKit

class SQSurahDownloadTableViewCell: UITableViewCell {
    
    enum State {
        case downloading
        case unstarted
        case paused

        fileprivate func _playButtonTitle() -> String {
            switch self {
            case .unstarted:
                return "تحميل السورة"
            case .downloading:
                return "إيقاف"
            case .paused:
                return "إكمال"
            }
        }
        
        fileprivate func _subtitle() -> String {
            switch self {
            case .unstarted:
                return "السورة غير محمّلة بعد"
            case .downloading:
                return "جاري تحميل السورة.."
            case .paused:
                return "التحميل متوقف"
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var resumePauseButton: UIButton!
    
    var onCancelButtonTap: (() -> Void)?
    var onDownloadButtonTap: (() -> Void)?
    
    fileprivate(set) var state: State = .unstarted
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cancelButton.cornerRadius = cancelButton.frame.height / 2
        resumePauseButton.cornerRadius = resumePauseButton.frame.height / 2
        
        set(state: .unstarted, animated: false)
    }
    
    func set(state: State, animated: Bool){
        self.state = state
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.cancelButton.alpha = state == .unstarted ? 0.5 : 1.0
            })
        } else {
            self.cancelButton.alpha = state == .unstarted ? 0.5 : 1.0
        }
        
        self.cancelButton.isEnabled = state != .unstarted
        self.resumePauseButton.setTitle(state._playButtonTitle(), for: .normal)
        self.descriptionLabel.text = state._subtitle()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        onCancelButtonTap?()
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        onDownloadButtonTap?()
    }
    
}
