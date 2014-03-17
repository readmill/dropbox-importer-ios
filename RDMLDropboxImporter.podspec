Pod::Spec.new do |s|
  s.name = 'RDMLDropboxImporter'
  s.version = '0.0.2'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage = 'https://github.com/readmill/dropbox-importer-ios'
  s.authors = { 'Martin Hwasser' => 'martin@readmill.com' }
  s.source = { :git => 'https://github.com/readmill/dropbox-importer-ios.git', :tag => '0.0.2' }
  s.summary = 'A simple Dropbox browser and downloader.'
  s.description = <<-DESC
  							  Dropbox Importer uses Dropbox Core API allowing for easy browsing,
                  searching and downloading of files using the Dropbox SDK.
  							  DESC
  s.platform = :ios, '6.0'
  s.requires_arc = true
  s.vendored_frameworks = 'Frameworks/DropboxSDK.framework'
  s.source_files = 'RDMLDropboxImporter/**/*.{h,m}'
  s.resources = 'RDMLDropboxImporter/UI/Assets/*.png'
end