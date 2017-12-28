require 'rails_helper'

describe DigitalObject::Publishing do
  let(:pubtarget_a) {
    a = double(pid: 'pubtarget:a')
    allow(a).to receive(:[]).with('pid').and_return('pubtarget:a')
    allow(DigitalObject::Base).to receive(:find).with('pubtarget:a').and_return(a)
    a
  }
  let(:pubtarget_b) {
    b = double(pid: 'pubtarget:b')
    allow(b).to receive(:[]).with('pid').and_return('pubtarget:b')
    allow(DigitalObject::Base).to receive(:find).with('pubtarget:b').and_return(b)
    b
  }
  let(:pubtarget_c) {
    c = double(pid: 'pubtarget:c')
    allow(c).to receive(:[]).with('pid').and_return('pubtarget:c')
    allow(DigitalObject::Base).to receive(:find).with('pubtarget:c').and_return(c)
    c
  }

  let(:digital_object) {
    DigitalObject::Item.new.tap do |obj|
      allow(obj).to receive(:before_publish).and_return(true)
      allow(obj).to receive(:fedora_object).and_return(double(save: true))
      allow(obj).to receive(:allowed_publish_targets).and_return([pubtarget_a, pubtarget_b, pubtarget_c])
      allow(obj).to receive(:project).and_return(double(primary_publish_target_pid: pubtarget_a.pid))
    end
  }

  describe '#publish' do
    subject(:publish) { digital_object.publish }

    it 'publishes to primary target' do
      allow(digital_object).to receive(:publish_target_pids).and_return ['pubtarget:a']
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_b, false).ordered
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_c, false).ordered
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a, true).ordered
      publish
    end

    it 'publishes to non-primary target' do
      allow(digital_object).to receive(:publish_target_pids).and_return ['pubtarget:b']
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_a, true).ordered
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_c, false).ordered
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_b, false).ordered
      publish
    end

    it 'publishes to all targets' do
      allow(digital_object).to receive(:publish_target_pids).and_return ['pubtarget:a', 'pubtarget:b', 'pubtarget:c']
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_a, true).ordered
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_b, false).ordered
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:publish, pubtarget_c, false).ordered
      publish
    end
  end


  describe '#unpublish_all' do
    before do
      digital_object.publish_target_pids = ['pubtarget:a', 'pubtarget:b', 'pubtarget:c']
    end

    subject(:unpublish_all) { digital_object.unpublish_all }

    it 'unpublishes from all publishes targets' do
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_a, true)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_b, false)
      expect(digital_object).to receive(:execute_publish_action_for_target).with(:unpublish, pubtarget_c, false)
      unpublish_all
      expect(digital_object.publish_target_pids).to be_blank
    end
  end

  describe '#execute_publish_action_for_target'
end
