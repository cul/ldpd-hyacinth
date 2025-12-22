export interface User {
  uid: string;
  first_name: string;
  last_name: string;
  email: string;
  is_admin: boolean;
  is_active: boolean;
  can_manage_all_controlled_vocabularies: boolean;
  account_type: number;
  sign_in_count: number;
  current_sign_in_at: string;
  last_sign_in_at: string;
  current_sign_in_ip: string;
  last_sign_in_ip: string;
  created_at: string;
  updated_at: string;
}