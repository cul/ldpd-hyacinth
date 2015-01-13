class ControlledVocabulary < ActiveRecord::Base
  belongs_to :pid_generator
  has_many :authorized_terms

  before_create :create_associated_fedora_object!

  def next_pid
    self.pid_generator.next_pid
  end

  def create_associated_fedora_object!
    pid = self.next_pid
    bag_aggregator = BagAggregator.new(:pid => pid)

    bag_aggregator.datastreams["DC"].dc_identifier = [pid]
    bag_aggregator.datastreams["DC"].dc_type = 'ControlledVocabulary'
    bag_aggregator.datastreams["DC"].dc_title = 'ControlledVocabulary: ' + self.display_label
    bag_aggregator.label = bag_aggregator.datastreams["DC"].dc_title[0]
    bag_aggregator.save

    self.pid = bag_aggregator.pid
  end

end
