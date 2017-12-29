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

    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    render json: { 'html' => white_list_sanitizer.sanitize(html).html_safe }
  end
end
