# frozen_string_literal: true

# Logs in user with no permissions and checks that the user does not have
# access to the given request.
shared_examples 'requires user to have correct permissions' do
  context 'when logged in user does not have appropriate permissions' do
    before do
      sign_in_user
      request
    end

    include_examples 'does not have access'
  end
end

shared_examples 'does not have access' do
  it 'returns 403' do
    expect(response.status).to be 403
  end

  it 'returns error' do
    expect(response.body).to be_json_eql(%(
      { "errors": [{ "title": "Forbidden" }] }
    ))
  end
end

shared_examples 'a basic user with no abilities is not authorized to perform this request' do |expected_message|
  context 'when logged in user does not have appropriate permissions' do
    before do
      sign_in_user
      request
    end

    it 'returns error' do
      expect(response.body).to be_json_eql(%(
        "#{expected_message || 'You are not authorized to access this page.'}"
      )).at_path('errors/0/message')
    end
  end
end
