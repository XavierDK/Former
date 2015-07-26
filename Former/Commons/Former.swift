//
//  Former.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 7/23/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public final class Former: NSObject {
    
    public weak var tableView: UITableView? {
        didSet {
            self.setupTableView()
        }
    }
    
    public var numberOfSectionFormers: Int {
        return self.sectionFormers.count
    }
    
    private(set) var sectionFormers = [SectionFormer]()
    private var selectedCellIndexPath: NSIndexPath?
    
    public init(tableView: UITableView) {
        
        super.init()
        self.tableView = tableView
        self.setupTableView()
    }
    
    public subscript(index: Int) -> SectionFormer {
        
        return self.sectionFormers[index]
    }
    
    public func registerCellClass<T: UITableViewCell where T: FormableRow>(cellType: T.Type) {
        
        self.tableView?.registerClass(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    public func registerViewClass<T: UITableViewHeaderFooterView where T: FormableView>(viewType: T.Type) {
        
        self.tableView?.registerClass(viewType, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
    }
    
    public func rowFormer(indexPath: NSIndexPath) -> RowFormer {
        
        return self[indexPath.section][indexPath.row]
    }
    
    public func addSectionFormer(sectionFormer: SectionFormer) -> Former {
        
        self.addSectionFormers([sectionFormer])
        return self
    }
    
    public func addSectionFormers(sectionFormers: [SectionFormer]) -> Former {
        
        self.sectionFormers += sectionFormers
        return self
    }
    
    public func reloadSectionFormer(sectionFormer: SectionFormer, section: Int, rowAnimation: UITableViewRowAnimation = .None) {
        
        assert(self.sectionFormers.count < section, "Invalid section index.")
        self.sectionFormers[section] = sectionFormer
        self.tableView?.reloadSections(NSIndexSet(index: section), withRowAnimation: rowAnimation)
    }

    public func reloadSectionFormers(sectionFormers: [SectionFormer], sections: [Int], rowAnimation: UITableViewRowAnimation = .None) {
        
        assert(sectionFormers.count == sections.count, "Number of sectionFormers and number of sections does not correspond.")
        sections.map {
            self.reloadSectionFormer(sectionFormers[$0], section: $0, rowAnimation: rowAnimation)
        }
    }
    
    public func reloadFormer() {
        
        self.tableView?.reloadData()
    }
    
    public func deselectSelectedCell(animated: Bool) {
        
        if let indexPath = self.selectedCellIndexPath {
            self.tableView?.deselectRowAtIndexPath(indexPath, animated: animated)
        }
        self.selectedCellIndexPath = nil
    }
    
    public func resignSelectedCellFirstResponder() {
        
        if let selectedCellIndexPath = self.selectedCellIndexPath {
            self.rowFormer(selectedCellIndexPath).resignCellFirstResponder()
        }
        self.selectedCellIndexPath = nil
    }
    
    private func setupTableView() {
        
        self.registerViewClass(FormerHeaderFooterView)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorStyle = .None
    }
}

extension Former: UITableViewDelegate, UITableViewDataSource {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.resignSelectedCellFirstResponder()
    }
    
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        self.resignSelectedCellFirstResponder()
        self.selectedCellIndexPath = indexPath
        return indexPath
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowFormer = self.rowFormer(indexPath)
        rowFormer.selectedHandler?(indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return false
    }
    
    // MARK: Cell
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return self.numberOfSectionFormers
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self[section].numberOfRowFormers
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return self.rowFormer(indexPath).rowHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let rowFormer = self.rowFormer(indexPath)
        let cellType = rowFormer.cellType
        let cell = tableView.dequeueReusableCellWithIdentifier(
            cellType.reuseIdentifier,
            forIndexPath: indexPath
        )
        rowFormer.cell = cell
        if let FormableRow = cell as? FormableRow {
            FormableRow.configureWithRowFormer(rowFormer)
        }
        return cell
    }
    
    // MARK: HeaderFooterVeiw
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return self[section].headerViewFormer.viewHeight
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return self[section].footerViewFormer.viewHeight
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewFormer = self[section].headerViewFormer
        let viewType = viewFormer.viewType
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(viewType.reuseIdentifier)
        viewFormer.view = headerView
        if let formableHeaderView = headerView as? FormableView {
            formableHeaderView.configureWithViewFormer(viewFormer)
        }
        return headerView
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let viewFormer = self[section].footerViewFormer
        let viewType = viewFormer.viewType
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(
            viewType.reuseIdentifier
        )
        viewFormer.view = footerView
        if let formableFooterView = footerView as? FormableView {
            formableFooterView.configureWithViewFormer(viewFormer)
        }
        return footerView
    }
}