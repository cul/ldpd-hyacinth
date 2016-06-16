module Hyacinth::DigitalObjects::ParentEditorBehavior
  def add_parent
    errors = validate_parent_pid(params[:parent_pid])

    if errors.blank?
      begin
        parent_digital_object = DigitalObject::Base.find(params[:parent_pid])
        validate_parent_type(parent_digital_object, errors)

        if saveable?(errors)
          @digital_object.add_parent_digital_object(parent_digital_object)
          @digital_object.save
        end
      rescue Hyacinth::Exceptions::DigitalObjectNotFoundError
        errors << 'Could not find Digital Object with PID: ' + params[:parent_pid]
      end
    end

    errors += @digital_object.errors.to_a

    if errors.present?
      response = { success: false, errors: errors }
    else
      response = { success: true }
    end

    respond_to do |format|
      format.json { render json: response }
    end
  end

  def validate_parent_pid(parent_pid)
    errors = []
    errors << "An object cannot be its own parent.  That's crazy!" if @digital_object.pid == parent_pid
    errors << "Object already has parent: #{params[:parent_pid]}" if @digital_object.parent_digital_object_pids.include?(parent_pid)
    errors
  end

  def validate_parent_type(parent_digital_object, errors = [])
    # If child is Asset, then parent must be Item
    # If child is Item or Group, then parent must be Group
    if @digital_object.is_a?(DigitalObject::Asset)
      errors << "Parent must be an Item or FileSystem" unless parent_digital_object.is_a?(DigitalObject::Item) || parent_digital_object.is_a?(DigitalObject::FileSystem)
    elsif !parent_digital_object.is_a?(DigitalObject::Group)
      errors << "Parent must be a Group"
    end
    errors
  end

  def remove_parents
    errors = []

    errors << 'You must specify at least one pid to remove.' if params[:parent_pids].blank?

    if errors.blank?
      begin
        params[:parent_pids].each do |pid|
          parent_digital_object = DigitalObject::Base.find(pid)
          @digital_object.remove_parent_digital_object(parent_digital_object)
        end

        @digital_object.save if self.saveable?(errors)
      rescue Hyacinth::Exceptions::DigitalObjectNotFoundError
        errors << 'Could not find Digital Object with PID: ' + params[:parent_pid]
      end
    end

    errors += @digital_object.errors.to_a

    if errors.present?
      response = { success: false, errors: errors }
    else
      response = { success: true }
    end

    respond_to do |format|
      format.json { render json: response }
    end
  end
end
