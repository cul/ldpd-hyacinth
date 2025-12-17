class Api::V2::UsersController < Api::V2::BaseController
  # Temporarily skip authentication since we're using mock data
  skip_before_action :verify_authenticity_token
  skip_before_action :require_authenticated_user!

  def index
    render json: { 
      users: [
        {
          uid: "admin",
          first_name: "admin",
          last_name: "role",
          email: "admin@example.com",
          is_admin: true,
          is_active: true,
          can_manage_all_controlled_vocabularies: true,
          account_type: 0,
          sign_in_count: 8,
          current_sign_in_at: "2025-12-17T10:30:00Z",
          last_sign_in_at: "2025-12-16T15:20:00Z",
          current_sign_in_ip: "192.168.1.1",
          last_sign_in_ip: "192.168.1.1",
          created_at: "2024-01-15T08:00:00Z",
          updated_at: "2025-12-17T10:30:00Z"
        },
        {
          uid: "nonadmin1",
          first_name: "nonadmin1",
          last_name: "role",
          email: "nonadmin1@example.com",
          is_admin: false,
          is_active: true,
          can_manage_all_controlled_vocabularies: false,
          account_type: 0,
          sign_in_count: 15,
          current_sign_in_at: "2025-12-15T14:00:00Z",
          last_sign_in_at: "2025-12-10T09:00:00Z",
          current_sign_in_ip: "192.168.1.2",
          last_sign_in_ip: "192.168.1.2",
          created_at: "2024-06-20T12:30:00Z",
          updated_at: "2025-12-15T14:00:00Z"
        },
        {
          uid: "service_user",
          first_name: "service",
          last_name: "user",
          email: "service_user@example.com",
          is_admin: false,
          is_active: false,
          can_manage_all_controlled_vocabularies: false,
          account_type: 1,
          sign_in_count: 3,
          current_sign_in_at: "2025-10-01T11:15:00Z",
          last_sign_in_at: "2025-09-28T16:30:00Z",
          current_sign_in_ip: "192.168.1.3",
          last_sign_in_ip: "192.168.1.3",
          created_at: "2025-09-01T09:00:00Z",
          updated_at: "2025-11-01T10:00:00Z"
        }
      ] 
    }
  end
end