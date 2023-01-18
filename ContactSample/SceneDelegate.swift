//
//  SceneDelegate.swift
//  ContactSample
//
//  Created by jefferson.setiawan on 29/11/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)

        window?.rootViewController = UINavigationController(rootViewController: RouteVC())
        window?.makeKeyAndVisible()
    }
}
