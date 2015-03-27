require File.expand_path(File.join(File.dirname(__FILE__), '..', 'file_concat'))

Puppet::Type.type(:file_concat).provide(:posix, :parent => Puppet::Type.type(:file).provider(:posix)) do
  confine :feature => :posix
  defaultfor :feature => :posix

  include Puppet::Provider::File_concat
end
