class PidGenerator < ActiveRecord::Base
  has_many :projects
  before_validation :set_template_if_blank_and_get_seed, :on => :create

  DEFAULT_TEMPLATE = '.reeeeeeeeee'
  VALID_NAMESPACE_REGEX = /\A([A-Za-z0-9-]+)\z/
  VALID_PID_WITHOUT_NAMESPACE_REGEX = /\A([0123456789bcdfghjkmnpqrstvwxz_-]+)\z/

  validates :namespace, presence: true, uniqueness: true, allow_blank: false, allow_nil: false
  validate :validate_sample_mint

  def self.get_namespace_from_pid(pid)
    captures = pid.match(/(.+):.+/).captures
    if captures.length == 1
      return captures[0]
    else
      return nil
    end
  end

  def self.get_pid_without_namespace(pid)
    captures = pid.match(/.+:(.+)/).captures
    if captures.length == 1
      return captures[0]
    else
      return nil
    end
  end

  def max_pids
    return Noid::Minter.new(:template => self.namespace + ':' + self.template).template.max
  end

  def next_pid

    newly_minted_pid = nil

    PidGenerator.transaction do

      # We always lock on @db_record (and wrap in a transaction)
      self.lock! # Within the established transaction, lock on this object's row.  Remember: "lock!" also reloads object data from the db, so perform all modifications AFTER this call.

      begin
        pid_minter = Noid::Minter.new(:template => self.namespace + ':' + self.template)
      rescue Exception => e
        raise 'PID Generator ' + self.namespace + ' has run out of unique ids.  Please use a different PID Generator for future Digital Objects.'
      end

      pid_minter.seed(self.seed.to_i, self.sequence)
      newly_minted_pid = pid_minter.mint

      self.increment!(:sequence)
      self.save
    end

    if newly_minted_pid.nil?
      raise 'Unexpected error during PID generation.'
    else
      # Verify that this PID has not been used before
      begin
        if ActiveFedora::Base.exists?(newly_minted_pid)
          # If Fedora is available, check to see if an object in Fedora already exists with this PID
          puts 'PID ' + newly_minted_pid + ' already exists in Fedora.  Generating new PID.'

          # Generate a new pid
          newly_minted_pid = self.next_pid
        end
      rescue Errno::ECONNREFUSED => e
        raise 'Fedora is unavailable, so it was not possible to check whether an object with PID ' + newly_minted_pid  + ' exists.'
      end
    end

    return newly_minted_pid
  end

  def set_template_if_blank_and_get_seed
    self.template = DEFAULT_TEMPLATE if self.template.blank?
    minter = Noid::Minter.new(:template => self.namespace + ':' + self.template)
    self.seed = minter.seed.seed # Doing .seed.seed because the first .seed call actually returns a Random object instance
  end

  def validate_sample_mint
    # Make sure that the namespace and template generate a PID that meets our regex specifications

    # We're only allowing certain characters to conform to Fedora PID namespace expectations.
    test_mint_pid = Noid::Minter.new(:template => self.namespace + ':' + self.template).mint
    test_mint_pid_namespace = PidGenerator.get_namespace_from_pid(test_mint_pid)
    test_mint_pid_without_namespace = PidGenerator.get_pid_without_namespace(test_mint_pid)

    unless test_mint_pid_namespace.match(VALID_NAMESPACE_REGEX)
      self.errors[:namespace] = "Invalid namespace.  Failed regex test: #{VALID_NAMESPACE_REGEX.to_s}.  Generated test PID: #{test_mint_pid}"
    end

    unless test_mint_pid_without_namespace.match(VALID_PID_WITHOUT_NAMESPACE_REGEX)
      self.errors[:template] = "Invalid post-namespace template.  Failed regex test: #{VALID_PID_WITHOUT_NAMESPACE_REGEX.to_s}.  Generated test PID: #{test_mint_pid}"
    end

  end

end
