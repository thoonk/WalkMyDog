//
//  WalkStartCountViewController.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/07/07.
//

import UIKit
import RxSwift

final class WalkStartCountViewController: UIViewController {
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "walkStartCountImage")
        
        return imageView
    }()
    
    lazy var countLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "NanumSquareRoundB", size: 40.0) ?? UIFont.systemFont(ofSize: 40.0)
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        label.text = "3"

        return label
    }()
    
    lazy var puppyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
                
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        
        collectionView.register(WalkPuppyCollectionViewCell.self, forCellWithReuseIdentifier: WalkPuppyCollectionViewCell.identifier)

        return collectionView
    }()
    
    private let selectedPuppies: [Puppy]
    private let imageService: ImageServiceProtocol
    var viewModel: WalkStartCountViewModel?
    var bag = DisposeBag()

    required init(
        selectedPuppies: [Puppy],
        imageService: ImageServiceProtocol = ImageService()
    ) {
        self.selectedPuppies = selectedPuppies
        self.imageService = imageService
        
        super.init(nibName: nil, bundle: nil)
        
        setupLayout()
        setupBinding()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        bag = DisposeBag()
    }
}

private extension WalkStartCountViewController {
    func setupLayout() {
        [
            backgroundImageView,
            countLabel,
            puppyCollectionView
        ].forEach { view.addSubview($0) }
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        let collectionViewWidth: CGFloat = 100.0 * CGFloat(self.selectedPuppies.count)
        
        if collectionViewWidth > self.view.bounds.size.width - 40 {
            puppyCollectionView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(20.0)
            }
        } else{
            puppyCollectionView.snp.makeConstraints {
                $0.top.equalTo(countLabel.snp.bottom).offset(30.0)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(self.view.frame.width - 40.0)
                $0.height.equalTo(100.0)
            }
        }
    }
    
    func setupBinding() {
        self.viewModel = WalkStartCountViewModel(selectedPuppies: self.selectedPuppies)
        let output = viewModel!.output
        
        output.timerCount
            .subscribe(onNext: { [weak self] currentTime in
                self?.countLabel.text = "\(currentTime)"
            })
            .disposed(by: bag)
        
        output.presentToWalk
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: {
                    let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as? SceneDelegate
                    
                    if let walkReadyViewController = self?.topViewController(base: sceneDelegate?.window!.rootViewController) as? WalkReadyViewController {
                        
                        let walkViewController = WalkViewController(selectedPuppies:  self?.selectedPuppies ?? [])
                        walkViewController.modalPresentationStyle = .fullScreen
                        
                        walkReadyViewController.present(walkViewController, animated: true)
                    }
                })
            })
            .disposed(by: bag)
    }
    
    func topViewController(base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension WalkStartCountViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.height
        
        return CGSize(width: size, height: size)
    }
}
