import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = SetupViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class SetupViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let title = UILabel()
        title.text = "عربي 123"
        title.font = .systemFont(ofSize: 36, weight: .bold)
        title.textAlignment = .center

        let instructions = UILabel()
        instructions.numberOfLines = 0
        instructions.font = .preferredFont(forTextStyle: .body)
        instructions.text = "Arabic letters. Always 0123456789.\n\nEnable in Settings → General → Keyboard → Keyboards → Add New Keyboard → Arabic 123.\n\nThen hold the globe key and choose Arabic 123. Full Access is not required.\n\nHold backspace to keep deleting. Hold ا, و or ي for more letter forms. Tap ⇧ for diacritics.\n\nTry your keyboard below:"

        let editor = UITextView()
        editor.font = .systemFont(ofSize: 24)
        editor.backgroundColor = .secondarySystemBackground
        editor.layer.cornerRadius = 14
        editor.text = "مرحبا 123"
        editor.textAlignment = .right
        editor.heightAnchor.constraint(equalToConstant: 160).isActive = true

        let settings = UIButton(type: .system)
        settings.setTitle("Open app settings", for: .normal)
        settings.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [title, instructions, editor, settings])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
