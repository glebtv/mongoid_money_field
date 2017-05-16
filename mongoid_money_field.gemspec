# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_money_field/version'

Gem::Specification.new do |spec|
  spec.name          = "mongoid_money_field"
  spec.version       = MongoidMoneyField::VERSION
  spec.authors       = ["Gleb Tv"]
  spec.email         = ["glebtv@gmail.com"]
  spec.description   = %q{Use RubyMoney with mongoid}
  spec.summary       = %q{Use RubyMoney with mongoid}
  spec.homepage      = "http://github.com/glebtv/mongoid_money_field"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mongoid", "~> 5.2"
  spec.add_runtime_dependency "money", "~> 6.5.0"
  spec.add_runtime_dependency "monetize"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "mongoid-rspec"
end
