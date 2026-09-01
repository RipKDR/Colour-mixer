#
# FFI plugin podspec for ChromaStudio.
# After building with ./tools/build_mobile.sh ios, place libchroma_engine.a in Frameworks/.
#
Pod::Spec.new do |s|
  s.name             = 'chroma_engine_ffi'
  s.version          = '0.1.0'
  s.summary          = 'ChromaStudio Rust spectral engine FFI'
  s.description      = 'Bundles libchroma_engine for iOS via static linking.'
  s.homepage         = 'https://github.com/chromastudio/chromastudio'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'ChromaStudio' => 'dev@chromastudio.app' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'OTHER_LDFLAGS' => '$(inherited) -lc++'
  }
  s.swift_version = '5.0'

  lib = 'Frameworks/libchroma_engine.a'
  if File.exist?(lib)
    s.vendored_libraries = lib
  end
end
