shared_examples 'authentication required' do |method, path|
  context 'when request does not include authentication' do
    before { send(method, path) }

    it 'returns error' do
      expect(JSON.parse(response.body)).to match('errors' => [ { 'title' => 'Unauthorized' } ])
    end

    it 'returns 401' do
      expect(response.status).to be 401
    end
  end
end
