# frozen_string_literal: true

module Hyacinth
  module BatchImport
    module IndexPrerequisiteMap
      # This method reads through the data in the given csv_file and generates a prerequisite map that
      # determines the order of processing, and which processing operations should be blocked by other
      # prerequisite operations.  The returned array looks something like this:
      # {
      #   4 => [3],    # 4 requires 3
      #   3 => [2],    # 3 requires 2
      #   2 => [1, 5], # 2 requires 1 and 5
      #   8 => [7],    # 8 requires 7
      #   7 => [2],    # 7 requires 2
      #   10 => [9]    # 10 requires 9
      # }
      def self.generate(csv_file)
        identifiers_to_row_numbers, row_numbers_to_parent_identifiers = generate_csv_identifier_maps(csv_file)
        row_numbers_to_parent_row_numbers = generate_row_numbers_to_parent_row_numbers_map(identifiers_to_row_numbers, row_numbers_to_parent_identifiers)
        processing_order_map = generate_processing_order_map(row_numbers_to_parent_row_numbers)
        index_prerequisite_map = generate_index_prerequisite_map(processing_order_map)

        # It's possible that the index_prerequisite_map may contain a circular dependency.
        # We don't want that because that will cause operations to block forever. Let's detect
        # circular dependencies and raise an error if we encounter one.

        raise_error_if_circular_dependency_found!(index_prerequisite_map)

        # Finally, return index_prerequisite_map
        index_prerequisite_map
      end

      # Converts the given processing_order_map into a map of import row numbers to prerequisite row
      # numbers, now taking sibling imports into consideration (which our earlier child-to-parent map
      # didn't take into account).  Continuing with earlier examples, it'll look something like this:
      # {
      #   4 => [3],    # 4 requires 3
      #   3 => [2],    # 3 requires 2
      #   2 => [1, 5], # 2 requires 1 and 5
      #   8 => [7],    # 8 requires 7
      #   7 => [2],    # 7 requires 2
      #   10 => [9]    # 10 requires 9
      # }
      # The generated map will NOT containy any references to UIDs. UIDs aren't
      # dependencies because they already exist, so we can treat rows with only UID dependencies
      # as ready for immediate processing.
      def self.generate_index_prerequisite_map(processing_order_map)
        index_prerequisite_map = {}
        processing_order_map.each do |parent_row_number, child_row_numbers|
          prerequisite_row_number = parent_row_number

          child_row_numbers.each do |child_row_number|
            # Remember: prerequisite_row_number will be an integer in most cases, but sometimes
            # it'll be a uid string to indicate that the dependency is an existing DigitalObject.
            # For existing digital objects, there's no reason to create an ImportPrerequisite, so we'll
            # ignore those entries when building the index_prerequisite_map.  They've already served
            # their purpose for placeholder ordering purposes.

            if prerequisite_row_number.is_a?(Integer)
              index_prerequisite_map[child_row_number] ||= []
              index_prerequisite_map[child_row_number] << prerequisite_row_number
            end

            # This child will be a prerequisite for the next child
            prerequisite_row_number = child_row_number
          end
        end
        index_prerequisite_map
      end

      # Converts the given row_numbers_to_parent_row_numbers map to a structure that also expresses
      # processing order, since multiple children that are being newly-linked to a parent need to be
      # processed in the order they appear in the spreadsheet (in order to set the desired order).
      # Example return value:
      # {
      #   1 => [2, 3, 4],
      #   5 => [2, 7, 8]
      #   '32c90e8a-7995-4c37-8c76-c2187546c745' => [9, 10]
      # }
      # The above example prerequisite map indicates the following.
      # - Row 1 is a parent of 2, 3, and 4, so 1 must be processed before 2, 3, and 4.
      # - For proper child order, row 2 must be processed before 3, and 3 must be processed before 4.
      # - Row 5 is a parent of 2, 7, and 8, so 5 must be processed before 2, 7, and 8.
      # - For proper child order, row 2 must be processed before 7, and 7 must be processed before 8.
      # - Since 2 depends on both 1 and 5, 2 will not be processed before BOTH 1 and 5 have been
      #   processed. Therefore 3, 4, 7, and 8 will also not be processed before 1 and 5 (and 2).
      # - Existing object with uid 32c90e8a-7995-4c37-8c76-c2187546c745 is a parent of 9 and 10. Nothing
      #   needs to be done for object 32c90e8a-7995-4c37-8c76-c2187546c745, but we still want to ensure
      #   that row 9 is processed before row 10 so they're both added to the existing parent object
      #   in the correct order.
      def self.generate_processing_order_map(row_numbers_to_parent_row_numbers)
        processing_order_map = {}
        row_numbers_to_parent_row_numbers.each do |row_number, parent_row_numbers|
          parent_row_numbers.each do |parent_row_number|
            processing_order_map[parent_row_number] ||= []
            processing_order_map[parent_row_number] << row_number
          end
        end
        processing_order_map
      end

      # Generates a map of row numbers to parent row numbers.
      # It could look something like this:
      #
      # {
      #   2 => [1, 5],
      #   3 => [1],
      #   4 => [1],
      #   7 => [5],
      #   8 => [5],
      #   9 => ['32c90e8a-7995-4c37-8c76-c2187546c745'],
      # }
      #
      # Explanation of above:
      # 2 requires parents 1 and 5
      # 3 requires parent 1
      # 4 requires parent 1
      # 7 requires parent 5
      # 8 requires parent 5
      # 9 requires an existing parent object (not in the CSV) with uid 32c90e8a-7995-4c37-8c76-c2187546c745
      def self.generate_row_numbers_to_parent_row_numbers_map(identifiers_to_row_numbers, row_numbers_to_parent_identifiers)
        row_numbers_to_parent_row_numbers = {}
        row_numbers_to_parent_identifiers.each do |row_number, parent_identifiers|
          # Remember: This row may have multiple parents, so that's why parent_row_numbers, below,
          # is an array rather than a single value.
          parent_row_numbers = []
          parent_identifiers_not_in_csv = []
          parent_identifiers.each do |identifier|
            if identifiers_to_row_numbers.key?(identifier)
              parent_row_numbers << identifiers_to_row_numbers[identifier]
            else
              parent_identifiers_not_in_csv << identifier
            end
          end

          # For any parent identifiers not found in the csv, let's check if they're referring to
          # existing digital object in Hyacinth.
          unresolvable_identifiers = []
          parent_identifiers_not_in_csv.each do |identifier|
            found_object_uids = Hyacinth::Config.digital_object_search_adapter.identifier_to_uids(identifier)
            if found_object_uids.blank?
              # If we found zero uids for the given identifier, that's not good because that
              # means the csv data refers to a parent that doesn't exist in the spreadsheet
              # and also doesn't exist in Hyacinth. We'll log this unresolvable identifier
              # and later on we'll raise an error.
              unresolvable_identifiers << identifier
              next
            elsif found_object_uids.length > 1
              # If we found more than one uid for the given identifier, that's not good because that
              # means we have an ambiguous parent reference. We'll raise an error.
              raise Hyacinth::Exceptions::BatchImportError,
                    "Ambiguous parent reference. Parent identifier #{identifier} was resolved to "\
                    "#{found_object_uids.length} objects in Hyacinth (#{found_object_uids.join(', ')}), "\
                    "so it's unclear which parent is being referenced."
            end

            # If we got here, that means we found just one uid for the given identifier. That's great.
            # We'll use that UID as the "parent row number" value in the map, and it will be treated
            # in a special way later on, differently than other numeric values.
            parent_row_numbers << identifiers_to_row_numbers[found_object_uids.first]
          end

          # Raise an error if we encountered any unresolvable identifiers
          if unresolvable_identifiers.present?
            raise Hyacinth::Exceptions::BatchImportError,
                  "The following parent identifiers could not be found in CSV data or "\
                  "among existing Hyacinth objects: #{unresolvable_identifiers.join(', ')}"
          end

          # If there are any duplicate values in parent_row_numbers, that indicates that the
          # spreadsheet data is trying to associate an object with the same parent twice, which
          # would be a mistake.  Raise an error in this (likely rare) case:
          if parent_row_numbers.length != parent_row_numbers.uniq.length
            raise Hyacinth::Exceptions::BatchImportError,
                  "Row #{row_number} contains multiple parent digital object values "\
                  "that refer to the the same parent."
          end

          row_numbers_to_parent_row_numbers[row_number] = parent_row_numbers unless parent_row_numbers.empty?
        end
        row_numbers_to_parent_row_numbers
      end

      # Parses the given csv_file and generates and returns two maps:
      # identifiers_to_row_numbers and row_numbers_to_parent_identifiers
      # @return Array<Hash, Hash> An identifiers_to_row_numbers Hash and a
      #                           row_numbers_to_parent_identifiers Hash.
      def self.generate_csv_identifier_maps(csv_file)
        identifiers_to_row_numbers = {}
        row_numbers_to_parent_identifiers = {}

        ::BatchImport.csv_file_to_hierarchical_json_hash(csv_file) do |json_hash_for_row, csv_row_number|
          identifiers = json_hash_for_row['identifiers'] || []
          # A uid is another kind of id, so we'll group it in with the other identifiers
          identifiers << json_hash_for_row['uid'] if json_hash_for_row['uid'].present?

          # Each of the found identifiers is associated with the current row, so we'll store that info.
          identifiers.each do |identifier|
            if identifiers_to_row_numbers.key?(identifier)
              raise Hyacinth::Exceptions::BatchImportError, "More than one row in the spreadsheet "\
                    "claims to have the same identifier: #{identifier}"
            end
            # Add idenfifier mapping
            identifiers_to_row_numbers[identifier] = csv_row_number
          end

          if json_hash_for_row['parents'].present?
            parent_identifiers = []
            json_hash_for_row['parents'].each do |parent_digital_object|
              parent_identifiers << parent_digital_object['identifier'] if parent_digital_object['identifier'].present?
              parent_identifiers << parent_digital_object['uid'] if parent_digital_object['uid'].present?
            end
            row_numbers_to_parent_identifiers[csv_row_number] = parent_identifiers unless parent_identifiers.empty?
          end
        end

        [identifiers_to_row_numbers, row_numbers_to_parent_identifiers]
      end

      # Raises an error if a circular dependency is found in the given index_prerequisite_map.
      # An couple of examples of circular dependencies include:
      # {
      #   20 => [19, 15], # 20 requires 19 and 15
      #   15 => [20],     # 15 requires 20
      # }
      # or:
      # {
      #   20 => [19], # 20 requires 19
      #   19 => [18], # 19 requires 18
      #   18 => [20]  # 18 requires 20
      # }
      def self.raise_error_if_circular_dependency_found!(index_prerequisite_map)
        index_prerequisite_map.each do |row_number, prerequisite_row_numbers|
          seen = []
          seen << row_number
          recurse_hierarchy(index_prerequisite_map, prerequisite_row_numbers) do |encountered_row_number|
            if seen.include?(encountered_row_number)
              raise Hyacinth::Exceptions::BatchImportError,
                    "Prerequisite circular dependency detected in csv data, "\
                    "starting at row: #{row_number}"
            end
            seen << encountered_row_number
          end
        end
      end

      # Traverses an index_prerequisite_map, starting at the given array of row_numbers,
      # and yields each number and its prerequisites as it follows the prerequisite hierarchy.
      def self.recurse_hierarchy(index_prerequisite_map, row_numbers, &block)
        row_numbers.each do |row_number|
          block.yield row_number
          prerequisite_row_numbers = index_prerequisite_map[row_number]
          recurse_hierarchy(index_prerequisite_map, prerequisite_row_numbers, &block) if prerequisite_row_numbers.present?
        end
      end
    end
  end
end
