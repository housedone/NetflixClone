//
//  MainViewController.swift
//  Netflix_250727
//
//  Created by 김우성 on 7/27/25.
//

import UIKit
import SnapKit
import RxSwift
import AVKit
import YouTubeiOSPlayerHelper
import Then

enum Section: Int, CaseIterable {
    case popularMovies
    case topRatedMovies
    case popularTVShows
    
    var title: String {
        switch self {
        case .popularMovies:
            return "이 시간 핫한 영화"
        case .topRatedMovies:
            return "가장 평점이 높은 영화"
        case .popularTVShows:
            return "인기 TV 프로그램"
        }
    }
}

class MainViewController: UIViewController {
    
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainViewModel()
    
    private var popularMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var popularTVShows = [Movie]()
    
    private let label = UILabel().then {
        $0.text = "NETFLIX"
        $0.textColor = UIColor(red: 229/255, green: 9/255, blue: 20/255, alpha: 1.0)
        $0.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        $0.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = .black
    }
    
    // 코드로 초기화할 수 있도록 추가
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController")
        
        bind()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.popularMovieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.popularMovies = movies
                self?.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        viewModel.topRatedMovieSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.topRatedMovies = movies
                self?.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
        
        viewModel.popularTvShowSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] movies in
                self?.popularTVShows = movies
                self?.collectionView.reloadData()
            }, onError: { error in
                print("에러 발생: \(error)")
            }).disposed(by: disposeBag)
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        view.addSubview(label)
        view.addSubview(collectionView)
        
        label.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // 각 아이템은 각 그룹 내에서 전체 너비와 높이를 차지. (1.0 = 100%).
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 각 그룹은 화면 너비의 40%를 차지하고, 높이는 너비의 60%.
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .fractionalWidth(0.4)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        /*
         섹션은 연속적인 수평 스크롤이 가능.
         그룹 간 간격은 10포인트.
         섹션의 모든 면에 10포인트의 여백 존재. bottom 은 20.
         */
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)
        
        /*
         헤더는 섹션의 전체 너비를 차지하고, 높이는 예상값 44포인트.
         헤더는 섹션의 상단에 배치됩니다.
         */
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    /// 해당 URL 의 비디오를 재생하는 함수. 임의의 url 을 넣어서 연습합니다.
    private func playVideoUrl(url: URL) {
        
        // url 을 인자로 받지만, 유튜브 url 은 정책상 바로 재생할 수 없으므로
        // 임의의 url 을 넣어서 동영상 재생의 구현만 연습해봅니다.
        let url = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
        // URL 을 AVPlayer 객체에 담음.
        let player = AVPlayer(url: url)
        // AVPlayerViewController 선언.
        let playerViewController = AVPlayerViewController()
        // AVPlayerViewController 의 player 에 위에서 선언한 player 세팅.
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    // 셀이 클릭 되었을 때 실행할 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch Section(rawValue: indexPath.section) {
        case .popularMovies:
            viewModel.fetchTrailerKey(movie: popularMovies[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] key in
                    // 만약 유효한 url 을 서버로부터 받았을 경우 이 url 을 그대로 사용했을 것입니다.
                    //                     let url = URL(string: "https://www.youtube.com/watch?v=\(key)")!
                    //                     self?.playVideoUrl(url: url)
                    self?.navigationController?.pushViewController(YouTubePlayerViewController(key: key), animated: true)
                }, onFailure: { error in
                    print("에러 발생: \(error)")
                }).disposed(by: disposeBag)
            
        case .topRatedMovies:
            viewModel.fetchTrailerKey(movie: topRatedMovies[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] key in
                    self?.navigationController?.pushViewController(YouTubePlayerViewController(key: key), animated: true)
                }, onFailure: { error in
                    print("에러 발생: \(error)")
                }).disposed(by: disposeBag)
            
        case .popularTVShows:
            viewModel.fetchTrailerKey(movie: popularTVShows[indexPath.row])
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] key in
                    self?.navigationController?.pushViewController(YouTubePlayerViewController(key: key), animated: true)
                }, onFailure: { error in
                    print("에러 발생: \(error)")
                }).disposed(by: disposeBag)
            
        case .none:
            break
        }
        
    }
}

extension MainViewController: UICollectionViewDataSource {
    // 섹션 별로 item 이 몇 개인지 지정하는 메서드.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .popularMovies: return popularMovies.count
        case .topRatedMovies: return topRatedMovies.count
        case .popularTVShows: return popularTVShows.count
        case .none: return 5
        }
    }
    
    // indexPath 별로 cell 을 구현한다.
    // tableView 의 cellForRowAt 과 비슷한 역할.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.id, for: indexPath) as? PosterCell else {
            return UICollectionViewCell()
        }
        
        switch Section(rawValue: indexPath.section) {
        case .popularMovies:
            cell.configure(with: popularMovies[indexPath.row])
        case .topRatedMovies:
            cell.configure(with: topRatedMovies[indexPath.row])
        case .popularTVShows:
            cell.configure(with: popularTVShows[indexPath.row])
        case .none:
            break
        }
        return cell
    }
    
    // indexPath 별로 supplemenatryView 를 구현한다.
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        // 헤더인 경우에만 구현.
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.id,
            for: indexPath
        ) as? SectionHeaderView else { return UICollectionReusableView() }
        
        let sectionType = Section.allCases[indexPath.section]
        headerView.configure(with: sectionType.title)
        
        return headerView
    }
    
    // collectionView 의 섹션이 몇개인지 설정하는 메서드.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
}

class YouTubeExtractor {
    static func extractVideoURL(youtubeURL: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: youtubeURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let htmlString = String(data: data!, encoding: .utf8) else {
                completion(.failure(NSError(domain: "Invalid data", code: -1, userInfo: nil)))
                return
            }
            
            // 정규표현식을 사용하여 "url_encoded_fmt_stream_map" 파라미터를 찾습니다.
            let pattern = "\"url_encoded_fmt_stream_map\":\"([^\"]*)\""
            guard let range = htmlString.range(of: pattern, options: .regularExpression) else {
                completion(.failure(NSError(domain: "URL not found", code: -1, userInfo: nil)))
                return
            }
            
            let matched = htmlString[range]
            let urlEncodedString = String(matched.split(separator: ":")[1]).replacingOccurrences(of: "\"", with: "")
            
            // URL 디코딩
            let decodedString = urlEncodedString.removingPercentEncoding ?? urlEncodedString
            
            // 첫 번째 URL 추출
            let components = decodedString.components(separatedBy: ",")
            guard let firstComponent = components.first,
                  let urlString = firstComponent.components(separatedBy: "&").first(where: { $0.contains("url=") })?.replacingOccurrences(of: "url=", with: ""),
                  let videoURL = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid video URL", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(videoURL))
        }
        task.resume()
    }
}

