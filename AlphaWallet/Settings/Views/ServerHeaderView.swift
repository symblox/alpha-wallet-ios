import UIKit

class ServerHeaderView: UIView {
    
    private var sectionLbl: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = R.color.black()
        view.textAlignment = .left
        view.font = Fonts.bold(size: 18)
        view.text = ""
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(sectionLbl)
        backgroundColor = R.color.silver()
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 40),
            sectionLbl.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 0),
            sectionLbl.bottomAnchor.constraint(equalToSystemSpacingBelow: self.bottomAnchor, multiplier: 0),
            sectionLbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            sectionLbl.trailingAnchor.constraint(equalToSystemSpacingAfter: self.trailingAnchor, multiplier: 0)
        ])
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func config(_ viewMdodel: ServerHeaderModel) {
        sectionLbl.text = viewMdodel.title
    }
}
