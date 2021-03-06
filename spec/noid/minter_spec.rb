# frozen_string_literal: true

require 'rails_helper'

describe Noid::Minter do
  # This may seem like an unnecessary test, but there was an issue with the Noid gem at
  # one point (in version 0.7.0 and presumably earlier) that actually DID cause these
  # sequential mints to be identical.
  it "ensures that two noid instances with the same seed and template and DIFFERENT sequences do not create the same pids" do
    pid_minter1 = described_class.new(template: 'ldpd:.reeeeeeee')
    pid_minter1.seed(192_548_637_498_850_379_850_405_658_298_152_906_991, 1)
    first_mint = pid_minter1.mint

    pid_minter2 = described_class.new(template: 'ldpd:.reeeeeeee')
    pid_minter2.seed(192_548_637_498_850_379_850_405_658_298_152_906_991, 2)
    second_mint = pid_minter2.mint

    expect(first_mint).not_to eq(second_mint)
  end

  it "correctly predicts the number of unique identifiers generated by a noid minter" do
    minter = described_class.new(template: 'cul:.ree')
    number_of_expected_mints = minter.template.max

    number_of_expected_mints.times { minter.mint }
    # The minter throws an exception when it runs out of mints
    expect { minter.mint }.to raise_error(Exception)
  end

  it "doesn't mint duplicates" do
    hsh = {}
    pid_minter = described_class.new(template: 'cul:.reee')
    number_of_expected_mints = pid_minter.template.max

    number_of_expected_mints.times { hsh[pid_minter.mint] = true }
    expect(hsh.length).to eql number_of_expected_mints
  end
end
