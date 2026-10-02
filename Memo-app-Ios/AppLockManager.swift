//
//  AppLockManager.swift
//  Memo-app-Ios
//
//  Created by student3 on 2026-10-02.
//
//
//import Foundation
//import LocalAuthentication
//
//@MainActor
//final class AppLockManager: ObservableObject {
//    static let shared = AppLockManager ()
//    
//    @Published private(set) var isLocked = false
//    
//    private let faceIDEnabledKey = "faceIDEnabled"
//    private let backgroundDateKey = "appBackgroundDate"
//    
//    private init() {
//        
//        if UserDefaults.standard.bool(
//            forKey: faceIDEnabledKey
//        ) {
//            
//            isLocked = true
//        }
//    }
//    
//    var faceIDEnabled: Bool {
//        UserDefaults.standard.bool(forKey: faceIDEnabledKey)
//    }
//    
//    func enableFaceID() async ->Bool{
//        let context = LAContext()
//        
//        var error: NSError?
//        
//        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//            else {
//                return false
//            }
//        }
//    }
//    
//    do {
//        let sucess = try await context.evaluatePolicy
//        (.deviceOwnerAuthentication, localizedReason: "Enable face ID to protect your memory app")
//        
//        if success{
//            UserDefaults.standard.set(true, forKey: faceIDEnabledKey)
//            isLocked = false
//            return true
//        }
//        
//        return false
//        
//        
//    }catch{
//        print ("face id enabal error",Error.localizedDescription)
//        return false
//    }
//    }
//
//    func disabelFaceID(){
//    let context = LAContext()
//        
//        var error: NSError?
//        
//        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else{
//            return false
//        }
//        
//        do {
//          let success = try await context.evaluatePolicy(
//              .deviceOwnerAuthentication,
//              localizedReason:
//                  "Confirm your identity to disable Face ID protection."
//          )
//
//
//          if success {
//
//              UserDefaults.standard.set(
//                  false,
//                  forKey: faceIDEnabledKey
//              )
//
//              isLocked = false
//
//              return true
//          }
//
//
//          return false
//
//        } catch {
//            print("face id disable error"),error.localizedDescription)
//            
//        }
//}
//    
//    
//#Preview {
//    AppLockManager()
//}
