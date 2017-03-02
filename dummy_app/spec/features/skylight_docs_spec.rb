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
      expect(page).to have_current_path('/support/bork')
      expect(page).to have_content("\"Bork\" has been moved.")
      expect(page.status_code).to eq(404)
    end
  end
end
