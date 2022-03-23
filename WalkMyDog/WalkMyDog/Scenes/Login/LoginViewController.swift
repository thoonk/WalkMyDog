//
//  ViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/02.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController {
    // MARK: - Interface Builder
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    // MARK: - Properties
    // Unhashed nonce.
    fileprivate var currentNonce: String?
//    private var slides: [SlideView] {
//        let slide1: SlideView = Bundle.main.loadNibNamed(
//            "SlideView",
//            owner: self,
//            options: nil
//        )?.first as! SlideView
//        slide1.imageView.image = UIImage(named: "slideImage1.jpeg")
//        slide1.textLabel.text = C.Slide.text1
//
//        let slide2: SlideView = Bundle.main.loadNibNamed(
//            "SlideView",
//            owner: self,
//            options: nil
//        )?.first as! SlideView
//        slide2.imageView.image = UIImage(named: "slideImage2.jpeg")
//        slide2.textLabel.text = C.Slide.text2
//
//
//        let slide3: SlideView = Bundle.main.loadNibNamed(
//            "SlideView",
//            owner: self,
//            options: nil
//        )?.first as! SlideView
//        slide3.imageView.image = UIImage(named: "slideImage3.jpg")
//        slide3.textLabel.text = C.Slide.text3
//
//        return [slide1, slide2, slide3]
//    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        view.bringSubviewToFront(loginProviderStackView)
        view.bringSubviewToFront(pageControl)
        setupOnboarding(slides: slides)
        setupProviderLoginView()
    }
    
    // MARK: - Methods
    private func setupOnboarding(slides: [SlideView]) {
        scrollView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height/2
        )
        scrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(slides.count),
            height: view.frame.height/2
        )
        scrollView.isPagingEnabled = true
        scrollView.contentSize.height = 1.0
                
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(
                x: view.frame.width * CGFloat(i),
                y: 0,
                width: view.frame.width,
                height: view.frame.height/2
            )
            scrollView.addSubview(slides[i])
        }
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(named: "customTintColor")
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        pageControl.isUserInteractionEnabled = false
    }
    
    /// 페이스북, 구글, 애플 로그인 버튼 세팅 메서드
    private func setupProviderLoginView() {
        let facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.delegate = self
        facebookLoginBtn.permissions = ["public_profile", "email"]
        loginProviderStackView.addArrangedSubview(facebookLoginBtn)
        
        let googleLoginBtn = GIDSignInButton()
        loginProviderStackView.addArrangedSubview(googleLoginBtn)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        let appleLoginBtn = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        appleLoginBtn.addTarget(
            self,
            action: #selector(handleAuthorizationAppleIDBtnPressed),
            for: .touchUpInside
        )
        loginProviderStackView.addArrangedSubview(appleLoginBtn)
        loginProviderStackView.spacing = 10
    }
        
    private func signInFirbase(with credential: NSObject) {
        Auth.auth().signIn(
            with: credential as! AuthCredential
        ) { authResult, error in
            if let error = error {
                print("Firebase sign in error: \(error.localizedDescription)")
                return
            } else {
                if let user = Auth.auth().currentUser {
                    print("Current Firebase user is \(user)")
                }
                self.performSegue(withIdentifier: "fromLoginToHome", sender: nil)
            }
        }
    }
    
    // MARK: - Authenticate with Firebase for sign in with Apple
    /// 인증을 처리할 메서드
    @objc
    private func handleAuthorizationAppleIDBtnPressed() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(
            authorizationRequests: [request]
        )
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

// MARK: - Facebook Login Extension
extension LoginViewController: LoginButtonDelegate {
    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith result: LoginManagerLoginResult?,
        error: Error?
    ) {
        print("Facebook User logged in")
        
        guard let token = result?.token?.tokenString else {
            print("Facebook: User failed to log in")
            return
        }
        print("Facebook Token: \(token)")
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        signInFirbase(with: credential)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Facebook User logged out")
    }
}

// MARK: - Google Login Extension
extension LoginViewController: GIDSignInDelegate {
    func sign(
        _ signIn: GIDSignIn!,
        didSignInFor user: GIDGoogleUser!,
        withError error: Error!
    ) {
        if let error = error {
            print("sigIn error: \(error.localizedDescription)")
            return
        } else {
            print("user email: \(user.profile.email ?? "no email")")
        }
        guard let auth = user.authentication else { return }
        let googleCredential = GoogleAuthProvider.credential(
            withIDToken: auth.idToken,
            accessToken: auth.accessToken
        )
        signInFirbase(with: googleCredential)
    }
}

// MARK: - Apple Login Extension
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        
        if let appleIDCredential = authorization
            .credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(
                    data: appleIDToken,
                    encoding: .utf8
            ) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            signInFirbase(with: credential)
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        // 에러 처리
        print("Sign in with Apple errored: \(error)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - UIScrollViewDelegate
extension LoginViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
