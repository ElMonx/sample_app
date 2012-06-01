include ApplicationHelper

# Methods

def valid_signin(user)
	fill_in "Email",		with: user.email
	fill_in "Password", 	with: user.password
	click_button "Sign in"
	# Sign in when not using Capybara as well.
	cookies[:remember_token] = user.remember_token
end

def valid_user_fill_in(user_data = {})
	fill_in "Name",			with: user_data[:name] || "Example User"
	fill_in "Email",		with: user_data[:email] || "user@example.com"
	fill_in "Password",		with: user_data[:password] || "foobar"
	fill_in "Confirmation",	with: user_data[:confirmation] || "foobar"
end

def valid_signup
	valid_user_fill_in({})
	click_button submit
end

# Rspec Custom Matchers

RSpec::Matchers.define :have_error_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-error', text: message)
	end
end

RSpec::Matchers.define :have_success_message do |message|
	match do |page|
		page.should have_selector('div.alert.alert-success', text: message)
	end
end

RSpec::Matchers.define :have_title do |title|
	match do |page|
		page.should have_selector('title', text: title)
	end
end

RSpec::Matchers.define :have_level1_header do |text|
	match do |page|
		page.should have_selector("h1", text: text)
	end
end