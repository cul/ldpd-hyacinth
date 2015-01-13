module Hyacinth::DigitalObjectsController::ReorderBehavior
  extend ActiveSupport::Concern

  # GET /digital_objects/1/reorder_child_digital_objects
  # POST /digital_objects/1/reorder_child_digital_objects
  def reorder_child_digital_objects

    if params[:commit]

      # Do reorder
      digital_object_memberships_to_reorder = params[:digital_object_memberships_to_reorder] || []

      digital_object_memberships_to_reorder.each do |digital_object_membership_id, new_sort_order|

        digital_object_membership = DigitalObjectMembership.find(digital_object_membership_id)
        raise 'Could not find DigitalObjectMembership with id: ' + digital_object_membership_id if digital_object_membership.blank?
        raise 'Cannot reorder: Digital Object with pid: ' + digital_object_membership.digital_object.pid + ' is not a child of Digital Object with pid ' + @digital_object.pid if digital_object_membership.parent_digital_object_id != @digital_object.id

        digital_object_membership.update(sort_order: digital_object_memberships_to_reorder[digital_object_membership_id]['sort_order'])
      end

      flash[:notice] = 'Child Digital Object order has been updated.'
    end

    @digital_object_memberships = DigitalObjectMembership.where(parent_digital_object: @digital_object).order(:sort_order)

  end

end
