//
//  ViewController.swift
//  MVVM_RxSwift_Restaurant
//
//  Created by 한상진 on 2021/04/14.
//

import UIKit

import RxCocoa
import RxSwift

final class SingerVC: BaseVC<SingerVM> {
    
    // MARK: Constant
    
    private enum Text {
        static let title: String = "가수 검색 화면"
    }
    
    private enum Matric {
        static let tableViewHeight: CGFloat = 100
    }
    
    // MARK: UI Property
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    private let searchController: UISearchController = .init()
    
    // MARK: Property
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupUI()
    }
}

// MARK: Bind

private extension SingerVC {
    func bindViewModel() {
        viewModel.start()
        eventBind()
        stateBind()
    }
    
    func eventBind() { 
        searchController.searchBar.rx.searchButtonClicked
            .debug()
            .map { [unowned self] _ -> String in
                return self.searchController.searchBar.text ?? "" 
            }
            .bind(to: viewModel.queryRelay)
            .disposed(by: disposeBag)
        
        // TODO: ObservableType만 bind 가능한 지 다시 찾아보기
        tableView.rx.modelDeleted(Itunes.self)
            .bind(to: viewModel.cellClickEvent)
            .disposed(by: disposeBag)
    }
    
    func stateBind() {
        
        viewModel.searchResultRelay
            .asDriver()
            .map { $0.isEmpty }
            .drive(tableView.rx.isHidden, emptyImageView.rx.isNotHidden)
            .disposed(by: disposeBag)
        
        viewModel.searchResultRelay
            .asDriver()
            .drive(
                tableView.rx.items(
                    cellIdentifier: SingerCell.reusableID,
                    cellType: SingerCell.self
                )
            ) { index, item, cell in
                cell.bind(with: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.errorEvent
            .asDriverOnErrorJustComplete()
            .drive(onNext: {
                Logger.info($0)
                // ErrorHandler
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UI

private extension SingerVC {
    func setupUI() {
        configureNavi()
        configureTableView()
    }
    
    func configureNavi() {
        navigationItem.title = Text.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configureSearchController()
        navigationItem.searchController = searchController
    }
    
    func configureSearchController() {
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.barStyle = .default
        searchController.searchBar.tintColor = .black
        searchController.searchBar.isTranslucent = true
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    func configureTableView() {
        let nib = UINib(nibName: SingerCell.reusableID, bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: SingerCell.reusableID)
        tableView.rowHeight = Matric.tableViewHeight
    }
}
