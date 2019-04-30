module ChoiceSetHelper
  def select_choice(container, choice)
    find(container).click
    find("li", :text => choice).click
    find("body").click
  end
end
