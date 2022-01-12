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
- API 통신을 통해 받아온 정보를 저장하는 구조체

### 5) SearchBlogAPI & SearchBlogNetwork

#### SearchBlogAPI  

``` Swift
struct SearchBlogAPI {
    static let scheme = "https"
    static let host = "dapi.kakao.com"
    static let path = "/v2/search/"
    
    func searchBlog(query: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = SearchBlogAPI.scheme
        components.host = SearchBlogAPI.host
        components.path = SearchBlogAPI.path + "blog"
        
        components.queryItems = [
            URLQueryItem(name:"query",value: query)
        ]
        
        return components
    }
}
```
- scheme, host , path를 저장 (Developers kakao의 문서에서 확인 가능)
- URLComponents를 return하는 함수를 만들어서 저장한다.

#### SearchBlogNetwork

``` swift
enum SearchNetworkError: Error {
    case invalidJSON
    case networkError
    case invalidURL
    
    var message: String {
        switch self {
        case .invalidURL, .invalidJSON:
            return "데이터를 불러올 수 없습니다."
        case .networkError:
            return "네트워크 상태를 확인해주세요."
        }
    }
}


class SearchBlogNetwork {
    private let session: URLSession
    let api = SearchBlogAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchBlog(query: String) -> Single<Result<DKBlog, SearchNetworkError>> {
        guard let url = api.searchBlog(query: query).url else {
            return .just(.failure(.invalidURL))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK 05a26cb7d0a9977f4cb650127321abea", forHTTPHeaderField: "Authorization")
        
        return session.rx.data(request: request as URLRequest)
            .map{ data in
                do {
                    let blogData = try JSONDecoder().decode(DKBlog.self,
                                                            from: data)
                    return .success(blogData)
                }catch {
                    return .failure(.invalidJSON)
                }
            }
            .catch{ _ in
                .just(.failure(.networkError))
            }
            .asSingle()
    }
}
```

- enum으로 SearchNetworkError 만들기
- api에 위에서 만든 SearchBlogAPI()를 저장
- URLSession을 .shared 한다.
- Single<Result<DKBlog, SearchNetworkError>> 는 성공했을 때는 DKBlog, 실패하면 SearchNetworkError를 방출한다.
- api의 searchBlog의 query를 받아 .url을 통해 url로 만들어 url 변수에 저장
- request 설정을 함.
- session.rx.data를 통해 data를 받아오면 DKBlog에 저장
- 아니면 실패 반환
### 5) SearchBar & SearchBarViewModel

#### SearchBar

```Swift
 self.rx.text
  .bind(to: viewModel.queryText)
  .disposed(by: disposeBag)
```
- 타이핑 치는 것을 ViewModel로 bind 해줌

```Swift
    Observable
            .merge(
                self.rx.searchButtonClicked.asObservable(),
                searchButton.rx.tap.asObservable()
            )
            .bind(to: viewModel.searchButtonTapped)
            .disposed(by: disposeBag)
        
        viewModel.searchButtonTapped
            .asSignal()
            .emit(to: self.rx.endEditing)
            .disposed(by: disposeBag)
```
- rx 자체 기능 중 하나인 searchButtonClicked와, searchButton이 tap 된 것을 Observable로 변환 후 merge
- viewModel의 SearchButtonTapped에 bind 해줌
- SearchBarViewModel의 searchButtonTapped를 통해 rx.endEditing을 방출


#### SearchBarViewModel
```Swift
 let queryText = PublishRelay<String?>()
    let searchButtonTapped = PublishRelay<Void>()
    let shouldLoadResult: Observable<String>
    
    init() {
        self.shouldLoadResult = searchButtonTapped
            .withLatestFrom(queryText) { $1 ?? "" }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
    }
```
- queryText는 View에서 타이핑 친 것을 받아옴
- searchButtonTapped도 rx.searchButtonClicked와 searchButton.rx.tap를 받음
- shouldLoadResult 는  .withLatestFrom(queryText) 를 통해 queryText가 끝난 후 searchButtonTapped이 되도록 함
-  .filter { !$0.isEmpty } 로 빈 값은 필터링 한다.
-  .distinctUntilChanged() 로 연달아 오는 값을 막음.


### 6) MainView & MainViewModel

### MainView 
```Swift
    let listView = BlogListView()
    let searchBar = SearchBar()
```
- BlogListView와 SearchBar 저장
