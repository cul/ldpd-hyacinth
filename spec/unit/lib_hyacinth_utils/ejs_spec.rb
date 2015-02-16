require 'rails_helper'

context 'Hyacinth::Utils::Ejs' do

  #before(:all) do
  #
  #end
  #
  #before(:each) do
  #
  #end

  context ".compile" do
    it "non-prefixed src doc AND dst doc" do

      compiled = Hyacinth::Utils::Ejs.compile('This is a <% var something = "test" %><%= something %>')
      rendered = Hyacinth::Utils::Ejs.render(compiled, {other_var: 'zzz'})

    end
  end

end
