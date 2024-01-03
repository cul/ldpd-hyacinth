class PidGenerator < ApplicationRecord
  has_many :projects
  before_validation :set_template_if_blank_and_get_seed, on: :create

  DEFAULT_TEMPLATE = '.reeeeeeeeee'
  VALID_NAMESPACE_REGEX = /\A([A-Za-z0-9-]+)\z/
  VALID_PID_WITHOUT_NAMESPACE_REGEX = /\A([0123456789bcdfghjkmnpqrstvwxz_-]+)\z/

  validates :namespace, presence: true, uniqueness: true, allow_blank: false, allow_nil: false
  validate :validate_sample_mint

  def self.default_pid_generator
    @default_pid_generator || PidGenerator.find_by(namespace: HYACINTH[:default_pid_generator_namespace])
  end

  def self.get_namespace_from_pid(pid)
    # TODO: match can return nil
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
    Noid::Minter.new(template: namespace + ':' + template).template.max
  end

  def next_pid
    current_pid_generator_sequence = nil

    # Put a read lock on the row, and reload the pid_generator row from the db
    with_lock do
      # Get the current sequence value
      current_pid_generator_sequence = self.sequence
      # Increment the sequence so this number will never be used for generating another PID
      increment!(:sequence)
    end

    begin
      pid_minter = Noid::Minter.new(template: namespace + ':' + template)
    rescue StandardError
      raise 'PID Generator ' + namespace + ' has run out of unique ids.  Please use a different PID Generator for future Digital Objects.'
    end

    # Use existing seed to generate a new pid
    pid_minter.seed(seed.to_i, current_pid_generator_sequence)
    newly_minted_pid = pid_minter.mint

    raise 'Unexpected error during PID generation.  Value of pid is nil.' if newly_minted_pid.nil?

    if ActiveFedora::Base.exists?(newly_minted_pid)
      # Check to see if an object in Fedora already exists with this PID
      Hyacinth::Utils::Logger.logger.info 'PID ' + newly_minted_pid + ' already exists in Fedora. Generating new PID.'

      # Generate a new pid
      newly_minted_pid = next_pid
    end

    newly_minted_pid
  end

  def set_template_if_blank_and_get_seed
    self.template = DEFAULT_TEMPLATE if template.blank?
    minter = Noid::Minter.new(template: namespace + ':' + template)
    # removed legacy behavior called no arguments - which is the same as generating a new seed
    # Doing .seed.seed because the first .seed call actually returns a Random object instance
    self.seed = minter.seed(Random.new_seed, 0).seed
  end

  def validate_sample_mint
    # Make sure that the namespace and template generate a PID that meets our regex specifications

    # We're only allowing certain characters to conform to Fedora PID namespace expectations.
    test_mint_pid = Noid::Minter.new(template: namespace + ':' + template).mint
    test_mint_pid_namespace = PidGenerator.get_namespace_from_pid(test_mint_pid)
    test_mint_pid_without_namespace = PidGenerator.get_pid_without_namespace(test_mint_pid)

    validate_sample_ns(test_mint_pid_namespace)

    validate_sample_id_part(test_mint_pid_without_namespace)
  end

  def validate_sample_ns(test_mint_pid_namespace)
    return if test_mint_pid_namespace.match(VALID_NAMESPACE_REGEX)
    errors[:namespace] = "Invalid namespace.  Failed regex test: #{VALID_NAMESPACE_REGEX}.  Generated test PID: #{test_mint_pid}"
  end

  def validate_sample_id_part(test_mint_pid_without_namespace)
    return if test_mint_pid_without_namespace.match(VALID_PID_WITHOUT_NAMESPACE_REGEX)
    errors[:template] = "Invalid post-namespace template.  Failed regex test: #{VALID_PID_WITHOUT_NAMESPACE_REGEX}.  Generated test PID: #{test_mint_pid}"
  end
end
