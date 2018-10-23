class API::V2::UsersController < ActionController::Base
  def index
    render(json:
      {
        items: ::User.all.map { |user| user.describe }
      })
  end
end
