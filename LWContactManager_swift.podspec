#
# LWContactManager_swift.podspec
# Swift version of LWContactManager
#

Pod::Spec.new do |s|
  s.name             = 'LWContactManager_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift version of LWContactManager - A modern contact management library'

  s.description      = <<-DESC
LWContactManager_swift is a modern Swift/SwiftUI implementation of the LWContactManager library.
A comprehensive contact management solution with:
- Contact fetching and management
- Pinyin-based sorting and searching
- SwiftUI contact picker view
- Contacts framework integration
- Privacy-aware permission handling
- Contact grouping by initials
- Real-time search and filtering
- Combine framework support
                       DESC

  s.homepage         = 'https://github.com/luowei/LWContactManager.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWContactManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'LWContactManager_swift/Sources/LWContactManager/**/*'

  s.frameworks = 'UIKit', 'Contacts', 'ContactsUI', 'SwiftUI', 'Combine'
end
