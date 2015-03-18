require 'spec_helper_acceptance'

# Here we put the more basic fundamental tests, ultra obvious stuff.
describe "File Concat" do

  describe "file fragment content" do

    it 'should run successfully' do
      pp = "file_fragment { 'fragment_1': content => 'mycontent', tag => 'mytag' }
            file_concat { 'myfile': ensure => 'present', tag => 'mytag', path => '/tmp/concat' }
           "
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end
 
    describe file('/tmp/concat') do
      it { should be_file }
      its(:content) { should match /mycontent/ }
    end
  end
end
