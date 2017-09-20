require 'spec_helper'

describe SitesController do
  describe '#show' do
    it "requires OAuth authentication" do
      get :show, user: 'pat', repo: 'riddle', path: 'index.html'

      expect(response).to redirect_to('/auth/github')
    end

    it "is successful with an active OAuth session" do
      session[:omniauth] = {'foo' => 'bar'}

      get :show, user: 'pat', repo: 'riddle', path: 'index.html'

      expect(response).to be_success
    end
  end

  describe '#update' do
    def send_update
      put :update, user: 'pat', repo: 'riddle', path: 'index.html',
        contents: 'cleared', subject: 'docs need rewriting',
        description: 'here is a start'
    end

    before :each do
      Gyoza::Workers::ChangeWorker.stub :perform_async => true

      session[:omniauth] = {'info' => {
        'nickname' => 'parndt',
        'email'    => 'phil@arn.dt',
        'name'     => 'Philip Arndt'
      }}

      request.env['HTTP_REFERER'] = '/original/path'
    end

    it "requires OAuth authentication" do
      session[:omniauth] = nil

      send_update

      expect(response).to redirect_to('/auth/github')
    end

    it "queues a change with an active OAuth session" do
      expect(Gyoza::Workers::ChangeWorker).to receive(:perform_async).with(
        author:      'Philip Arndt <phil@arn.dt>',
        user:        'pat',
        repo:        'riddle',
        file:        'index.html',
        contents:    'cleared',
        subject:     'docs need rewriting',
        description: 'here is a start',
        nickname:    'parndt'
      ).and_return true

      send_update
    end

    it "uses the nickname if no name is set" do
      session[:omniauth]['info'].delete 'name'

      expect(Gyoza::Workers::ChangeWorker).to receive(:perform_async).with(
        author:      'parndt <phil@arn.dt>',
        user:        'pat',
        repo:        'riddle',
        file:        'index.html',
        contents:    'cleared',
        subject:     'docs need rewriting',
        description: 'here is a start',
        nickname:    'parndt'
      ).and_return true

      send_update
    end

    it "redirects back to the previous page" do
      send_update

      expect(response).to redirect_to('/original/path')
    end
  end
end
