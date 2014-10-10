#
#  Be sure to run `pod spec lint CCDataSourceManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CCDataSourceManager"
  s.version      = "0.0.2"
  s.summary      = "Drop In DataSource Manager for Table- and CollectionView. Register Cells for certain model classes"

  s.description  = <<-DESC
                   A longer description of CCDataSourceManager in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/absolute-heike/CCDataSourceManager"

  s.license      = "MIT"

  s.author             = { "Michael Berg" => "michael@couchfunk.de" }
  s.social_media_url   = "http://twitter.com/aBsoluteh3ike"

  s.platform     = :ios
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/absolute-heike/CCDataSourceManager.git", :tag => "0.0.2" }


  s.source_files  = "CCDataSourceManager", "CCDataSourceManager/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "ReactiveCocoa"

end
