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
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProviderLoginView()
    }
    /// 페이스북, 구글, 애플 로그인 버튼 세팅 메서드
    func setupProviderLoginView() {
        let facebookLoginBtn = FBLoginButton()
        facebookLoginBtn.delegate = self
        facebookLoginBtn.permissions = ["public_profile", "email"]
        loginProviderStackView.addArrangedSubview(facebookLoginBtn)
        
        let googleLoginBtn = GIDSignInButton()
        loginProviderStackView.addArrangedSubview(googleLoginBtn)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        let appleLoginBtn = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        appleLoginBtn.addTarget(self, action: #selector(handleAuthorizationAppleIDBtnPressed), for: .touchUpInside)
        loginProviderStackView.addArrangedSubview(appleLoginBtn)
    }
        
    func signInFirbase(with credential: NSObject) {
        Auth.auth().signIn(with: credential as! AuthCredential) { (authResult, error) in
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
    func handleAuthorizationAppleIDBtnPressed() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
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
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
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
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("sigIn error: \(error.localizedDescription)")
            return
        } else {
            print("user email: \(user.profile.email ?? "no email")")
        }
        guard let auth = user.authentication else { return }
        let googleCredential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        signInFirbase(with: googleCredential)
    }
}

// MARK: - Apple Login Extension
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A lgoin callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            signInFirbase(with: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 에러 처리
        print("Sign in with Apple errored: \(error)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

