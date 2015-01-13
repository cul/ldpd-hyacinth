require 'rails_helper'
require 'equivalent-xml'

context 'Hyacinth::Utils::XmlUtils' do

  before(:all) do
    @mods_namespace_hash = {'mods' => 'http://www.loc.gov/mods/v3'}
    @src_mods_item_xml = fixture('xml_utils/merge/src_mods_item.xml').read
    @src_mods_item_with_mods_prefix_xml = fixture('xml_utils/merge/src_mods_item.xml').read
    @dst_mods_item_xml = fixture('xml_utils/merge/dst_mods_item.xml').read
    @dst_mods_item_with_mods_prefix_xml = fixture('xml_utils/merge/dst_mods_item_with_mods_prefix.xml').read
    @merged_mods_item_ng = Nokogiri::XML(fixture('xml_utils/merge/merged_mods_item.xml').read)
    @merged_mods_item_with_mods_prefix_ng = Nokogiri::XML(fixture('xml_utils/merge/merged_mods_item_with_mods_prefix.xml').read)
  end

  before(:each) do
    @src_mods_item_ng = Nokogiri::XML(@src_mods_item_xml)
    @src_mods_item_with_mods_prefix_ng = Nokogiri::XML(@src_mods_item_with_mods_prefix_xml)
    @dst_mods_item_ng = Nokogiri::XML(@dst_mods_item_xml)
    @dst_mods_item_with_mods_prefix_ng = Nokogiri::XML(@dst_mods_item_with_mods_prefix_xml)
  end

  context ".update_dst_with_src" do
    
    context "replace a single mods titleInfo/title element in MODS-namespaced src and dst docs, regardless of whether those docs have 'mods:'-prefixed elements" do
    
      it "non-prefixed src doc AND dst doc" do
        xpaths_to_replace = ['/mods:mods/mods:titleInfo/mods:title']
        Hyacinth::Utils::XmlUtils.replace_xml_subtrees(@src_mods_item_ng, @dst_mods_item_ng, xpaths_to_replace, {'mods' => 'http://www.loc.gov/mods/v3'})
        #expect(@dst_mods_item_ng.to_xml).to eq(@merged_mods_item_ng.to_xml)
        expect(EquivalentXml.equivalent?(@dst_mods_item_ng, @merged_mods_item_ng)).to eq(true)
      end
      
      it "prefixed src doc and non-prefixed dst doc" do
        xpaths_to_replace = ['/mods:mods/mods:titleInfo/mods:title']
        Hyacinth::Utils::XmlUtils.replace_xml_subtrees(@src_mods_item_with_mods_prefix_ng, @dst_mods_item_ng, xpaths_to_replace, {'mods' => 'http://www.loc.gov/mods/v3'})
        #expect(@dst_mods_item_ng.to_xml).to eq(@merged_mods_item_ng.to_xml)
        expect(EquivalentXml.equivalent?(@dst_mods_item_ng, @merged_mods_item_ng)).to eq(true)
      end
      
      it "non-prefixed src doc and prefixed dst doc" do
        xpaths_to_replace = ['/mods:mods/mods:titleInfo/mods:title']
        Hyacinth::Utils::XmlUtils.replace_xml_subtrees(@src_mods_item_ng, @dst_mods_item_with_mods_prefix_ng, xpaths_to_replace, {'mods' => 'http://www.loc.gov/mods/v3'})
        #expect(@dst_mods_item_with_mods_prefix_ng.to_xml).to eq(@merged_mods_item_with_mods_prefix_ng.to_xml)
        expect(EquivalentXml.equivalent?(@dst_mods_item_with_mods_prefix_ng, @merged_mods_item_with_mods_prefix_ng)).to eq(true)
      end
      
      it "prefixed src doc AND dst doc" do
        xpaths_to_replace = ['/mods:mods/mods:titleInfo/mods:title']
        Hyacinth::Utils::XmlUtils.replace_xml_subtrees(@src_mods_item_with_mods_prefix_ng, @dst_mods_item_with_mods_prefix_ng, xpaths_to_replace, {'mods' => 'http://www.loc.gov/mods/v3'})
        #expect(@dst_mods_item_with_mods_prefix_ng.to_xml).to eq(@merged_mods_item_with_mods_prefix_ng.to_xml)
        expect(EquivalentXml.equivalent?(@dst_mods_item_with_mods_prefix_ng, @merged_mods_item_with_mods_prefix_ng)).to eq(true)
      end
    
    end
  
    context "replace multiple same-xpath elements with several new same-xpath elements" do
      
      it "deletes old name elements and adds new elements in the correct order" do
        target_xpath_for_test = '/mods:mods/mods:name'
        xpaths_to_replace = [target_xpath_for_test]
        Hyacinth::Utils::XmlUtils.replace_xml_subtrees(@src_mods_item_ng, @dst_mods_item_ng, xpaths_to_replace, @mods_namespace_hash)
        expect(@dst_mods_item_ng.to_xml).to_not include("Lindquist, G. E. E. (Gustavus Elmer Emanuel), 1886-1967")
        expect(@dst_mods_item_ng.to_xml).to_not include("Washington, Bill, 1870-1950")
        expect(@dst_mods_item_ng.to_xml).to include("Wayne, Bruce")
        
        names = @dst_mods_item_ng.xpath(target_xpath_for_test, @mods_namespace_hash)
        expect(names[0].to_xml).to include("Wayne, Bruce")
        expect(names[1].to_xml).to include("Kent, Clark")
        expect(names[2].to_xml).to include("A Great Big Party")
        expect(names[3].to_xml).to include("The Willy Wonka Candy Company")
        expect(names[4].to_xml).to include("A Name With No Authority And No Type")
      end
    
  end
  
  context "replace a single mods titleInfo/title element in a MODS document that has a MODS extension with a different namespace" do
    #TODO:
    #it "updates the titleInfo/title" do
    #end
  end

  end

end
