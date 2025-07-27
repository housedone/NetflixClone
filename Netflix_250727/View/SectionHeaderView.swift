//
//  SectionHeaderView.swift
//  Netflix_250727
//
//  Created by 김우성 on 7/27/25.
//

import UIKit
import SnapKit
import Then

class SectionHeaderView: UICollectionReusableView {
    static let id = "SectionHeader"
    
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .white
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(5)
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
