# frozen_string_literal: true

require 'rails_helper'
require 'active_fedora/cleaner'

RSpec.describe ModularImporter, :clean do
  let(:modular_csv) { 'spec/fixtures/csv_files/modular_input.csv' }
  let(:user) { ::User.batch_user }

  before do
    ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
    DatabaseCleaner.clean
    ActiveFedora::Cleaner.clean!
  end

  it "imports a csv" do
    expect { ModularImporter.new(modular_csv).import }.to change { Image.count }.by 3
  end

  it "puts the title into the title field" do
    ModularImporter.new(modular_csv).import
    expect(Image.where(title: 'A Cute Dog').count).to eq 1
  end

  it "puts the url into the source field" do
    ModularImporter.new(modular_csv).import
    expect(Image.where(source: 'https://www.pexels.com/photo/animal-blur-canine-close-up-551628/').count).to eq 1
  end

  it "creates publicly visible objects" do
    ModularImporter.new(modular_csv).import
    imported_work = Image.first
    expect(imported_work.visibility).to eq 'open'
  end

  it "attaches files" do
    allow(AttachFilesToWorkJob).to receive(:perform_later)
    ModularImporter.new(modular_csv).import
    expect(AttachFilesToWorkJob).to have_received(:perform_later).exactly(3).times
  end
end