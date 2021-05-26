//
//  PagedTableView.swift
//  PagedTableView
//
//  Created by Adam Wienconek on 25/05/2021.
//

import UIKit

public protocol PagedTableViewDataSource: AnyObject {
    func sectionTitles(inPagedTable pagedTableView: PagedTableView) -> [String]
    func configure(tableView: UITableView, atIndex index: Int)
}

public class PagedTableView: UIScrollView {
    
    public weak var dataSource: PagedTableViewDataSource? {
        didSet {
            reloadData()
        }
    }
        
    public var padding: CGFloat = 0 {
        didSet {
            stackView.spacing = 2 * padding
        }
    }
    
    public var tableHeaderView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            tableHeaderView?.translatesAutoresizingMaskIntoConstraints = false
            setupView()
        }
    }
    
    public var backgroundView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            backgroundView?.translatesAutoresizingMaskIntoConstraints = false
            setupView()
        }
    }
    
    private var tableScrollObservers: [NSKeyValueObservation]!
    private lazy var stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private lazy var headerView: PagedTableHeaderView = {
        let h = PagedTableHeaderView(frame: .zero)
        h.translatesAutoresizingMaskIntoConstraints = false
        h.delegate = self
        return h
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private var numberOfPages: Int {
        return dataSource?.sectionTitles(inPagedTable: self).count ?? 0
    }
    
    public func index(ofTableView tableView: UITableView) -> Int {
        return stackView.arrangedSubviews.firstIndex(of: tableView) ?? NSNotFound
    }
    
    public func reloadData() {
        tableScrollObservers = []
        stackView.removeAllArrangedSubviews()
       
        let segments = dataSource?.sectionTitles(inPagedTable: self) ?? []
        if segments.isEmpty {
            return
        }
        for idx in 0 ..< segments.count {
            setupTableView(atIndex: idx)
        }
        headerView.configure(withSections: segments)
    }
    
    private func commonInit() {
        delegate = self
        showsHorizontalScrollIndicator = false
        isDirectionalLockEnabled = true
        isPagingEnabled = true
        backgroundColor = .orange
        
        setupView()
    }
    
    func setPage(atIndex index: Int, animated: Bool) {
        let offset = CGPoint(x: frame.width * CGFloat(index), y: 0)
        setContentOffset(offset, animated: animated)
    }
    
    private func handleTableScrolling(atOffset offset: CGFloat) {
        let y = -offset
        let origin = max(y, (contentInset.top + (tableHeaderView?.bounds.height ?? 0)) - headerView.bounds.height)
        print(y, origin)
        headerView.frame.origin.y = origin
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        headerView.frame.size.width = bounds.width
    }
}

extension PagedTableView: PagedTableHeaderViewDelegate {
    func headerView(_ headerView: PagedTableHeaderView, switchedSegmentToIndex index: Int) {
        setPage(atIndex: index, animated: true)
    }
}

extension PagedTableView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = Int((x / scrollView.bounds.width).rounded())
        
        headerView.setSelectedIndex(page)
    }
}

// - MARK: Configuring view
private extension PagedTableView {
    private func setupTableView(atIndex index: Int) {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.contentInsetAdjustmentBehavior = .never
        tableScrollObservers.append(tableView.observe(\.contentOffset, options: .new, changeHandler: { [weak self] tableView, change in
            guard let offset = change.newValue?.y else {
                return
            }
            self?.handleTableScrolling(atOffset: offset)
        }))
        
        stackView.insertArrangedSubview(tableView, at: index)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
        ])
        
        dataSource?.configure(tableView: tableView, atIndex: index)
    }
    
    private func setupView() {
        removeAllSubviews()
        stackView.backgroundColor = .systemPink
        
        if let background = backgroundView {
            addSubview(background)
        }
        if let header = tableHeaderView {
            addSubview(header)
        }
        addSubview(stackView)
        addSubview(headerView)
        
        let constraints = prepareConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    
    func prepareConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        if let background = backgroundView {
            constraints.append(contentsOf: [
                background.topAnchor.constraint(equalTo: frameLayoutGuide.topAnchor),
                background.bottomAnchor.constraint(equalTo: frameLayoutGuide.bottomAnchor),
                background.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
                background.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor)
            ])
        }
        
        if let header = tableHeaderView {
            constraints.append(contentsOf: [
                header.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
                header.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
                header.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
            ])
        }
        
        constraints.append(contentsOf: [
            headerView.topAnchor.constraint(equalTo: tableHeaderView?.bottomAnchor ?? contentLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor),
        ])
        
        return constraints
    }
}
