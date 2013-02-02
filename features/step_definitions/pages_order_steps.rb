Given /^Signin as admin$/ do
  emp = FactoryGirl.create(:admin_employee_info)
  visit '/employees/sign_in'
  fill_in 'Login', :with => 'test'
  fill_in 'Password', :with => 'aetravelusa.com'
  click_button 'Sign in'
  page.should have_content 'Signed in successfully.'
end
Given /^browse (.+)$/ do |page_name|
  visit path_to(page_name)
end
Given /^visit (.+)$/ do |page_url|
  visit page_url
end
Given /^goto order page$/ do
  order = FactoryGirl.create(:valid_new_order)
  visit admin_order_path(order)
  find('.barcode').should have_content order.order_number
end
Then /^I should have the selector "([^"]*)"$/ do |selector|
  page.should have_table selector
end
