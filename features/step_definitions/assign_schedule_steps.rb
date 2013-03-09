Given /^a tour$/ do
  @tour = FactoryGirl.create(:tour)
end
Given /^a day$/ do
  @day = '2013-12-31'.to_date
end
When /^generate tour's schedule$/ do
  @tour.schedules.destroy_all
  @tour.schedules.where(:departure_date => @day).should be_empty
  @tour.gen_schedule(@day)
end
Then /^schedule generated$/ do
  schedule = @tour.schedules.where(:departure_date => @day).first
  schedule.should_not be_nil
  schedule.assignments.should_not be_empty
end

