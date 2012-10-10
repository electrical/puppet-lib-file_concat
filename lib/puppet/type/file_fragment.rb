#
# TODO
#
module Puppet
  newtype(:file_fragment) do
    @doc = "TODO"

    newparam(:name, :namevar => true) do
      desc "TODO"
    end

    newparam(:target) do
      desc "Deprecated. Use *path* instead."
    end

    newparam(:path) do
      desc "TODO"

      defaultto do
	resource.value(:target)
      end
    end

    newparam(:content) do
      desc "TODO"
    end

    newparam(:order) do
      desc "TODO"

      defaultto '10'

      validate do |val|
        fail "only integers > 0 are allowed and not '#{val}'" if val !~ /^\d+$/
      end

    end
  end
end

