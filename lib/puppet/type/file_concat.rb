require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'
require 'puppet/util/checksums'
require 'puppet/type/file/source'

Puppet::Type.newtype(:file_concat) do
  @doc = "Gets all the file fragments and puts these into the target file.
    This will mostly be used with exported resources.

    example:
      File_fragment <<| tag == 'unique_tag' |>>

      file_concat { '/tmp/file:
        tag   => 'unique_tag', # Mandatory
        path  => '/tmp/file',  # Optional. If given it overrides the resource name
        owner => 'root',       # Optional. Default to root
        group => 'root',       # Optional. Default to root
        mode  => '0644'        # Optional. Default to 0644
        order => 'numeric'     # Optional, Default to 'numeric'
      }
  "
  ensurable do
    defaultvalues

    defaultto { :present }
  end

  def exists?
    self[:ensure] == :present
  end

  newparam(:name, :namevar => true) do
    desc "Resource name"
  end

  newparam(:tag) do
    desc "Tag reference to collect all file_fragment's with the same tag"
  end

  newparam(:path) do
    desc "The output file"
    defaultto do
      resource.value(:name)
    end
  end

  newparam(:owner, :parent => Puppet::Type::File::Owner) do
    desc "Desired file owner."
    defaultto 'root'
  end

  newparam(:group, :parent => Puppet::Type::File::Group) do
    desc "Desired file group."
    defaultto 'root'
  end

  newparam(:mode, :parent => Puppet::Type::File::Mode) do
    desc "Desired file mode."
    defaultto '0644'
  end

  newparam(:order) do
    desc "Controls the ordering of fragments. Can be set to alphabetical or numeric."
    defaultto 'numeric'
  end

  newparam(:backup) do
    desc "Controls the filebucketing behavior of the final file and see File type reference for its use."
    defaultto 'puppet'
  end

  newparam(:replace) do
    desc "Whether to replace a file that already exists on the local system."
    defaultto true
  end

  newparam(:validate_cmd) do
    desc "Validates file."
  end

  def should_content
    return @generated_content if @generated_content
    @generated_content = ""
    content_fragments = []

    resources = catalog.resources.select do |r|
      r.is_a?(Puppet::Type.type(:file_fragment)) && r[:tag] == self[:tag]
    end

    resources.each do |r|
      content_fragments << ["#{r[:order]}___#{r[:name]}", fragment_content(r)]
    end

    if self[:order] == 'numeric'
      sorted = content_fragments.sort do |a, b|
        def decompound(d)
          d.split('___').map { |v| v =~ /^\d+$/ ? v.to_i : v }
        end

        decompound(a[0]) <=> decompound(b[0])
      end
    else
      sorted = content_fragments.sort do |a, b|
        def decompound(d)
          d.split('___').first
        end

        decompound(a[0]) <=> decompound(b[0])
      end
    end

    @generated_content = sorted.map { |cf| cf[1] }.join

    @generated_content
  end

  def fragment_content(r)
    if r[:content].nil? == false
      fragment_content = r[:content]
    elsif r[:source].nil? == false
      tmp = Puppet::FileServing::Content.indirection.find(r[:source], :environment => catalog.environment)
      fragment_content = tmp.content unless tmp.nil?
    end
    fragment_content
  end

  def generate
    Puppet::Type.type(:file).new({
      :ensure  => self[:ensure] == :absent ? :absent : :file,
      :path    => self[:path],
      :owner   => self[:owner],
      :group   => self[:group],
      :replace => self[:replace],
      :content => self.should_content,
    })
  end
end
