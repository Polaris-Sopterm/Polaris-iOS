//
//  LookBackViewModel.swift
//  polaris-ios
//
//  Created by Yunjae Kim on 2021/12/28.
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import MapKit

struct LookBackTitle {
    var text: String
    var highlightedText: String
}


final class LookBackViewModel {
    
    @Published var page: Int = 0
    
    @Published var firstvcStars: [LookBackStar] = []
    
    @Published var secondvcStars: [LookBackStar] = []
    @Published var secondvcNextButtonAble: Bool = false
    @Published var secondvcTitle: LookBackTitle = LookBackTitle(text: "당신 마음에\n가장 가까이 닿은 별은 어떤 별인가요?",
                                                                highlightedText: "가장 가까이 닿은 별")
    @Published var secondvcAnswerInfo: [[String]] = []
    @Published var secondvcPhase: Int = 0 {
        didSet {
            self.secondvcCheckNextButtonEnabled()
        }
    }
    
    @Published var thirdvcPhase: Int = 0
    @Published var thirdvcAnswerInfo: [Int] = []
    @Published var thirdvcImageNameInfo: String = "lookBack3Illust00"
    @Published var thirdvcTitle: LookBackTitle = LookBackTitle(text: "한 주 동안 당신만을 위한 시간을\n얼마나 보냈나요?",
                                                               highlightedText: "당신만을 위한 시간")
    
    @Published var fourthvcEmotions: [LookBackEmotion] = []
    @Published var fourthvcNextButtonAble: Bool = false
    
    
    @Published var fifthvcReason: [String] = []
    @Published var fifthVCNextButtonAble: Bool = false
    
    @Published var sixthvcStars: [LookBackStar] = []
    @Published var sixthvcNextButtonAble: Bool = false
    
    @Published var lookbackEnd: Bool = false
    
    private var disposeBag = DisposeBag()
    
    private var firstVCStarInfo = [LookBackStar(starName: "건강", starImageName: "imgChangeAdd", selected: false),
                                   LookBackStar(starName: "극복", starImageName: "imgOvercomeAdd", selected: false),
                                   LookBackStar(starName: "절제", starImageName: "imgControlAdd", selected: false),
                                   LookBackStar(starName: "변화", starImageName: "imgGrowthAdd", selected: false),
                                   LookBackStar(starName: "도전", starImageName: "imgChallengeAdd", selected: false),
                                   LookBackStar(starName: "감사", starImageName: "imgThanksAdd", selected: false),
                                   LookBackStar(starName: "행복", starImageName: "imgHappinessAdd", selected: false),
                                   LookBackStar(starName: "휴식", starImageName: "imgRestAdd", selected: false),
                                   LookBackStar(starName: "성장", starImageName: "imgHealthAdd", selected: false),
    ]
    
    private var secondVCStarInfo1 = [LookBackStar(starName: "행복", starImageName: "imgHappinessLookBack", selected: false),
                                     LookBackStar(starName: "절제", starImageName: "imgControlLookBack", selected: false),
                                     LookBackStar(starName: "감사", starImageName: "imgThanksLookBack", selected: false),
                                     LookBackStar(starName: "휴식", starImageName: "imgRestLookBack", selected: false),
                                     LookBackStar(starName: "성장", starImageName: "imgHealthLookBack", selected: false),
                                     LookBackStar(starName: "변화", starImageName: "imgGrowthLookBack", selected: false),
                                     LookBackStar(starName: "건강", starImageName: "imgChangeLookBack", selected: false),
                                     LookBackStar(starName: "극복", starImageName: "imgOvercomeLookBack", selected: false),
                                     LookBackStar(starName: "도전", starImageName: "imgChallengeLookBack", selected: false),
    ]
    
    private var secondVCStarInfo2 = [LookBackStar(starName: "행복", starImageName: "imgHappinessLookBack", selected: false),
                                     LookBackStar(starName: "절제", starImageName: "imgControlLookBack", selected: false),
                                     LookBackStar(starName: "감사", starImageName: "imgThanksLookBack", selected: false),
                                     LookBackStar(starName: "휴식", starImageName: "imgRestLookBack", selected: false),
                                     LookBackStar(starName: "성장", starImageName: "imgHealthLookBack", selected: false),
                                     LookBackStar(starName: "변화", starImageName: "imgGrowthLookBack", selected: false),
                                     LookBackStar(starName: "건강", starImageName: "imgChangeLookBack", selected: false),
                                     LookBackStar(starName: "극복", starImageName: "imgOvercomeLookBack", selected: false),
                                     LookBackStar(starName: "도전", starImageName: "imgChallengeLookBack", selected: false),
    ]
    
    private var secondvcTitles: [LookBackTitle] = [LookBackTitle(text: "당신 마음에\n가장 가까이 닿은 별은 어떤 별인가요?",
                                                                 highlightedText: "가장 가까이 닿은 별"),
                                                   LookBackTitle(text: "당신 마음에\n와닿지 않은 별은 어떤 별인가요? ",
                                                                 highlightedText: "와닿지 않은 별"),
    ]
    
    
    private var sixthVCStarInfo = [LookBackStar(starName: "행복", starImageName: "imgHappinessLookBack", selected: false),
                                   LookBackStar(starName: "절제", starImageName: "imgControlLookBack", selected: false),
                                   LookBackStar(starName: "감사", starImageName: "imgThanksLookBack", selected: false),
                                   LookBackStar(starName: "휴식", starImageName: "imgRestLookBack", selected: false),
                                   LookBackStar(starName: "성장", starImageName: "imgHealthLookBack", selected: false),
                                   LookBackStar(starName: "변화", starImageName: "imgGrowthLookBack", selected: false),
                                   LookBackStar(starName: "건강", starImageName: "imgChangeLookBack", selected: false),
                                   LookBackStar(starName: "극복", starImageName: "imgOvercomeLookBack", selected: false),
                                   LookBackStar(starName: "도전", starImageName: "imgChallengeLookBack", selected: false),
    ]
    
    private var thirdvcAnswers: [Int] = [0]
    private var thirdvcImageNames: [String] = ["lookBack3Illust00"]
    private var thirdvcTitles: [LookBackTitle] = [LookBackTitle(text: "한 주 동안 당신만을 위한 시간을\n얼마나 보냈나요?",
                                                                highlightedText: "당신만을 위한 시간"),
                                                  LookBackTitle(text: "한 주 동안 일상 속에서\n웃음지었던 순간이 얼마나 있었나요?",
                                                                highlightedText: "웃음지었던 순간"),
                                                  LookBackTitle(text: "한 주 동안 스스로 다짐한 것들을\n얼마나 지켜나갔나요?",
                                                                highlightedText: "스스로 다짐한 것들"),
                                                  LookBackTitle(text: "한 주 동안\n얼마나 더 나은 당신을 만들어갔나요?",
                                                                highlightedText: "더 나은 당신"),
    ]
    
    private var fourthVCEmotionInfo = [LookBackEmotion(emotion: "편안", emotionImageName: "emotionComfortableSelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "불편", emotionImageName: "emotionInconvenientSelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "기대", emotionImageName: "emotionExpectationSelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "답답", emotionImageName: "emotionFrustratedSelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "무난", emotionImageName: "emotionEasySelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "기쁨", emotionImageName: "emotionJoySelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "화남", emotionImageName: "emotionAngrySelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "아쉬움", emotionImageName: "emotionRegretfulSelectionUnselected", isSelected: false),
                                       LookBackEmotion(emotion: "만족", emotionImageName: "emotionSatisfactionSelectionUnselected", isSelected: false),
                                       
    ]
    
    private var fifthvcReasonInfo: [String] = []
    
    func toNextPage() {
        guard self.page < 5 else { return }
        self.page = self.page + 1
    }
    
    func toPreviousPage() {
        guard self.page > 0 else { return }
        switch self.page {
        case 1:
            self.secondvcPrevPageButton()
        case 2:
            self.thirdvcPrevButtonTapped()
        default:
            self.page = self.page - 1
        }
    }
    
    func publishFirstStarInfos() {
        self.firstvcStars = self.firstVCStarInfo
    }
    
    func publishSecondStarInfos() {
        if self.secondvcPhase == 0 {
            self.secondvcStars = self.secondVCStarInfo1
        }
        else {
            self.secondvcStars = self.secondVCStarInfo2
        }
    }
    
    func setStarSelectedSecondVC(index: Int) {
        if self.secondvcPhase == 0 {
            self.secondVCStarInfo1[index].selected = !self.secondVCStarInfo1[index].selected
            self.publishSecondStarInfos()
            self.secondvcCheckNextButtonEnabled()
        }
        else {
            self.secondVCStarInfo2[index].selected = !self.secondVCStarInfo2[index].selected
            self.publishSecondStarInfos()
            self.secondvcCheckNextButtonEnabled()
        }
    }
    
    func secondvcCheckNextButtonEnabled() {
        var starInfoList = self.secondVCStarInfo1
        if self.secondvcPhase == 1 {
            starInfoList = self.secondVCStarInfo2
        }
        for star in starInfoList {
            if star.selected {
                self.secondvcNextButtonAble = true
                return
            }
        }
        self.secondvcNextButtonAble = false
    }
    
    func secondvcNextButtonTapped() {
        self.secondvcAddAnswer()
        if self.secondvcPhase == 1 {
            self.toNextPage()
        }
        else {
            self.secondvcPhase = 1
            self.secondvcTitle = self.secondvcTitles[1]
            self.secondvcStars = self.secondVCStarInfo2
        }
    }
    
    func secondvcAddAnswer() {
        var answers: [String] = []
        if self.secondvcPhase == 0 {
            for star in self.secondVCStarInfo1 {
                if star.selected {
                    answers.append(star.starName)
                }
            }
            self.secondvcAnswerInfo.append(answers)
        }
        else {
            for star in self.secondVCStarInfo2 {
                if star.selected {
                    answers.append(star.starName)
                }
            }
            self.secondvcAnswerInfo.append(answers)
        }
    }
    
    func secondvcPrevPageButton() {
        if self.secondvcPhase == 0 {
            self.page = self.page - 1
        }
        else {
            self.secondvcPhase = 0
            self.secondvcCheckNextButtonEnabled()
            self.secondvcTitle = self.secondvcTitles[0]
            self.secondvcStars = self.secondVCStarInfo1
        }
    }
    
    func thirdvcAnswerChange(value: Int) {
        guard thirdvcAnswers[self.thirdvcPhase] != value else { return }
        self.thirdvcAnswers[self.thirdvcPhase] = value
        self.thirdvcImageNames[self.thirdvcPhase] = self.makeBackgroundImageName(value: value)
        self.publishThirdVCInfos()
    }
    
    func publishThirdVCInfos() {
        self.thirdvcAnswerInfo = self.thirdvcAnswers
        self.thirdvcImageNameInfo = self.thirdvcImageNames[self.thirdvcPhase]
        self.thirdvcTitle = self.thirdvcTitles[self.thirdvcPhase]
    }
    
    func thirdvcNextButtonTapped() {
        if self.thirdvcPhase >= 3 {
            self.toNextPage()
        }
        else {
            self.thirdvcPhase += 1
            if self.thirdvcPhase >= self.thirdvcAnswers.count {
                self.thirdvcAnswers.append(0)
                self.thirdvcImageNames.append(makeBackgroundImageName(value: 0))
            }
            self.publishThirdVCInfos()
        }
    }
    
    func thirdvcPrevButtonTapped() {
        if self.thirdvcPhase == 0 {
            self.page = self.page - 1
        }
        else {
            self.thirdvcPhase -= 1
            self.publishThirdVCInfos()
        }
    }
    
    func setEmotionSelectedFourthVC(index: Int) {
        self.fourthVCEmotionInfo[index].isSelected = !self.fourthVCEmotionInfo[index].isSelected
        if self.fourthVCEmotionInfo[index].isSelected {
            self.fourthVCEmotionInfo[index].emotionImageName = self.fourthVCEmotionInfo[index].emotionImageName.replacingOccurrences(of: "Unselected", with: "Selected")
        }
        else {
            self.fourthVCEmotionInfo[index].emotionImageName = self.fourthVCEmotionInfo[index].emotionImageName.replacingOccurrences(of: "Selected", with: "Unselected")
        }
        
        self.publishFourthEmotionInfo()
        for emotion in self.fourthVCEmotionInfo {
            if emotion.isSelected {
                self.fourthvcNextButtonAble = true
                return
            }
        }
        self.fourthvcNextButtonAble = false
    }
    
    func publishFourthEmotionInfo() {
        self.fourthvcEmotions = self.fourthVCEmotionInfo
    }
    
    private func makeBackgroundImageName(value: Int) -> String {
        return "lookBack3Illust" + String(self.thirdvcPhase) + String(value)
    }
    
    func publishFifthReasonInfo() {
        if self.fifthvcReasonInfo.isEmpty {
            self.fifthVCNextButtonAble = false
        }
        else {
            self.fifthVCNextButtonAble = true
        }
        self.fifthvcReason = self.fifthvcReasonInfo
    }
    
    func addFifthvcReason(reason: String) {
        self.fifthvcReasonInfo.append(reason)
        self.publishFifthReasonInfo()
    }
    
    func removeFifthvcReason(removeReason: String) {
        for (idx, reason) in self.fifthvcReasonInfo.enumerated() {
            if reason == removeReason {
                self.fifthvcReasonInfo.remove(at: idx)
                break
            }
        }
        self.publishFifthReasonInfo()
    }
    
    
    func publishSixthStarInfo() {
        self.sixthvcStars = self.sixthVCStarInfo
    }
    
    func setStarSelectedSixthVC(index: Int) {
        self.sixthVCStarInfo[index].selected = !self.sixthVCStarInfo[index].selected
        self.publishSixthStarInfo()
        for star in self.sixthVCStarInfo {
            if star.selected {
                self.sixthvcNextButtonAble = true
                return
            }
        }
        self.sixthvcNextButtonAble = false
    }
    
    func getSelectedStars(starList: [LookBackStar]) -> [String] {
        var result: [String] = []
        for star in starList {
            if star.selected {
                result.append(star.starName)
            }
        }
        return result
    }
    
    func getSelectedEmotions(emotionList: [LookBackEmotion]) -> [String] {
        var result: [String] = []
        for emotion in emotionList {
            if emotion.isSelected {
                result.append(emotion.emotion)
            }
        }
        return result
    }
    
    func makeRecordInfo() -> [String?] {
        var result: [String?] = []
        if self.fifthvcReasonInfo.count == 0 {
            result = [nil, nil, nil]
        }
        else {
            for idx in 0..<3 {
                if idx < self.fifthvcReasonInfo.count {
                    result.append(self.fifthvcReasonInfo[idx])
                }
                else {
                    result.append(nil)
                }
            }
        }
        return result
    }
    
    func registerLookBackResult() {
        guard self.thirdvcAnswerInfo.count == 4 else { return }
        
        
        
        let resultValue = RetrospectValueModel(y: self.getSelectedStars(starList: self.secondVCStarInfo1),
                                             n: self.getSelectedStars(starList: self.secondVCStarInfo2),
                                             health: self.thirdvcAnswerInfo[0],
                                             happy: self.thirdvcAnswerInfo[1],
                                             challenge: self.thirdvcAnswerInfo[2],
                                             moderation: self.thirdvcAnswerInfo[3],
                                             emoticon: self.getSelectedEmotions(emotionList: self.fourthVCEmotionInfo),
                                             need: self.getSelectedStars(starList: self.sixthVCStarInfo)
        )
        
        let recordInfo = self.makeRecordInfo()
        
        let weekAPI = WeekAPI.getWeekNo(date: Date.normalizedCurrent)
        
        NetworkManager.request(apiType: weekAPI)
            .asObservable()
            .map { (weekModel: WeekResponseModel) -> RetrospectModel in
                let resultModel = RetrospectModel(year: Date.currentYear, month: Date.currentMonth, weekNo: weekModel.weekNo, value: resultValue, record1: recordInfo[0], record2: recordInfo[1], record3: recordInfo[2])
                return resultModel
            }
            .flatMapLatest { resultModel -> Observable<RetrospectResponseModel> in
                let registAPI = RetrospectAPI.create(model: resultModel)
                return NetworkManager.request(apiType: registAPI).asObservable()
            }
            .subscribe(onNext: { [weak self] (responseModel: RetrospectResponseModel) in
                PolarisToastManager.shared.showToast(with: "회고 등록이 완료되었어요")
                self?.lookbackEnd = true
            }, onError: { [weak self] error in
                if let polarisError = error as? PolarisErrorModel.PolarisError {
                    PolarisToastManager.shared.showToast(with: polarisError.message)
                }
                else {
                    PolarisToastManager.shared.showToast(with: "회고 등록이 완료되었어요")
                    
                }
                self?.lookbackEnd = true
            })
            .disposed(by: self.disposeBag)
        
    }
    
}
