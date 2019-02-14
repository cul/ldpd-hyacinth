module Hyacinth
  module Utils
    module HashPath
      # Given a base_path and string identifier, generates a new path that starts
      # with the base path and ends with two-by-two character pairs of the hashed
      # version of the identifier.
      # Example return value: #{base_path}/ba/78/16/bf/8f/01/ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
      # @param base_path a string file path
      # @param identifier a string object id
      def self.hash_path(base_path, identifier)
        hexdigest = Digest::SHA256.hexdigest(identifier)
        File.join(
          base_path,
          hexdigest[0...2],
          hexdigest[2...4],
          hexdigest[4...6],
          hexdigest[6...8],
          hexdigest[8...10],
          hexdigest[10...12],
          hexdigest
        )
      end
    end
  end
end
