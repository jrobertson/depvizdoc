Gem::Specification.new do |s|
  s.name = 'depvizdoc'
  s.version = '0.2.1'
  s.summary = 'Generates a hyperlinked SVG document containing relative ' + 
      'dependencies for all the given dependencies.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/depvizdoc.rb']
  s.add_runtime_dependency('depviz', '~> 0.4', '>=0.4.0')
  s.add_runtime_dependency('martile', '~> 0.9', '>=0.9.4')
  s.signing_key = '../privatekeys/depvizdoc.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/depvizdoc'
end
