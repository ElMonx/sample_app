require 'spec_helper'

describe "User pages" do

	subject { page }

	describe "index" do
		let(:user) { FactoryGirl.create(:user) }

		before(:all) { 30.times { FactoryGirl.create(:user) } }
		after(:all) { User.delete_all }
		before(:each) do
			visit signin_path
			valid_signin(FactoryGirl.create(:user))
			visit users_path
		end

		it { should have_title("All users") }
		it { should have_level1_header("All users") }

		describe "pagination" do
			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1).each do |user|
					page.should have_selector('li', text: user.name)
				end
			end
		end

		describe "delete links" do
			it { should_not have_link('delete') }

			describe "as an admin user" do
				let(:admin) { FactoryGirl.create(:admin) }
				before do
					visit signin_path
					valid_signin admin
					visit users_path
				end

				it { should have_link('delete', href: user_path(User.first)) }
				it "should be able to delete another user" do
					expect { click_link('delete') }.to change(User, :count).by(-1)
				end
				it { should_not have_link('delete', href: user_path(admin)) }
			end
		end
	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_level1_header(user.name)}
		it { should have_title(user.name) }
	end

	describe "signup page" do
		before { visit signup_path }

		it { should have_level1_header('Sign up') }
		it { should have_title(full_title('Sign up')) }
	end

	describe "signup" do
		before { visit signup_path }

		let(:submit) { "Create my account" }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end

			describe "after submission" do
				before { click_button submit }

				it { should have_title('Sign up') }
				it { should have_error_message('error') }
			end
		end

		describe "with valid information" do
			it "should create a user" do
				expect { valid_signup }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before { valid_signup }
				let(:user) { User.find_by_email('user@example.com') }

				it { should have_title(user.name) }
				it { should have_success_message('Welcome') }
				it { should have_link('Sign out') }
			end
		end
	end

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do 
			visit signin_path
			valid_signin(user)
			visit edit_user_path(user)
		end

		describe "page" do
			it { should have_level1_header("Update your profile") }
			it { should have_title("Edit user") }
			it { should have_link('Change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button "Save changes" }

			it { should have_content('error') }
		end

		describe "with valid information" do
			let(:new_name)	{ "New Name" }
			let(:new_email)	{ "new@example.com" }
			before do
				valid_user_fill_in({name: new_name, email: new_email})
				click_button "Save changes"
			end

			it { should have_title(new_name) }
			it { should have_success_message('Profile updated') }
			it { should have_link('Sign out', href: signout_path) }
			specify { user.reload.name.should == new_name }
			specify { user.reload.email.should == new_email }
		end
	end

	describe "destroy" do
		before(:all) { 10.times { FactoryGirl.create(:admin) } }
		after(:all) { User.delete_all }

		let(:admin) { FactoryGirl.create(:admin) }

		before do
			visit signin_path
			valid_signin(admin)
			visit users_path
		end

		describe "an admin should not be able to delete another admin" do
			before do
				click_link 'delete'
			end

			it { should have_error_message("You can't delete other admin users.") }
		end
	end

end
