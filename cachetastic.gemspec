# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cachetastic-three}
  s.version = "3.0.0.20090611121711"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Bates"]
  s.date = %q{2009-06-11}
  s.description = %q{A very simple, yet very powerful caching framework for Ruby.}
  s.email = %q{mark@mackframework.com}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["lib/cachetastic/adapters/base.rb", "lib/cachetastic/adapters/file.rb", "lib/cachetastic/adapters/local_memory.rb", "lib/cachetastic/adapters/memcached.rb", "lib/cachetastic/cache.rb", "lib/cachetastic/cacheable.rb", "lib/cachetastic/extensions/string.rb", "lib/cachetastic/logger.rb", "lib/cachetastic/store_object.rb", "lib/cachetastic.rb", "README", "LICENSE", "doc/classes/Cachetastic/Adapters/Base.html", "doc/classes/Cachetastic/Adapters/File.html", "doc/classes/Cachetastic/Adapters/LocalMemory.html", "doc/classes/Cachetastic/Adapters/Memcached.html", "doc/classes/Cachetastic/Adapters.html", "doc/classes/Cachetastic/Cache.html", "doc/classes/Cachetastic/Cacheable/ClassAndInstanceMethods.html", "doc/classes/Cachetastic/Cacheable/ClassOnlyMethods.html", "doc/classes/Cachetastic/Cacheable.html", "doc/classes/Cachetastic/Logger.html", "doc/created.rid", "doc/files/lib/cachetastic/adapters/base_rb.html", "doc/files/lib/cachetastic/adapters/file_rb.html", "doc/files/lib/cachetastic/adapters/local_memory_rb.html", "doc/files/lib/cachetastic/adapters/memcached_rb.html", "doc/files/lib/cachetastic/cache_rb.html", "doc/files/lib/cachetastic/cacheable_rb.html", "doc/files/lib/cachetastic/extensions/string_rb.html", "doc/files/lib/cachetastic/logger_rb.html", "doc/files/lib/cachetastic/store_object_rb.html", "doc/files/lib/cachetastic_rb.html", "doc/files/LICENSE.html", "doc/files/README.html", "doc/fr_class_index.html", "doc/fr_file_index.html", "doc/fr_method_index.html", "doc/index.html", "doc/rdoc-style.css"]
  s.has_rdoc = true
  s.homepage = %q{http://www.metabates.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cachetastic}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A very simple, yet very powerful caching framework for Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<configatron>, [">= 2.3.2"])
      s.add_runtime_dependency(%q<memcache-client>, [">= 1.7.4"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.2"])
    else
      s.add_dependency(%q<configatron>, [">= 2.3.2"])
      s.add_dependency(%q<memcache-client>, [">= 1.7.4"])
      s.add_dependency(%q<activesupport>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<configatron>, [">= 2.3.2"])
    s.add_dependency(%q<memcache-client>, [">= 1.7.4"])
    s.add_dependency(%q<activesupport>, [">= 2.3.2"])
  end
end
