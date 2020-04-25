Gem::Specification.new do |spec|
  spec.name = 'google_forms'
  spec.version = '0.0.2'
  spec.date = '2020-04-25'
  spec.summary = 'Posting to Google Forms from your ruby scripts'
  spec.authors = ['Vadim Venediktov']
  spec.email = 'install.vv@gmail.com'
  spec.homepage = 'https://github.com/installero/google_forms_ruby'

  spec.files += Dir['lib/*.rb']

  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'curb', '~> 0.9'
  spec.add_runtime_dependency 'nokogiri', '~> 1.10'

  spec.license = 'MIT'
end
