require 'acceptance_helper'

feature 'User SignUp Test
  In order to be able to create a post
  As a guest
  I want to sign up' do

  scenario '#1 Link to SignUp must be exist on a root page.' do
    # To visit a page:
    visit root_path

    # To find an element inside some scope:
    within '.header' do
      # We expect that the Page Object has html element with certain css and text:
      assert page.has_css?('a', text: 'Sign Up')
      # or we can check only the text if exist:
      # assert page.has_content?('Sign Up')
    end
  end

  scenario '#2 After the link was clicked guest will be redirected to the registration form' do
    visit root_path

    within '.header' do
      click_on('Sign Up')
    end

    assert page.has_current_path?('/users/sign_up')
  end

  # Actually we don't need this test, because we could check it in the next one,
  # when we start to fill in the form.
  # But I'll leave it just as an example.
  scenario '#3 The Registration Form has fields:
    — Email
    — Password
    — Password Confirmation
    — Sign Up button' do

    visit '/users/sign_up'

    within '#new_user' do
      assert page.has_css?('input[name="user[email]"]')
      assert page.has_css?('input[name="user[password]"]')
      assert page.has_css?('input[name="user[password_confirmation]"]')
      assert page.has_css?('input[value="Sign up"]')
    end
  end

  scenario '#4 Guest is able to sign up with valid data:
    — correct email format
    — password must be long then 6 chars' do

    visit '/users/sign_up'

    sign_up_with(
      email: 'john.rambo@test.com',
      password: '12345678',
      password_confirmation: '12345678'
    )

    # There are many ways to check if user has been successfully registered. This is one of them:
    assert page.has_content?('Welcome! You have signed up successfully.')
    # We've just checked the 'flash' message. Also you can check if some html element was changed,
    # or if User is seeing their Email in the header, etc.
  end

  # The negative tests often are redundant, but in this case we keep it here as an example.
  # And let's split the AC by two independent scenarios for each requirement:
  scenario '#5 Guest is unable to sign up with invalid data:
    — Invalid email format' do

    visit '/users/sign_up'

    sign_up_with(
      email: 'invalid email'
    )

    assert page.has_content?('Email is invalid')
  end

  scenario '#5 Guest is unable to sign up with invalid data:
    — password and password confirmation are different' do

    visit '/users/sign_up'

    sign_up_with(
      password: '12345678',
      password_confirmation: 'password is not equal'
    )

    assert page.has_content?("Password confirmation doesn't match Password")
  end

  # We didn't discuss this AC in a grooming stage, let it be our initiative:
  scenario '#5 Guest is unable to sign up with invalid data:
    — password is shorter than 6 chars' do

    visit '/users/sign_up'

    sign_up_with(
      password: '12345',
      password_confirmation: '12345'
    )

    assert page.has_content?('Password is too short (minimum is 6 characters)')
  end

  # Actually this is a default behaviour of Devise gem. But this test is still needed, cause this is a part of
  # requirements (see the certain user story in PivotalTracker).
  scenario '#6 After success sign up registered user will be redirected to the Root Page' do
    visit '/users/sign_up'

    # Here we can use it with defaults
    sign_up_with

    assert page.has_current_path?('/')
  end

  # Let's refactor the tests. For example, we could extract a common form behavior to the method:
  def sign_up_with(**args)
    email = args.fetch(:email, 'john.rambo@test.com')
    password = args.fetch(:password, '12345678')
    password_confirmation = args.fetch(:password_confirmation, '12345678')

    within '#new_user' do
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password_confirmation
      click_on 'Sign up'
    end
  end
end
