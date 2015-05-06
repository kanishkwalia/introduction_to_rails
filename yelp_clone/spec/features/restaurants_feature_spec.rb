require 'rails_helper'

feature 'restaurants' do

  before(:each) do
    visit 'users/sign_up'
    fill_in 'Email', with: 'name@name.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_button 'Sign up' 

  end

  def alt_sign_up
    visit 'users/sign_up'
    fill_in 'Email', with: 'bob@name.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_button 'Sign up' 
  end

  context 'no restaurants have been added' do
    scenario 'should display a prompt to add a restaurant' do
      visit '/restaurants'
      expect(page).to have_content 'No restaurants yet'
      expect(page).to have_link 'Add a restaurant'
    end
  end

  context 'restaurants have been added' do
    before do
      Restaurant.create(name: 'KFC')
    end

    scenario 'display restaurants' do
      visit '/restaurants'
      expect(page).to have_content('KFC')
      expect(page).not_to have_content('No restaurants yet')
    end
  end

  context 'creating restaurants' do
    scenario 'prompts user to fill out a form, then displays the new restaurant' do
      visit '/restaurants'
      click_link 'Add a restaurant'
      fill_in 'Name', with: 'KFC'
      click_button 'Create Restaurant'
      expect(page).to have_content 'KFC'
      expect(current_path).to eq '/restaurants'
    end

    context 'an invalid restaurant' do
      it 'does not let you submit a name that is too short' do
        visit '/restaurants'
        click_link 'Add a restaurant'
        fill_in 'Name', with: 'kf'
        click_button 'Create Restaurant'
        expect(page).not_to have_css 'h2', text: 'kf'
        expect(page).to have_content 'error'
      end
    end
  end

  context 'viewing restaurants' do

    let!(:kfc){Restaurant.create(name:'KFC')}

    scenario 'lets a user view a restaurant' do
     visit '/restaurants'
     click_link 'KFC'
     expect(page).to have_content 'KFC'
     expect(current_path).to eq "/restaurants/#{kfc.id}"
    end
  end

  context 'editing restaurants' do

    before(:each) do
      visit '/restaurants'
      click_link 'Add a restaurant'
      fill_in 'Name', with: 'KFC'
      click_button 'Create Restaurant'
    end

    scenario 'let a user edit a restaurant' do
      visit '/restaurants'
      click_link 'Edit KFC'
      fill_in 'Name', with: 'Kentucky Fried Chicken'
      click_button 'Update Restaurant'
      expect(page).to have_content 'Kentucky Fried Chicken'
      expect(current_path).to eq '/restaurants'
    end

    scenario 'cannot edit a restaurant if not signed in' do
      click_link 'Sign out'
      click_link 'Edit KFC'
      expect(page).to have_content 'You need to sign in or sign up before continuing'
    end

    scenario 'cannot edit a restaurant if did not create' do
      click_link 'Sign out'
      visit '/restaurants'
      alt_sign_up
      click_link 'Edit KFC'
      expect(page).to have_content 'Name'
    end
  end

  context 'deleting restaurants' do
    
    before(:each) do
      visit '/restaurants'
      click_link 'Add a restaurant'
      fill_in 'Name', with: 'KFC'
      click_button 'Create Restaurant'
    end

    scenario 'removes a restaurant when a user clicks a delete link' do
      visit '/restaurants'
      click_link 'Delete KFC'
      expect(page).not_to have_content 'KFC'
      expect(page).to have_content 'Restaurant deleted successfully'
    end

    scenario 'cannont remove a restaurant if not signed in' do
      click_link 'Sign out'
      click_link 'Delete KFC'
      expect(page).to have_content 'You need to sign in or sign up before continuing'
  end

  scenario 'prompts user to sign in when creating a restaurant whilst signed out' do
      click_link 'Sign out'
      visit '/restaurants'
      click_link 'Add a restaurant'
      expect(page).to have_content 'You need to sign in or sign up before continuing'
      expect(current_path).to eq '/users/sign_in'
    end

    scenario 'cannont remove a restaurant if did not create' do
      click_link 'Sign out'
      alt_sign_up
      click_link 'Delete KFC'
      expect(page).to have_content 'KFC'
    end
  end
end