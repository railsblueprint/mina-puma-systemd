# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mina/puma_systemd/version'

Gem::Specification.new do |spec|
  spec.name          = 'mina-puma-systemd'
  spec.version       = Mina::PumaSystemd::VERSION
  spec.authors       = ['Vladimir Elchinov']
  spec.email         = ['elik@elik.ru']
  spec.description   = %q{Puma tasks for Mina and systemd}
  spec.summary       = %q{Puma tasks for Mina and systemd}
  spec.homepage      = 'https://github.com/railsblueprint/mina-puma-systemd'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mina', '~> 1.2.0'
  spec.add_dependency 'puma', '>= 2.13'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
