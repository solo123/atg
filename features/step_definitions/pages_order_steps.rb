require 'ruby-debug'
require 'watir'

Given /^Signin as admin$/ do
  @host = "http://localhost:3000"
  @admin_url = "#{@host}/aeadmin"
  @browser ||= Watir::Browser.new :firefox 
  @browser.goto(@admin_url)
  if @browser.url == "#{@host}/employees/sign_in"
    @browser.text_field(:id, 'employee_login').set('test')
    @browser.text_field(:id, 'employee_password').set('aetravelusa.com')
    @browser.button(:value, 'Sign in').click
  end
  @browser.url.should == @admin_url
end
Given /^browse resource page (.+)$/ do |resource_name|
  @browser.goto("#{@admin_url}/#{resource_name}")
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

Then /^table (.+) have (\d+) rows?$/ do |table_id, num_rows|
  table = @browser.table(:id, table_id)
  table.should be_exists
  table.rows.count.should == num_rows.to_i
end 

Then /^check destination's operations$/ do
  table = @browser.table(:id, 'list_destinations')
  table.rows[1].link(:index, 0).click
  popup = @browser.window(:index, 1)
  popup.url.should == "#{@host}/destinations/1"
  popup.close

  table.rows[1].link(:index, 1).click
  sleep 2
  div = @browser.div(:id, 'edit_destination_div')
  div.should be_exists
  div.parent.link(:class, 'ui-dialog-titlebar-close').click

  @browser.execute_script "window.confirm=function(){return true;}"
  table.rows[1].link(:index, 2).click
  sleep 1
  table.rows[1].class_name.should == 'deleted'
  table.rows[1].link(:index, 2).click
  sleep 1
  table.rows[1].class_name.should be_blank

  table.rows[1].link(:index, 3).click
  sleep 2
  popup = @browser.window(:index, 1)
  popup.should be_exists
  popup.close
end

After do |scenario|
  @browser.close if @browser && @browser.exists?
end
