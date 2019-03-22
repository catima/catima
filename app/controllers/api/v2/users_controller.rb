class API::V2::UsersController < ApplicationController
  def index
    render(json:
      {
        items: ::User.all.map(&:describe)
      })
  end
end
