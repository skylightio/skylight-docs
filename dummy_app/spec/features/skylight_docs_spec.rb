require 'rails_helper'

describe "visiting support index page" do
  it "displays all of the chapters" do
    visit "/support"
    expect(page).to have_content("Markdown Styleguide")
    expect(page).to have_content("A Aardvark Chapter")
    expect(page).to have_content("Third Chapter")
  end
end

describe "visiting a chapter page" do
  it "displays the correct chapter page" do
    visit "/support"
    click_on "Markdown Styleguide"
    expect(page).to have_content("Content of the markdown styleguide")
    expect(page).to have_current_path('/support/markdown-styleguide')
  end

  context "when the chapter name is invalid" do
    it "redirects to the support index page" do
      visit "/support/bork"
      expect(page).to have_current_path('/support/')
      expect(page).to have_content("Our docs have just received a makeover! \"Bork\" has been moved.")
    end
  end
end
