# CafeBlogSearchApp

## 다음 블로그 검색 앱 구현


### 1. SearchBar와 테이블 뷰 
> 블로그 이름을 검색할 SearchBar 구현과 검색했을 때 블로그들을 보여줄 TableView 구현


![simulator_screenshot_9F917EA3-C62B-4526-B3C0-74F3FFEB1B57](https://user-images.githubusercontent.com/61230321/148673000-deb0fd19-8e10-44f3-8636-fe454ddc2435.png)


### 2. 검색 후 화면
> 검색했을 때 보여지는 모습


![simulator_screenshot_041A694D-DA14-4311-9B19-FAF62F9C2AB2](https://user-images.githubusercontent.com/61230321/148673252-352eb845-fe39-4dc2-ae58-57cf6962a112.png)



### 3. 코드 리뷰
> API를 통해 받아와서 decoding 할 구조체와 받아서 tableViewCell에 넣어 줄 구조체 필요함.

#### 1) FilterView & FilterViewModel

##### FilterView
```swift
    func bind(_ viewModel: FilterViewModel) {
        sortButton.rx.tap // Sort button을 탭하면
            .bind(to: viewModel.sortButtonTapped) 
            .disposed(by: disposeBag)
    }
```
- sortButton이 tap되면 뷰모델로 sortButtonTapped애 바인딩 시켜줌 (버튼 누르는 것은 View에서 일어나는 일이기 때문에)
- View -> ViewModel
##### FilterViewModel
```swift
 // View -> ViewModel
    let sortButtonTapped = PublishRelay<Void>() //sort하는 버튼을 눌러서 바인딩 되어 넘어옴
    let shouldUpdateType: Observable<Void> // 버튼이 눌렸다면 업데이트 시켜줄 Observable
    
    init() {
        self.shouldUpdateType = sortButtonTapped
            .asObservable()
    }
```
 - view에서 tap 하여 viewModel의 sortButtonTapped로 바인딩 되면 sortButtonTapped의 PublishRelay 기능에 따라 하나씩 ShouldUpdateType으로 보낸다.


#### 2) BlogListView & BlogListViewModel

##### BlogListView

```swift
let headerView = FilterView(
        frame: CGRect(
            origin: .zero,
            size: CGSize(width: UIScreen.main.bounds.width, height: 50)
        )
    )
```
- BlogListView의 헤더뷰는 FilterView이다.

```swift
 
    func bind(_ viewModel: BlogListViewModel) {
        
        headerView.bind(viewModel.filterViewModel) // BlogList의 헤더뷰는 filterView의 filterViewModel에 바인드
        
        //viewModel에서 cellData는 blogListCellData의 PublishSubject의 기능을 통해 BlogListCellData를 하나씩 받아옴
        viewModel.cellData
            .asDriver(onErrorJustReturn: [])
            .drive(self.rx.items) { tv, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: "BlogListCell", for: index) as! BlogListCell
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)
    }
```
- headerView를 BlogListViewModel에 바인딩 시켜준다.
- viewModel에서 cellData는 ViewModel에서부터 바인딩 받아서 blogListCellData(BlogListViewModel에 있는 값)의 PublishSubject의 기능을 통해 BlogListCellData를 받아옴
- drive룰 통해 데이터를 받아온다.

##### BlogListViewModel

```swift

   //View -> ViewModel
    let filterViewModel = FilterViewModel()
    
  //ViewModel -> View
    let blogListCellData = PublishSubject<[BlogListCellData]>()
    let cellData: Driver<[BlogListCellData]>
    
    init() {
        self.cellData = blogListCellData
            .asDriver(onErrorJustReturn: [])
    }
```
- blogListCellData를 PublishSubject<[BlogListCellData]>() 로 설정하여 BlgoListCellData를 받아온다.
- init 안에서 blogListCellData를 Driver로 만들어 cellData에 저장



#### 3) BlogListCellData
- Decoding 되어 받아오는 DKBlog의 값을 받아오는 구조체


#### 4) DKBlog
- API 통신을 


