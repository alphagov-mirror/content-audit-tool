RSpec.feature "Export to CSV" do
  scenario "Export a csv file as an attachment" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_three_content_items
    when_i_export_an_audit_report
    then_i_receive_the_report_in_csv_format
  end

  scenario "Apply filters" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_three_content_items
    and_a_filter_is_applied_to_show_only_audited_hmrc_content_items
    when_i_export_the_reports
    then_i_receive_only_hmrc_related_content_items_in_the_report
  end

  scenario "Export multiple pages" do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_there_are_multiple_pages_of_content_items
    when_i_export_to_csv
    then_all_content_items_are_included_in_the_csv
  end

  def given_i_am_an_auditor_belonging_to_an_organisation
    @user = create(:user)
    @hmrc = create(:content_item,
                   title: "HMRC",
                   document_type: "organisation",
                   allocated_to: @user)
  end

  def then_i_receive_only_hmrc_related_content_items_in_the_report
    expect(@audit_report).to have_content("Title,URL")
    expect(@audit_report).to have_content("Assigned HMRC content,https://gov.uk/example1")
    expect(@audit_report).to have_no_content("Unassigned content 2,https://gov.uk/example2")
  end

  def when_i_export_an_audit_report
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load
    @audit_report.export_to_csv.click
  end

  def then_i_receive_the_report_in_csv_format
    content_type = page.response_headers.fetch("Content-Type")
    content_disposition = page.response_headers.fetch("Content-Disposition")

    expect(content_type).to eq("text/csv")
    expect(content_disposition).to start_with("attachment")
    expect(content_disposition).to include(
      'filename="Transformation_audit_report_CSV_download.csv"',
    )
    expect(@audit_report).to have_content("Title,URL")
    expect(@audit_report).to have_content("Assigned HMRC content,https://gov.uk/example1")
  end

  def and_a_filter_is_applied_to_show_only_audited_hmrc_content_items
    @audit_report = ContentAuditTool.new.audit_report_page
    @audit_report.load
    @audit_report.organisations.select 'HMRC'
    @audit_report.audit_status.choose 'Audited'
    @audit_report.apply_filters.click
  end

  def when_i_export_the_reports
    @audit_report.export_to_csv.click
  end

  def and_there_are_multiple_pages_of_content_items
    content_items_per_page = 101
    create_list(:content_item, content_items_per_page)
  end

  def when_i_export_to_csv
    visit report_path
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
    click_link "Export filtered audit to CSV"
  end

  def then_all_content_items_are_included_in_the_csv
    csv = CSV.parse(page.body)
    number_of_metadata_rows = 1
    expect(csv.count).to eq(Item.count + number_of_metadata_rows)
  end

  def and_there_are_three_content_items
    example1 = create(:content_item,
                      title: "Assigned HMRC content",
                      base_path: "/example1",
                      allocated_to: @user,
                      primary_publishing_organisation: @hmrc)
    create(:audit, content_item: example1)
    create(:content_item,
           title: "Unassigned content 2",
           base_path: "/example2")
    create(:content_item,
           title: "Unassigned content 3",
           base_path: "/example3",
           primary_publishing_organisation: @hmrc)
  end
end
