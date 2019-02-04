# frozen_string_literal: true

require 'rails_helper'
require 'active_fedora/cleaner'

RSpec.describe SimpleImporter do
  let(:one_line_example)       { 'spec/fixtures/csv_files/one_line_example.csv' }
  let(:three_line_example)     { 'spec/fixtures/csv_files/three_line_example.csv' }

  before do
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

  it "imports a csv" do
    expect { SimpleImporter.new(three_line_example).import }.to change { Image.count }.by 3
  end

  it "puts the title into the title field" do
    SimpleImporter.new(one_line_example).import
    expect(Image.where(title: 'A Cute Dog').count).to eq 1
  end

  it "puts the url into the source field" do
    SimpleImporter.new(one_line_example).import
    expect(Image.where(source: 'https://www.pexels.com/photo/animal-blur-canine-close-up-551628/').count).to eq 1
  end

  it "creates publicly visible objects" do
    SimpleImporter.new(one_line_example).import
    imported_Image = Image.first
    expect(imported_Image.visibility).to eq 'open'
  end

  it "attaches files" do
    allow(AttachFilesToWorkJob).to receive(:perform_later)
    SimpleImporter.new(one_line_example).import
    expect(AttachFilesToWorkJob).to have_received(:perform_later).exactly(1).times
  end
end
