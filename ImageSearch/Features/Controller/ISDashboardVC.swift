//
//  ISDashboardVC.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/20/22.
//

import UIKit


class ISDashboardVC: UIViewController {
    
    @IBOutlet weak private var searchBarView: UISearchBar!
    @IBOutlet weak private var photoListCollectionView: UICollectionView!
    @IBOutlet weak private var activityLoaderView: UIActivityIndicatorView!
    @IBOutlet weak private var footerLoadingBGView: UIView!
    @IBOutlet weak private var footerActivityLoaderView: UIActivityIndicatorView!
    
    private let viewModel = ISDashboardVM()
    private var page: Int = 1
    private var searchText = ""
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations = [IndexPath : DataLoadOperation]()
    private var workItemReference : DispatchWorkItem? = nil
    private var cellWidth: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        getData(searchTxt: "", page: page)
    }
    
    private func style(){
        navigationItem.titleView = searchBarView
        searchBarView.delegate = self
        activityLoaderView.isHidden = true
        photoListCollectionView.prefetchDataSource = self
        cellWidth = (view.frame.size.width - 30) / 2
    }
    
    private func getData(searchTxt: String, page: Int){
        if page == 1{
            footerLoadingBGView.isHidden = true
            footerActivityLoaderView.isHidden = true
            activityLoaderView.isHidden = false
            activityLoaderView.startAnimating()
        }else{
            activityLoaderView.isHidden = true
            footerLoadingBGView.isHidden = false
            footerActivityLoaderView.isHidden = false
            footerActivityLoaderView.startAnimating()
        }
        
        viewModel.getSearchImage(searchTxt: searchTxt, page: page) { success in
            DispatchQueue.main.async {
                self.activityLoaderView.stopAnimating()
                self.activityLoaderView.isHidden = true
                self.footerLoadingBGView.isHidden = true
                self.footerActivityLoaderView.isHidden = true
                self.footerActivityLoaderView.stopAnimating()
            }
            
            if success{
                DispatchQueue.main.async {
                    self.photoListCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func optionAction(_ sender: Any) {
        showActionSheet()
    }
    
    private func showActionSheet(){
        let frameWidth = view.frame.size.width - 30
        
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: Constants.twoImagePerRow, style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.cellWidth = frameWidth / 2
            self.photoListCollectionView.reloadData()
        }))
        
        actionsheet.addAction(UIAlertAction(title: Constants.threeImagePerRow, style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.cellWidth = (frameWidth - 10) / 3
            self.photoListCollectionView.reloadData()
        }))
        actionsheet.addAction(UIAlertAction(title: Constants.fourImagePerRow, style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.cellWidth = (frameWidth - 20) / 4
            self.photoListCollectionView.reloadData()
        }))
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
            
        }))
        present(actionsheet, animated: true, completion: nil)
    }
    
}

extension ISDashboardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.photosList?.count == 0{
            Helper.emptyMessageInCollectionView(collectionView, Constants.noDataAvailable)
        }else{
            collectionView.backgroundView = nil
        }
        return viewModel.photosList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ISImageCell.identifier, for: indexPath) as? ISImageCell else {return UICollectionViewCell()}
        cell.updateAppearanceFor(.none)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ISImageCell else { return }
        
        if indexPath.row == (viewModel.photosList?.count ?? 0) - 1 && collectionView.contentOffset.y > 0{
            page = page + 1
            debugPrint("current page: \(page)")
            self.getData(searchTxt: searchText, page: page)
        }
        
        // How should the operation update the cell once the data has been loaded?
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.updateAppearanceFor(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        // Try to find an existing data loader
        if let dataLoader = loadingOperations[indexPath] {
            // Has the data already been loaded?
            if let image = dataLoader.image {
                cell.updateAppearanceFor(image)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                // No data loaded yet, so add the completion closure to update the cell once the data arrives
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            // Need to create a data loaded for this index path
            if let dataLoader = viewModel.loadImage(at: indexPath.row, size: CFloat(cellWidth)) {
                // Provide the completion closure, and kick off the loading operation
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showImageDetails(collectionView, indexPath: indexPath)
    }
    
    private func showImageDetails(_ collectionView: UICollectionView, indexPath: IndexPath){
        let imageViewer = ISImageDetailsView()
        imageViewer.frame = self.view.bounds
        imageViewer.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.view.addSubview(imageViewer)
        let cPoint = collectionView.layoutAttributesForItem(at: indexPath)?.center
        guard let cell = collectionView.cellForItem(at: indexPath) as? ISImageCell else {return}
        let image = cell.getCellImage()
        imageViewer.showImage(image: image! , fromSize: CGSize(width: cellWidth, height: cellWidth), x: cPoint?.x ?? self.view.layer.frame.midX, y: cPoint?.y ?? self.view.layer.frame.midY, duration: 0.30)
    }
}

extension ISDashboardVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if self.searchText.isEmpty{
            searchBarCancelButtonClicked(searchBar)
        }else{
            workItemReference?.cancel()
            
            // make api call to fetch the data
            let imageSearchWorkItem = DispatchWorkItem{
                self.getData(searchTxt: searchText, page: self.page)
            }
            
            workItemReference = imageSearchWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: imageSearchWorkItem)
        }

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String()
        viewModel.photosList = []
        photoListCollectionView.reloadData()
    }
}

extension ISDashboardVC: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] { return }
            if let dataLoader = viewModel.loadImage(at: indexPath.row, size: CFloat(cellWidth)) {
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}

extension ISDashboardVC: ISImageDetailsDelegate{
    func didDismiss() {
        self.navigationController?.navigationBar.isHidden = false
    }
}
