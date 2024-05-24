class Webhooks::GurupassBotController < ActionController::API
  def create
    return if params['message_type'] == 'outgoing'

    response = RestClient.post('http://localhost:5005/webhooks/rest/webhook', { sender: '', message: params['content'] }.to_json,
                               { content_type: :json, accept: :json })
    body = JSON.parse(response.body)
    message = params.dig('conversation', 'messages').first
    conversation_id = message['conversation_id']
    inbox_id = message['inbox_id']
    account_id = message['account_id']

    body.each do |msg|
      Message.create!(content: msg['text'], conversation_id: conversation_id, inbox_id: inbox_id, account_id: account_id, message_type: :outgoing)
    end
  end
end
