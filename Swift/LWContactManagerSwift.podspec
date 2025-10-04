Pod::Spec.new do |s|
  s.name             = 'LWContactManagerSwift'
  s.version          = '1.0.0'
  s.summary          = 'Swift/SwiftUI version of LWContactManager for iOS contacts management'

  s.description      = <<-DESC
  LWContactManagerSwift is a modern Swift/SwiftUI library for managing iOS contacts.
  It provides a clean API with async/await support, SwiftUI views, and Chinese pinyin sorting.

  Features:
  - Native Contacts framework integration (no external dependencies)
  - Async/await and callback-based APIs
  - SwiftUI contact picker view
  - Chinese pinyin sorting support
  - Search functionality
  - iOS 12+ compatible
                       DESC

  s.homepage         = 'https://github.com/luowei/LWContactManager'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWContactManager.git', :tag => "swift-#{s.version}" }

  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5.5', '5.6', '5.7', '5.8', '5.9']

  s.source_files = 'Sources/LWContactManager/**/*.swift'

  s.frameworks = 'Contacts', 'ContactsUI', 'SwiftUI'

  # No external dependencies
end
