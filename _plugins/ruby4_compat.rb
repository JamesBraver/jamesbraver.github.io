# Ruby 4 local-preview compatibility shim.
#
# Jekyll 3.9 ships Liquid 4.0.3, which still uses the object-taint API
# (`tainted?`, `untaint`). Ruby 3.2 deprecated tainting and Ruby 4 removed it,
# so on a modern local Ruby the build dies inside Liquid. Restoring no-op
# versions is enough — the taint flag never carried meaning for Jekyll.
#
# GitHub Pages builds in safe mode and ignores _plugins/ entirely, so this file
# never runs there. Delete it if you upgrade to Jekyll 4 / Liquid 5 locally.
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.2")
  class Object
    def tainted?
      false
    end

    def taint
      self
    end

    def untaint
      self
    end
  end
end
