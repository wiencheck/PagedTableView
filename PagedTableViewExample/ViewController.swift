//
//  ViewController.swift
//  PagedTableView
//
//  Created by Adam Wienconek on 25/05/2021.
//

import UIKit
import PagedTableView

class ViewController: UIViewController {
    
    @IBOutlet weak var pagedTableView: PagedTableView!
    
//    lazy var data: [[Int]] = {
//        return (1...30).reduce(into: [[Int]]()) { arr, i in
//            let mod = i % 10
//            if
//        }
//    }()
    
    let data = [
        [1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 2, 3, 4, 5, 6, 7, 8, 9],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        pagedTableView.dataSource = self
        
        pagedTableView.tableHeaderView = {
            let v = UIView(frame: .zero)
            v.backgroundColor = .green
            v.heightAnchor.constraint(equalToConstant: 80).isActive = true
            return v
        }()
        
//        pagedTableView.backgroundView = {
//            let v = UIView(frame: .zero)
//            v.backgroundColor = .purple
//            return v
//        }()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(pagedTableView.frame)
        print(pagedTableView.subviews.first!.frame)
    }

}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tableIndex = pagedTableView.index(ofTableView: tableView)
        return data[tableIndex].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let tableIndex = pagedTableView.index(ofTableView: tableView)
        let number = data[tableIndex][indexPath.row]
        cell.textLabel?.text = "Cell: \(number)"
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: PagedTableViewDataSource {
    func sectionTitles(inPagedTable pagedTableView: PagedTableView) -> [String] {
        return ["1", "2", "3"]
    }
    
    func configure(tableView: UITableView, atIndex index: Int) {
        switch index {
        case 1:
            tableView.backgroundColor = .green
        case 2:
            tableView.backgroundColor = .yellow
        default:
            tableView.backgroundColor = .cyan
        }
        tableView.delegate = self
        tableView.dataSource = self
        // If using custom cells, you should register them here
    }
}
