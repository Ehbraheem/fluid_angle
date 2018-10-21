require 'rails_helper'

RSpec.describe "User Authentication API", type: :request do
  include_context 'db_cleanup_each', :transaction
  let(:user_attr) { FactoryGirl.attributes_for :user }

  context 'sign-up' do
    context 'valid registration' do
      it 'successfully creates account' do
        signup user_attr

        payload = parsed_body
        expect(payload).to include 'status' => 'success'
        expect(payload).to include 'data'
        expect(payload['data']).to include 'id'
        expect(payload['data']).to include 'provider' => 'email'
        expect(payload['data']).to include 'uid' => user_attr[:email]
        expect(payload['data']).to include 'name' => user_attr[:name]
        expect(payload['data']).to include 'email'=> user_attr[:email]
        expect(payload['data']).to include 'created_at', 'updated_at'
      end
    end

    context 'invalid registration' do
      context 'missing information' do
        it 'reports error with messages' do
          signup user_attr.except(:email), :unprocessable_entity

          payload = parsed_body
          expect(payload).to include 'status' => 'error'
          expect(payload).to include 'data'
          expect(payload).to include 'errors'
          expect(payload['data']).to include 'email'=> nil
          expect(payload['errors']).to include 'email'
          expect(payload['errors']).to include 'full_messages'
          expect(payload['errors']['full_messages']).to include /email/i
        end
      end

      context 'non-unique information' do
        it 'reports non-unique e-mail' do
          signup user_attr
          signup user_attr, :unprocessable_entity

          payload = parsed_body
          expect(payload).to include 'status' => 'error'
          expect(payload).to include 'data'
          expect(payload).to include 'errors'
          expect(payload['errors']).to include 'email'
          expect(payload['errors']).to include 'full_messages'
          expect(payload['errors']['full_messages']).to include /email/i
        end
      end
    end
  end

  context 'anonymous user' do
    it 'accesses unprotected' do
      get auth_whoami_path
      expect(response).to have_http_status :ok
    end
    it 'fails to access protected resource' do
      get auth_checkme_path
      expect(response).to have_http_status :unauthorized
      expect(parsed_body).to include 'errors' => ['You need to sign in or sign up before continuing.']
    end
  end

  context 'login' do
    let(:account) { signup user_attr, :ok }
    let!(:user) { login account, :ok }

    context 'valid user login' do
      it 'generates access token' do
        # byebug
        # byebug
        expect(response.headers['uid']).to eq account[:uid]
        expect(response.headers).to include 'access-token'
        expect(response.headers).to include 'client'
        expect(response.headers['token-type']).to eq 'Bearer'
      end
      it 'extracts access headers' do
        expect(access_tokens?).to be true
        expect(access_tokens).to include 'uid' => account[:uid]
        expect(access_tokens).to include 'access-token'
        expect(access_tokens).to include 'client'
        expect(access_tokens).to include 'token-type' => 'Bearer'
      end
      it 'grants access to resource' do
        jget auth_checkme_path
        expect(response).to have_http_status :ok

        payload = parsed_body
        expect(payload).to include('id' => account[:id])
        expect(payload).to include('uid' => account[:uid])
      end
      it 'grants access to resource multiple times' do
        (1..10).each do |idx|
          jget auth_checkme_path
          expect(response).to have_http_status :ok
        end
      end
      it 'logout' do
        logout :ok
        expect(access_tokens?).to be false

        jget auth_checkme_path
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'invalid password' do
      it 'rejects credentials' do
        logout :ok

        login account.merge(password: 'bad pws'), :unauthorized
        jget auth_checkme_path
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end