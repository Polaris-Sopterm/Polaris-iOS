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
    @Published var secondvcPhase: Int = 0
    
    @Published var thirdvcAnswerInfo: [Int] = []
    @Published var thirdvcImageNameInfo: [String] = []
    @Published var thirdvcTitle: LookBackTitle = LookBackTitle(text: "한 주 동안 당신만을 위한 시간을\n얼마나 보냈나요?",
                                                               highlightedText: "당신만을 위한 시간")
    
    @Published var fourthvcEmotions: [LookBackEmotion] = []
    @Published var fourthvcNextButtonAble: Bool = false
    
    
    @Published var fifthvcReason: [String] = []
    
    @Published var sixthvcStars: [LookBackStar] = []
    @Published var sixthvcNextButtonAble: Bool = false
    
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
    
    private let starEnumDict: [String: LookBackStarEnum] = ["행복":.HAPPINESS, "절제":.CONTROL, "감사":.GRATITUDE,"휴식":.REST,
                                                            "성장":.GROWTH, "변화":.CHANGE, "건강":.HEALTH, "극복":.OVERCOME,
                                                            "도전":.CHALLENGE]
    private let emotionEnumDict: [String: LookBackEmotionEnum] = ["편안":.COMFORTABLE, "불편":.INCONVENIENCE,
                                                                  "기대":.EXPECTATION,"답답":.FRUSTRATED,
                                                                  "무난":.EASY, "기쁨":.JOY, "화남":.ANGRY, "아쉬운":.REGRETFUL,
                                                                  "만족":.SATISFACTION]
    
    func toNextPage() {
        guard self.page < 5 else { return }
        self.page = self.page + 1
    }
    
    func toPreviousPage() {
        guard self.page > 0 else { return }
        self.page = self.page - 1
    }
    
    func publishFirstStarInfos() {
        self.firstvcStars = self.firstVCStarInfo
    }
    
    func publishSecondStarInfos() {
        if self.secondvcAnswerInfo.count == 0 {
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
            for star in self.secondVCStarInfo1 {
                if star.selected {
                    self.secondvcNextButtonAble = true
                    return
                }
            }
            self.secondvcNextButtonAble = false
        }
        else {
            self.secondVCStarInfo2[index].selected = !self.secondVCStarInfo2[index].selected
            self.publishSecondStarInfos()
            for star in self.secondVCStarInfo2 {
                if star.selected {
                    self.secondvcNextButtonAble = true
                    return
                }
            }
            self.secondvcNextButtonAble = false
        }
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
    
    func thirdvcAnswerChange(value: Int) {
        guard thirdvcAnswers[self.thirdvcAnswers.count - 1] != value else { return }
        self.thirdvcAnswers[self.thirdvcAnswers.count - 1] = value
        self.thirdvcImageNames[self.thirdvcImageNames.count - 1] = self.makeBackgroundImageName(value: value)
        self.publishThirdVCInfos()
    }
    
    func publishThirdVCInfos() {
        self.thirdvcAnswerInfo = self.thirdvcAnswers
        self.thirdvcImageNameInfo = self.thirdvcImageNames
        self.thirdvcTitle = self.thirdvcTitles[self.thirdvcAnswers.count - 1]
    }
    
    func thirdvcNextButtonTapped() {
        if self.thirdvcAnswerInfo.count >= 4 {
            self.toNextPage()
        }
        else {
            self.thirdvcAnswers.append(0)
            self.thirdvcImageNames.append(makeBackgroundImageName(value: 0))
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
        return "lookBack3Illust" + String(self.thirdvcAnswers.count - 1) + String(value)
    }
    
    func publishFifthReasonInfo() {
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
    
    func getSelectedStars(starList: [LookBackStar]) -> [LookBackStarEnum] {
        var result: [LookBackStarEnum] = []
        for star in starList {
            if star.selected {
                guard let enumerated = self.starEnumDict[star.starName] else { continue }
                result.append(enumerated)
            }
        }
        return result
    }
    
    func getSelectedEmotions(emotionList: [LookBackEmotion]) -> [LookBackEmotionEnum] {
        var result: [LookBackEmotionEnum] = []
        for emotion in emotionList {
            if emotion.isSelected {
                guard let enumerated = self.emotionEnumDict[emotion.emotion] else { continue }
                result.append(enumerated)
            }
        }
        return result
    }
    
    func makeRecordInfo() -> [String?] {
        var result: [String?] = []
        if self.fifthvcReasonInfo.count == 0 {
            result = ["", nil, nil]
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
        
        
        let resultValue = LookBackValueModel(y: self.getSelectedStars(starList: self.secondVCStarInfo1),
                                             n: self.getSelectedStars(starList: self.secondVCStarInfo2),
                                             health: self.thirdvcAnswerInfo[0],
                                             happy: self.thirdvcAnswerInfo[1],
                                             challenge: self.thirdvcAnswerInfo[2],
                                             moderation: self.thirdvcAnswerInfo[3],
                                             emoticon: self.getSelectedEmotions(emotionList: self.fourthVCEmotionInfo),
                                             need: self.getSelectedStars(starList: self.sixthVCStarInfo)
        )
        
        let recordInfo = self.makeRecordInfo()
        
        let resultModel = LookBackModel(year: String(Date.currentYear), month: String(Date.currentMonth), weekNo: String(Date.currentWeekNoOfMonth), value: resultValue, record1: recordInfo[0], record2: recordInfo[1], record3: recordInfo[2])
        print(resultModel)
        
        let registAPI = LookBackAPI.createLookBack(model: resultModel)
        
        NetworkManager.request(apiType: registAPI)
            .subscribe(onSuccess: { [weak self] (responseModel: LookBackResponseModel) in
                print(responseModel)
            })
            .disposed(by: self.disposeBag)
        
        
        
        
    }
    
}


