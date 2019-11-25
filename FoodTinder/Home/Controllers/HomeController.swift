//
//  HomeController.swift
//  Tinder
//
//  Created by Bekzod Rakhmatov on 23/01/2019.
//  Copyright © 2019 BekzodRakhmatov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import JGProgressHUD

//class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {
class HomeController: UIViewController, SettingsControllerDelegate, CardViewDelegate {
    
    let topStackView    = TopNavigationStackView()
    let cardsDeckView   = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettingsButton), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleFavButton), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefreshButton), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLikeButton), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislikeButton), for: .touchUpInside)
        setupLayout()
//        fetchCurrentUser()
        fetchUsersFromFirebase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\n\n\n\n")
//        self.topCardView = self.setupFakeCard()
        print(self.topCardView)
        print("\n\n\n\n")
//        if Auth.auth().currentUser == nil {
//            let registrationController = RegistrationController()
//            registrationController.loginControllerDelegate = self
//            let navigationController = UINavigationController(rootViewController: registrationController)
//            present(navigationController, animated: true, completion: nil)
//        }
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        
        Firestore.firestore().fetchCurrentUser { (user, error) in
            if let error = error {
                print("Error, \(error)")
                return
            }
            self.user = user
            self.fetchSwipes()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch sipes info for currently logged in user: ",error)
                return
            }
            
            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = data
//            self.fetchUsersFromFirebase()
        }
    }
    
    @objc fileprivate func handleRefreshButton() {
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirebase()
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirebase() {
        let user = User(dictionary: ["age": 12, "profession": "kkk", "fullName": "bora dale", "imageUrl1": "https://www.gazetadopovo.com.br/haus/wp-content/uploads/2019/10/02190226/flores-primavera-pixabay-1.jpg", "imageUrl2": "https://imagens-revista.vivadecora.com.br/uploads/2018/05/tipos-de-flores-para-arranjos-na-decora%C3%A7%C3%A3o.jpg", "uid": "1234567890", "minSeekingAge": 0, "maxSeekingAge": 100])
//        self.age = dictionary["age"] as? Int
//        self.profession = dictionary["profession"] as? String
//        self.name = dictionary["fullName"] as? String ?? ""
//        self.imageUrl1 = dictionary["imageUrl1"] as? String
//        self.imageUrl2 = dictionary["imageUrl2"] as? String
//        self.imageUrl3 = dictionary["imageUrl3"] as? String
//        self.uid = dictionary["uid"] as? String ?? ""
//        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
//        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
        var prevoiusCardView: CardView?
        
        let cardView = self.setupCardFromUser(user: user)
        prevoiusCardView?.nextCardView = cardView
        prevoiusCardView = cardView

        if self.topCardView == nil {
            self.topCardView = cardView
        }
    }
    
//    fileprivate func fetchUsersFromFirebase() {
//        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
//        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
//
//        let hud = JGProgressHUD(style: .dark)
//        hud.textLabel.text = "Fetching Users"
//        hud.show(in: view)
//
//        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThan: minAge - 1).whereField("age", isLessThan: maxAge + 1)
////        let query = Firestore.firestore().collection("users")
//
//        topCardView = nil
//
//        query.getDocuments { (snapshot, error) in
//
//            hud.dismiss()
//
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//
//            var prevoiusCardView: CardView?
//
//            snapshot?.documents.forEach({ (documentSnapshot) in
//                let userDictionary = documentSnapshot.data()
//                let user = User(dictionary: userDictionary)
//
//                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
////               let hasSwipedBefore = self.swipes[user.uid!] == nil
//                let hasSwipedBefore = true
//                if isNotCurrentUser && hasSwipedBefore {
//
//                    let cardView = self.setupCardFromUser(user: user)
//
//                    prevoiusCardView?.nextCardView = cardView
//                    prevoiusCardView = cardView
//
//                    if self.topCardView == nil {
//                        self.topCardView = cardView
//                    }
//                }
//            })
//        }
//    }
    
    var topCardView: CardView?
    
    @objc func handleLikeButton() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislikeButton() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -10)
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    if didLike == 1 {
//                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    if didLike == 1 {
//                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    
//    fileprivate func checkIfMatchExists(cardUID: String) {
//        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
//            if let err = err {
//                print("Failed to fetch document for card user:", err)
//                return
//            }
//
//            guard let data = snapshot?.data() else { return }
//            print(data)
//
//            guard let uid = Auth.auth().currentUser?.uid else { return }
//
//            let hasMatched = data[uid] as? Int == 1
//            if hasMatched {
//                self.presentMatchView(cardUID: cardUID)
//            }
//        }
//    }
    
//    fileprivate func presentMatchView(cardUID: String) {
//        let matchView = MatchView()
//        matchView.currentUser = self.user
//        matchView.cardUID = cardUID
//        view.addSubview(matchView)
//        matchView.fillSuperview()
//    }
    
    func didRemoveCard(cardView: CardView) {
        
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let coardView = topCardView
        topCardView = coardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            coardView?.removeFromSuperview()
        }
        
        coardView?.layer.add(translationAnimation, forKey: "translation")
        coardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = user.toCardViewModel()
        cardView.cardViewDelegate = self
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        
        return cardView
    }
    
    fileprivate func setupFakeCard() -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = CardViewModel(uid: "1234567890", imageNames: ["super_like_circle", "super_like_circle", "super_like_circle"], attributedString: NSAttributedString(string: "Poketeste"), textAlignment: .left)
//        self.view = cardView
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleSettingsButton() {
        
        let settingsController = SettingsController()
        settingsController.settingDelegate = self
        let navigationController = UINavigationController(rootViewController: settingsController)
        present(navigationController, animated: true, completion: nil)
        
    }
    
    @objc fileprivate func handleFavButton() {
        
        let favView = FavView() 
//        let navigationController = UINavigationController(rootViewController: settingsController)
        present(favView, animated: true, completion: nil)
        
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    //MARK: - Setup File Private Methods
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardViewModel) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardViewModel
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
}
