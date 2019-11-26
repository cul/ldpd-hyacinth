# frozen_string_literal: true

require 'rails_helper'

describe PidGenerator do
  let(:generator) do
    described_class.new(template: test_template, namespace: 'test')
  end
  describe ".get_namespace_from_pid" do
    subject { described_class.get_namespace_from_pid("toast:1") }
    it { is_expected.to eql("toast") }
  end
  describe ".get_pid_without_namespace" do
    subject { described_class.get_pid_without_namespace("toast:1") }
    it { is_expected.to eql("1") }
  end
  describe "#max_pids" do
    subject { generator.max_pids }
    let(:edigits) { 3 }
    let(:test_template) { edigits.times.inject(".r") { |m| m << "e" } }
    it { is_expected.to eql(29**edigits) }
  end
  describe "#next_pid" do
    subject { generator.next_pid }
    let(:test_template) { PidGenerator::DEFAULT_TEMPLATE }
    it { is_expected.to match(/^test:[0-9a-z]+/) }
  end
  describe "#set_template_if_blank_and_get_seed" do
    subject { generator.template }
    let(:test_template) { nil }
    before { generator.set_template_if_blank_and_get_seed }
    it { is_expected.to eql(PidGenerator::DEFAULT_TEMPLATE) }
  end
end
