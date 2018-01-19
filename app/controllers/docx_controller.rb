require 'nokogiri'

# rubocop:disable Rails/OutputSafety
class DocxController < ApplicationController
  def convert_to_html
    # Get the uploaded DOCX file
    uploaded_file = params[:docx]

    # Check if the file extension is valid
    unless uploaded_file.original_filename[-5, 5] == '.docx'
      render json: { 'error' => 'File type not supported', 'html' => '' }
      return
    end

    html = ''

    # Create a temporary directory for the input and output files
    Dir.mktmpdir do |dir|
      infile = File.join(dir, 'in.docx')
      outfile = File.join(dir, 'out.html')

      # Write the DOCX into the temporary directory
      File.open(infile, 'wb') { |fp| fp.write(uploaded_file.read) }

      # Run the conversion using mammoth
      bin = Rails.root.join('node_modules', 'mammoth', 'bin', 'mammoth')
      `#{bin} #{infile} #{outfile}`
      html = File.read(outfile)
    end

    html = process_html(html)
    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    render json: { 'html' => white_list_sanitizer.sanitize(html).html_safe }
  end

  def process_html(html)
    frag = Nokogiri::HTML::DocumentFragment.parse(html)
    # Get all the notes first
    notes = frag.css('ol.notes li.note').collect do |nel|
      [nel['id'], nel.children[0].children.to_html.strip]
    end
    notes = Hash[notes]
    # Remove the notes
    frag.css('ol.notes').remove
    # Insert the notes into the core HTML
    frag.css('span.note-reference').each do |refel|
      note_id = refel['data-note-id']
      note = notes[note_id]
      note_type = refel['data-note-type']
      refel.add_next_sibling("<span class=\"#{note_type}\">#{note}</span>")
    end
    # Remove the references
    frag.css('span.note-reference').remove
    frag.to_html
  end
end
