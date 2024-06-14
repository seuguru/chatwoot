class Webhooks::GurupassBotController < ActionController::API
  def create
    return if params['message_type'] == 'outgoing'

    message = params.dig('conversation', 'messages').first
    conversation_id = message['conversation_id']
    inbox_id = message['inbox_id']
    account_id = message['account_id']
    conversation = Conversation.where(display_id: conversation_id)
    phone = conversation.contact&.phone_number

    response = recognize_text(conversation, params['content'])

    messages = response.messages

    messages.each do |msg|
      content_type = nil
      items = []
      content = msg.content

      if msg.content_type == 'CustomPayload'
        msg_json = JSON.parse(msg.content)
        content = msg_json['text']
        if msg_json.key?('buttons')
          content_type = 'input_select'
          items = msg_json['buttons'].map { |button| { title: button['title'], value: button['payload'] } }
        end
        if msg_json.key?('action') && (msg_json['action'] == 'handoff')
          event = Events::Base.new('conversation.bot_handoff', Time.zone.now, conversation: conversation)
        end
      end
      Message.create!(content: content, conversation_id: conversation.id, inbox_id: inbox_id, account_id: account_id, message_type: :outgoing,
                      content_type: content_type, content_attributes: { items: items })
    end
  rescue Exception => e
    Rails.logger.error "Erro: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  private

  def recognize_text(conversation, text)
    phone = conversation.contact&.phone_number || nil
    user = find_user_by_phone(phone)

    session_attributes = {}
    if user
      session_attributes['userName'] = user[:name] if user
      session_attributes['userPhone'] = phone if phone
      session_attributes['userId'] = user[:id] if user
      session_attributes['isCustomer'] = user.present?.to_s
      session_attributes['userStatus'] = user[:user_status] if user
      session_attributes['phoneChecked'] = user[:phone_checked] if user
    end

    lex_client.recognize_text(bot_id: ENV.fetch('BOT_ID'), bot_alias_id: ENV.fetch('BOT_ALIAS_ID'), locale_id: 'pt_BR', session_id: (conversation.id * 10).to_s, text: text,
                              session_state: { session_attributes: session_attributes })
  end

  def lex_client
    client = Aws::LexRuntimeV2::Client.new(region: ENV.fetch('AWS_REGION', nil), access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
                                           secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil))
  end

  def get_user(user_id)
    url = "#{base_url}/users/#{user_id}"
    headers = {
      'Authorization': "Bearer #{admin_token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get(url, headers: headers)
  end

  def admin_token
    ENV.fetch('ADMIN_TOKEN', nil)
  end

  def base_url
    ENV.fetch('ADMIN_URL', nil)
  end

  def find_user_by_phone(phone)
    base_url = ENV.fetch('ADMIN_URL', nil)
    url = "#{base_url}/users/filter?filter[0][value]=#{phone}&filter[0][path]=phone&filter[0][type]=string&select=id name cpf email phone paymentForm toDeleteAt"
    headers = {
      'Authorization': "Bearer #{admin_token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get(url, headers: headers)

    user = response.first

    return unless user.is_a?(Hash) && user.key?('id')

    user_complete = get_user(user['id'])
    user_status = get_user_status(user_complete['subscriptions'])

    { id: user['id'], name: user['name'], email: user['email'], phone: user['phone'], user_status: user_status, is_customer: user.present?,
      phone_checked: user_complete['phoneChecked'].to_s }
  end

  def get_user_status(subscriptions)
    is_customer = subscriptions.any?
    has_active_subscription = subscriptions.any? { |subscription| subscription['status'] == 'active' }
    has_cancelled_subscription = subscriptions.any? { |subscription| subscription['status'] == 'cancelled' }
    has_suspended_subscription = subscriptions.any? { |subscription| subscription['status'] == 'suspended' }
    return 'active' if has_active_subscription
    return 'suspended' if has_suspended_subscription
    return 'cancelled' if has_cancelled_subscription

    'lead'
  end
end
