require File.expand_path(File.join(File.dirname(__FILE__), '..', 'file_concat'))

Puppet::Type.type(:file_concat).provide(:windows, :parent => Puppet::Type.type(:file).provider(:windows)) do
  confine :feature => :windows
  defaultfor :feature => :windows

  include Puppet::Provider::File_concat
end
