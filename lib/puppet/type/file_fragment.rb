#
# File Fragment
#

Puppet::Type.newtype(:file_fragment) do
  @doc = "Create a file fragment to be used by file_concat"

  newparam(:name, :namevar => true) do
    desc "Unique name"
  end

  newparam(:content) do
    desc "Content"
  end

  newparam(:order) do
    desc "Order"
    defaultto '10'
    validate do |val|
      fail "only integers > 0 are allowed and not '#{val}'" if val !~ /^\d+$/
    end
  end

  newparam(:tag) do
    desc "Tag name to be used by file_concat to collect all file_fragments by tag name"
  end

end
