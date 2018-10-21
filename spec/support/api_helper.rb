module ApiHelper
  
  def parsed_body
    JSON.parse response.body
  end

  %i(post get put patch head delete).each do |verb|
    define_method "j#{verb}" do |path, params = {}, headers = {}|
      if %i(post put patch).include?(verb)
        headers = headers.merge('Content-Type' => 'application/json') unless params.empty?
        params = params.to_json
      end
      # byebug
      self.send(verb,
                path,
                params: params,
                headers: headers.merge(access_tokens))
    end
  end

  def signup(reg, status = :ok)
    jpost user_registration_path, reg
    expect(response).to have_http_status status
    payload = parsed_body
    reg.merge(id: payload['data']['id'], uid: payload['data']['uid']) if response.ok?
  end

  def login(credentials, status = :ok) 
    jpost user_session_path, credentials.slice(:username, :password)
    # pp parsed_body
    # byebug
    expect(response).to have_http_status status
    response.ok? ? parsed_body['data'] : parsed_body
  end

  def logout status=:ok
    jdelete destroy_user_session_path
    @last_tokens = {}
    expect(response).to have_http_status status if status
  end

  def access_tokens?
    !response.headers['access-token'].nil? if response
  end

  def access_tokens
    if access_tokens?
      @last_tokens = %W(uid client token-type access-token).inject({}) { |mem, var| mem[var] = response.headers[var]; mem }
    end
    @last_tokens || {}
  end
end
