//
//  HomeViewController.swift
//  MatStar
//
//  Created by uiskim on 2022/10/12.
//  Copyright (c) 2022 Try-ing. All rights reserved.
//

import Combine
import UIKit

import CancelBag
import SnapKit
import Lottie

enum AddCourseFlowType: Int {
    // 과거에 계획을 안한경우 -> 계획,후기를 등록합니다0
    case addCourse = 0
    
    // 후기등록건드려야함
    // 과거인데 계획을 했을경우 -> 후기만 등록합니다
    // 미래인데 계획을 했을경우 -> 버튼 비활성화되어야함
    case registerReview
    
    // 수정버튼 건드려야함
    // 과거인데 계획이 되어있고 수정을 하는경우 -> 타이틀과 장소를 수정합니다0
    case editCourse
    
    // 미래인데 계획이 안되어있는 경우 -> 버튼 title을 바꿔야합니다0
    case addPlan
    
    // 수정버튼 건드려야함
    // 미래인데 계획이 되어있고 수정을 하는 경우 -> 타이틀하고 장소를 수정합니다0
    case editPlan
    
    // 이전에있던 addCourseFlowType Case
    case plan
    case record
}

final class HomeViewController: BaseViewController {
    
    var myCancelBag = Set<AnyCancellable>()
    let viewModel: HomeViewModel
    var dateInfoIsHidden: Bool = false
    var selectedDate: Date = Date()
    
    let homeTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.gmarksans(weight: .bold, size: ._20)
        label.textColor = .white
        return label
    }()
    
    lazy var alarmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "AlarmButton_notEmpty"), for: .normal)
        button.addTarget(self, action: #selector(alarmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let ddayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.gmarksans(weight: .bold, size: ._25)
        label.textColor = .white
        return label
    }()
    
    lazy var inviteMateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("메이트 초대하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: .bold)
        button.layer.borderWidth = 1
        button.layer.borderColor = .designSystem(.mainYellow)
        button.setTitleColor(.designSystem(.mainYellow), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let nextDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.gmarksans(weight: .light, size: ._13)
        label.text = "⭐️ 포항데이트 D-3"
        label.textColor = .white
        return label
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "MoreButtonForOpen"), for: .normal)
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var dateTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DateTableViewCell.self, forCellReuseIdentifier: DateTableViewCell.cellId)
        tableView.rowHeight = 20
        tableView.isHidden = true
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        tableView.separatorStyle = .none
        tableView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        tableView.layer.borderWidth = 0.5
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundView = blurEffectView
        return tableView
    }()
    
    lazy var calendarView = CalendarView(today: .init(), frame: .init(origin: .zero, size: .init(width: DeviceInfo.screenWidth - 40, height: 0)))
    
    lazy var dateCoureRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .designSystem(.mainYellow)
        button.backgroundColor = .designSystem(.mainYellow)?.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(registerButtonTapped(_:)), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        button.layer.borderWidth = 0.3
        button.setPreferredSymbolConfiguration(.init(pointSize: 16), forImageIn: .normal)
        button.setTitleColor(.designSystem(.mainYellow), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        return button
    }()
    
    let pathTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PathTableViewCell.self, forCellReuseIdentifier: PathTableViewCell.cellId)
        tableView.register(PathTableHeader.self, forHeaderFooterViewReuseIdentifier: PathTableHeader.cellId)
        tableView.register(PathTableFooter.self, forHeaderFooterViewReuseIdentifier: PathTableFooter.cellId)
        tableView.rowHeight = 59
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 15
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .designSystem(.mainYellow)?.withAlphaComponent(0.2)
        tableView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        tableView.layer.borderWidth = 0.3
        return tableView
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// View Model과 bind 합니다.
    private func bind() {
        // input
        
        // output
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedValue in
                guard let self = self else { return }
                if receivedValue?.mate != nil {
                    self.setHasMateUI()
                } else {
                    self.setNoMateUI()
                }
            }
            .store(in: &myCancelBag)
        
        viewModel.$dateCalendarList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedValue in
                guard let self = self else { return }
                self.calendarView.scheduleList = receivedValue
            }
            .store(in: &myCancelBag)
        
        viewModel.$dateCourse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] receivedValue in
                guard let self = self else { return }
                guard let receivedValue = receivedValue else { return }
                self.pathTableView.isHidden = false
                self.pathTableView.snp.makeConstraints { make in
                    make.top.equalTo(self.calendarView.snp.bottom).offset(10)
                    make.centerX.equalToSuperview()
                    make.leading.trailing.equalToSuperview().inset(20)
                    // MARK: - 하나의 cell높이(59), Header의 높이 43, Footer의 높이(60)에서 자연스럽게 10추가
                    make.height.equalTo(receivedValue.courseList.count * 59 + 43 + 70)
                }
                self.pathTableView.reloadData()
            }
            .store(in: &myCancelBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, touch.view == self.backgroundView {
            self.dateInfoIsHidden = false
            self.moreButton.setImage(UIImage(named: "MoreButtonForOpen"), for: .normal)
            self.dateTableView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
        Task {
            let currentDateRange = getCurrentDateRange()
            try await viewModel.fetchUserInfo()
            try await viewModel.fetchDateRange(dateRange: currentDateRange)
            try await viewModel.fetchSelectedDateCourse(selectedDate: Date.currentDateString)
            if viewModel.hasCourse(selectedDate: Date.currentDateString) {
                try await viewModel.fetchSelectedDateCourse(selectedDate: Date.currentDateString)
                self.dateCoureRegisterButton.isHidden = true
            } else {
                setRegisterButton(.addCourse)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setAttributes()
        setUI()
    }
    
    private func setNoMateUI() {
        guard let user = self.viewModel.user else { return }
        self.homeTitle.attributedText = String.makeAtrributedString(
            name: user.me.name,
            appendString: " 님 반갑습니다",
            changeAppendStringSize: ._15,
            changeAppendStringWieght: .light,
            changeAppendStringColor: .white
        )
        
        self.view.addSubviews(self.inviteMateButton)
        self.inviteMateButton.snp.makeConstraints { make in
            make.leading.equalTo(self.homeTitle.snp.leading)
            make.top.equalTo(self.homeTitle.snp.bottom).offset(5)
            make.width.equalTo(90)
            make.height.equalTo(25)
        }
        
        self.nextDateLabel.snp.remakeConstraints { make in
            make.top.equalTo(self.inviteMateButton.snp.bottom).offset(10)
            make.leading.equalTo(self.homeTitle.snp.leading)
            make.height.equalTo(15)
        }
        
        self.ddayLabel.isHidden = true
        self.inviteMateButton.isHidden = false
    }
    
    private func setHasMateUI() {
        guard let userMate = self.viewModel.user?.mate else { return }
        guard let dday = self.viewModel.user?.planet?.dday else { return }
        self.homeTitle.attributedText = String.makeAtrributedString(
            name: userMate.name,
            appendString: " 님과 함께",
            changeAppendStringSize: ._15,
            changeAppendStringWieght: .light,
            changeAppendStringColor: .white
        )
        
        self.ddayLabel.isHidden = false
        self.inviteMateButton.isHidden = true
        self.ddayLabel.text = "D+\(dday)"
    }
    
    @objc
    func alarmButtonTapped() {
        print("알람버튼이눌렸습니다")
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backButtonItem.tintColor = .designSystem(.white)
        let nextVC = UserWarningViewController(outgoingType: .membershipWithdrawal)
        navigationController?.pushViewController(nextVC, animated: true)
        navigationItem.backBarButtonItem = backButtonItem
        
    }
    
    @objc
    func moreButtonTapped() {
        dateInfoIsHidden.toggle()
        dateTableView.isHidden.toggle()
        moreButton.setImage(dateInfoIsHidden ? UIImage(named: "MoreButtonForClose") : UIImage(named: "MoreButtonForOpen"), for: .normal)
    }
    
    @objc
    func inviteButtonTapped() {
        print("초대하기 버튼이 눌렸습니다")
    }
    
    @objc
    func registerButtonTapped(_ sender: UIButton) {
        guard let type = AddCourseFlowType(rawValue: sender.tag) else { return }
        viewModel.startAddCourseFlow(type: type)
    }
}

// MARK: - UI
extension HomeViewController {
    func setAttributes() {
        view.addSubview(homeTitle)
        view.addSubview(alarmButton)
        view.addSubview(ddayLabel)
        view.addSubview(nextDateLabel)
        view.addSubview(moreButton)
        view.addSubview(pathTableView)
        view.addSubview(calendarView)
        // MARK: - DateTableView가 맨위에 있어야 Layer가 가장 위쪽으로 적용이 된다
        view.addSubview(dateTableView)
        view.addSubview(dateCoureRegisterButton)
        dateTableView.dataSource = self
        pathTableView.delegate = self
        pathTableView.dataSource = self
        calendarView.delegate = self
        
    }
    
    func setUI() {
        homeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(70)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(200)
            make.height.equalTo(25)
        }
        
        alarmButton.snp.makeConstraints { make in
            make.top.equalTo(homeTitle.snp.top)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(32)
        }
        
        ddayLabel.snp.makeConstraints { make in
            make.top.equalTo(homeTitle.snp.bottom).offset(5)
            make.leading.equalTo(homeTitle.snp.leading)
        }
        
        nextDateLabel.snp.makeConstraints { make in
            make.top.equalTo(ddayLabel.snp.bottom).offset(10)
            make.leading.equalTo(homeTitle.snp.leading)
            make.height.equalTo(15)
        }
        
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(nextDateLabel.snp.centerY)
            make.leading.equalTo(nextDateLabel.snp.trailing).offset(5)
            make.size.equalTo(16)
        }
        
        dateTableView.snp.makeConstraints { make in
            make.leading.equalTo(homeTitle.snp.leading)
            make.top.equalTo(nextDateLabel.snp.bottom).offset(5)
            make.width.equalTo(150)
            make.height.equalTo(viewModel.ddayDateList.count * 20 + 30)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(nextDateLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        dateCoureRegisterButton.snp.makeConstraints { make in
            make.top.equalTo(calendarView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(58)
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = (tableView == dateTableView ? viewModel.ddayDateList.count : viewModel.dateCourse?.courseList.count)
        guard let sectionCount = sectionCount else { return 0 }
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == dateTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.cellId, for: indexPath) as? DateTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.dateData = viewModel.ddayDateList[indexPath.row]
            return cell
        } else if tableView == pathTableView {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PathTableViewCell.cellId, for: indexPath) as? PathTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            guard let course = viewModel.dateCourse else { return UITableViewCell() }
            switch indexPath.row {
            case 0:
                cell.lineUpper.isHidden = true
                // MARK: - 코스가 하나일때 분기처리
                if course.courseList.count == 1 {
                    cell.lineLower.isHidden = true
                }
            case course.courseList.index(before: course.courseList.endIndex):
                cell.lineLower.isHidden = true
            default:
                cell.lineLower.isHidden = false
                cell.lineUpper.isHidden = false
            }
            cell.data = viewModel.dateCourse?.courseList[indexPath.row]
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == pathTableView {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PathTableHeader.cellId) as? PathTableHeader else { return UIView() }
            header.title.text = viewModel.dateCourse?.courseTitle
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight = 43.0
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == pathTableView {
            guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: PathTableFooter.cellId) as? PathTableFooter else { return UIView() }
            footer.delegate = self
            return footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let footerHeight = 60.0
        return footerHeight
    }
}

extension HomeViewController: ActionSheetDelegate {
    func presentModifyViewController() {
        viewModel.startAddCourseFlow(type: self.selectedDate > Date() ? .editPlan : .editCourse)
    }
    
    func presentRegisterReviewViewController() {
        if self.selectedDate > Date() {
            let alert = UIAlertController(title: "안내", message: "미래의 계획은 후기를 등록할 수 없습니다", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "알겠습니다", style: .default)
            alert.addAction(okAction)
            present(alert, animated: false, completion: nil)
        } else {
            viewModel.startAddCourseFlow(type: .registerReview)
        }
    }

    func showPathActionSheet(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    func showSettingActionSheet(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}

extension HomeViewController: CalendarViewDelegate {
    func changeCalendarPage(startDate: String, endDate: String) {
        Task {
            try await viewModel.fetchDateRange(dateRange: [startDate, endDate])
        }
    }
    
    func switchCalendarButtonDidTapped() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 캘린더에서 특정날짜를 누르면 그 날짜를 input으로 넣어주는 delegate함수
    /// - Parameter date: 내가 누른 날짜
    func selectDate(_ date: Date?) {
        guard let date = date else { return }
        self.selectedDate = date
        let selectedDate = date.dateToString()
        Task {
            // MARK: - 내가 누른 날짜가 처음에 조회한 데이트가 존재하는 날짜에 포함되어있는지를 판단
            // 데이트가 존재하지 않는날짜를 누르면 api자체를 호출하지 않게끔 하기 위한 분기처리 - 서버에서 데이터를 안주게 처리
            if viewModel.hasCourse(selectedDate: selectedDate) {
                try await viewModel.fetchSelectedDateCourse(selectedDate: selectedDate)
                self.dateCoureRegisterButton.isHidden = true
            } else {
                setRegisterButton(date > Date() ? .addPlan : .addCourse)
            }
        }
    }

    func scrollViewDidEndDecelerating() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 데이트가 없다면 데이트추가하기 버튼을 보여주는 분기처리 함수
    private func setRegisterButton(_ type: AddCourseFlowType) {
        switch type {
        case .addCourse:
            dateCoureRegisterButton.setTitle(" 별자리 등록하기", for: .normal)
            dateCoureRegisterButton.tag = 0
        case .addPlan:
            dateCoureRegisterButton.setTitle(" 데이트코스 계획하기", for: .normal)
            dateCoureRegisterButton.tag = 3
        default:
            break
        }

        self.dateCoureRegisterButton.isHidden = false
        self.pathTableView.isHidden = true
    }

    private func getCurrentDateRange() -> [String] {
        let currentDate = Date()
        let beforeDate = Date().monthBefore
        let nextDate = currentDate.month2After
        let beforeDateString = beforeDate.dateToString()
        let afterDateString = nextDate.dateToString()
        return [beforeDateString, afterDateString]
    }
}
