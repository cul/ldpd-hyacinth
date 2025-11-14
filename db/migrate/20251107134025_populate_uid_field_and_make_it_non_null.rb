class PopulateUidFieldAndMakeItNonNull < ActiveRecord::Migration[7.0]
  def change
    # Then populate all of the uid fields, based on existing email addresses
    User.find_each do |user|
      uid = user.email.gsub(/@.+/, '')
      user.update!(uid: uid)
    rescue ActiveRecord::RecordNotUnique
      # To guarantee that this migration never fails, we'll handle the (unlikely)
      # case of having two users with the same email address string before their @-sign.
      user.update!(uid: "#{uid}-#{user.id}")
    end

    # Then switch the uid field to non-null
    change_column_null :users, :uid, false
  end
end
