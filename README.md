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

```swift
    func bind(_ viewModel: FilterViewModel) {
        sortButton.rx.tap // Sort button을 탭하면
            .bind(to: viewModel.sortButtonTapped) 
            .disposed(by: disposeBag)
    }
```
- sortButton이 tap되면 뷰모델로 sortButtonTapped애 바인딩 시켜줌 (버튼 누르는 것은 View에서 일어나는 일이기 때문에)
- View -> ViewModel

```swift
 // View -> ViewModel
    let sortButtonTapped = PublishRelay<Void>() //sort하는 버튼을 눌러서 바인딩 되어 넘어옴
    let shouldUpdateType: Observable<Void> // 버튼이 눌렸다면 업데이트 시켜줄 Observable
    
    init() {
        self.shouldUpdateType = sortButtonTapped
            .asObservable()
    }
```
 - view에서 tap 하여 viewModel의 sortButtonTapped로 바인딩 되면  sortButtonTapped의 PublishRelay 기능에 따라 하나씩 ShouldUpdateType으로 보낸다.

