//
//  File.swift
//  
//
//  Created by Adam Wienconek on 26/05/2021.
//

import UIKit

protocol PagedTableHeaderViewDelegate: AnyObject {
    func headerView(_ headerView: PagedTableHeaderView, switchedSegmentToIndex index: Int)
}

class PagedTableHeaderView: UIView {
    weak var delegate: PagedTableHeaderViewDelegate?
    
    private lazy var segment: UISegmentedControl = {
        let s = UISegmentedControl(frame: .zero)
        s.addTarget(self, action: #selector(handleSegmentSwitched(_:)), for: .valueChanged)
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func configure(withSections sections: [String]) {
        for section in sections.reversed() {
            segment.insertSegment(withTitle: section, at: 0, animated: false)
        }
        segment.selectedSegmentIndex = 0
    }
    
    func setSelectedIndex(_ index: Int) {
        segment.selectedSegmentIndex = index
    }
    
    private func commonInit() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        addSubview(segment)
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segment.centerYAnchor.constraint(equalTo: centerYAnchor),
            segment.centerXAnchor.constraint(equalTo: centerXAnchor),
            segment.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            segment.topAnchor.constraint(equalTo: topAnchor, constant: 4)
        ])
    }
    
    @objc private func handleSegmentSwitched(_ sender: UISegmentedControl) {
        delegate?.headerView(self, switchedSegmentToIndex: sender.selectedSegmentIndex)
    }
}
