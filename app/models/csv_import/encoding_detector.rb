# frozen_string_literal: true

# =============================================================================
# CSVImport::EncodingDetector
# =============================================================================
#
# Automatically detects the encoding of a CSV file among the four most common
# encodings found in spreadsheet exports:
#
#   - UTF-8        (with or without BOM EF BB BF)
#   - UTF-16LE     (with or without BOM FF FE — typical of Windows Excel exports)
#   - Windows-1252 (CP1252, default encoding of Excel on Windows)
#   - macRoman     (Mac OS Roman, default encoding of Excel/Numbers on Mac)
class CSVImport::EncodingDetector
  # BOM (Byte Order Mark) — file start markers
  UTF8_BOM = "\xEF\xBB\xBF".b.freeze # EF BB BF
  UTF16LE_BOM = "\xFF\xFE".b.freeze # FF FE

  # Maximum number of bytes sampled for Latin encoding disambiguation.
  LATIN_SAMPLE_SIZE = 65_536 # 64 KB

  # Bytes that are **undefined** in Windows-1252 but valid in macRoman.
  # If these bytes appear in the file, it is a strong signal for macRoman
  # since no correct software should produce these bytes in CP1252.
  #
  #   0x81 → Å  in macRoman  |  *reserved* in CP1252
  #   0x8D → ç  in macRoman  |  *reserved* in CP1252
  #   0x8F → è  in macRoman  |  *reserved* in CP1252
  #   0x90 → ê  in macRoman  |  *reserved* in CP1252
  #   0x9D → û  in macRoman  |  *reserved* in CP1252
  CP1252_UNDEFINED_BYTES = [0x81, 0x8D, 0x8F, 0x90, 0x9D].freeze

  # Bytes characteristic of Windows-1252 in the 0x80-0x9F range.
  # Frequently produced by Word/Excel on Windows:
  #   0x80 = €  (euro sign)
  #   0x85 = …  (ellipsis)
  #   0x91 = '  (left single typographic quote)
  #   0x92 = '  (right single typographic quote)
  #   0x93 = "  (left double typographic quote)
  #   0x94 = "  (right double typographic quote)
  #   0x95 = •  (bullet)
  #   0x96 = –  (en dash)
  #   0x97 = —  (em dash)
  #   0x99 = ™  (trade mark)
  CP1252_SIGNATURE_BYTES = [0x80, 0x85, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x99].freeze

  # Result returned when detection is impossible (empty file, etc.)
  UNKNOWN_RESULT = { encoding: "unknown", confidence: 0.0, has_bom: false }.freeze

  # Detects the encoding from a raw byte string (content already in memory).
  def self.detect_from_string(raw)
    new.send(:detect_from_bytes, raw.b)
  end

  # Strips the BOM bytes from the beginning of a string, if present.
  # Works directly on the raw BOM byte sequences (UTF-8: EF BB BF, UTF-16LE: FF FE).
  def self.strip_bom(str)
    raw = str.b
    if raw.start_with?(UTF8_BOM)
      str.byteslice(UTF8_BOM.bytesize..)
    elsif raw.start_with?(UTF16LE_BOM)
      str.byteslice(UTF16LE_BOM.bytesize..)
    else
      str
    end
  end

  private

  # Internal detection entry point, works on raw bytes.
  def detect_from_bytes(raw)
    return UNKNOWN_RESULT.dup if raw.blank?

    raw = raw.b # force Ruby encoding to BINARY / ASCII-8BIT

    # --- Step 1: BOM detection ------------------------------------------------
    # BOM is the most reliable method: absolute confidence (1.0).
    bom_result = detect_by_bom(raw)
    return bom_result if bom_result

    # --- Step 2: Pure ASCII content -------------------------------------------
    # If all bytes are in the 0x00-0x7F range, the file is pure ASCII,
    # which is a strict subset of UTF-8 (and all other supported encodings).
    return { encoding: "UTF-8", confidence: 1.0, has_bom: false } if pure_ascii?(raw)

    # --- Step 3: Strict UTF-8 validation --------------------------------------
    # Ruby can validate whether a byte sequence is a legal UTF-8 string.
    return { encoding: "UTF-8", confidence: 0.99, has_bom: false } if valid_utf8?(raw)

    # --- Step 4: UTF-16LE detection without BOM --------------------------------
    # In UTF-16LE, common ASCII characters occupy 2 bytes: [value, 0x00].
    # This creates a detectable statistical pattern: many zeros at odd byte positions.
    utf16le_result = detect_utf16le_without_bom(raw)
    return utf16le_result if utf16le_result

    # --- Step 5: macRoman vs Windows-1252 disambiguation ---------------------
    # At this point we know the file contains bytes >= 0x80 (non-ASCII)
    # and is neither UTF-8 nor UTF-16LE. We distinguish the two Latin encodings.
    disambiguate_latin_encodings(raw)
  end

  # ---------------------------------------------------------------------------
  # Step 1 — BOM detection
  # ---------------------------------------------------------------------------

  # Returns a result if a recognized BOM is found, nil otherwise.
  def detect_by_bom(raw)
    if raw.start_with?(UTF8_BOM)
      { encoding: "UTF-8", confidence: 1.0, has_bom: true }
    elsif raw.start_with?(UTF16LE_BOM)
      { encoding: "UTF-16LE", confidence: 1.0, has_bom: true }
    end
  end

  # ---------------------------------------------------------------------------
  # Steps 2 & 3 — UTF-8 tests
  # ---------------------------------------------------------------------------

  # Returns true if all bytes are in the ASCII range (0x00-0x7F).
  def pure_ascii?(raw)
    raw.bytes.none? { |b| b > 0x7F }
  end

  # Returns true if the byte sequence is a valid UTF-8 string.
  # Uses Ruby's built-in validator (fast and reliable).
  def valid_utf8?(raw)
    raw.dup.force_encoding(Encoding::UTF_8).valid_encoding?
  end

  # ---------------------------------------------------------------------------
  # Step 4 — UTF-16LE detection without BOM
  # ---------------------------------------------------------------------------

  # In UTF-16LE, each character is encoded on 2 bytes (little-endian).
  # For ordinary Latin text (ASCII + accented characters), the high byte is
  # often 0x00 (ASCII) or 0x00/0x01 (Latin Extended).
  # This translates to: at odd positions (index 1, 3, 5, …) there are many
  # zeros, while at even positions (index 0, 2, 4, …) there are the actual
  # non-null values.
  def detect_utf16le_without_bom(raw)
    sample = raw[0, [raw.bytesize, 2048].min]
    total_pairs = sample.bytesize / 2
    return nil if total_pairs < 10

    odd_null_ratio, even_nonzero_ratio = utf16le_ratios(sample, total_pairs)

    # Empirical thresholds: >40% nulls at odd positions AND
    # >40% non-nulls at even positions → very characteristic of UTF-16LE
    return unless odd_null_ratio > 0.40 && even_nonzero_ratio > 0.40

    { encoding: "UTF-16LE", confidence: 0.85, has_bom: false }
  end

  def utf16le_ratios(sample, total_pairs)
    odd_nulls = 0
    even_nonzero = 0

    sample.bytes.each_with_index do |b, i|
      if i.odd?
        odd_nulls += 1 if b == 0x00
      elsif b != 0x00
        even_nonzero += 1
      end
    end

    [odd_nulls.to_f / total_pairs, even_nonzero.to_f / total_pairs]
  end

  # ---------------------------------------------------------------------------
  # Step 5 — macRoman vs Windows-1252 disambiguation
  # ---------------------------------------------------------------------------

  # macRoman and Windows-1252 share the ASCII range (0x00-0x7F) and have
  # identical values for many accented characters in 0xA0-0xFF.
  # The key distinction lies in the 0x80-0x9F range:
  #
  #   - Some bytes are undefined/reserved in CP1252 but have valid characters
  #     in macRoman → presence = strong macRoman signal.
  #   - Some CP1252 bytes correspond to Windows typographic characters
  #     (smart quotes, dashes, € sign) → CP1252 signal.
  #
  # A single pass on a sample avoids allocating an intermediate array.
  def disambiguate_latin_encodings(raw)
    sample = raw[0, [raw.bytesize, LATIN_SAMPLE_SIZE].min]
    macroman_score = 0
    cp1252_score = 0
    high_byte_count = 0

    sample.each_byte do |b|
      next if b < 0x80

      high_byte_count += 1
      if CP1252_UNDEFINED_BYTES.include?(b)
        # These bytes CANNOT appear in a real Windows-1252 file;
        # their presence is a very strong signal for macRoman.
        macroman_score += 3
      elsif CP1252_SIGNATURE_BYTES.include?(b)
        # These bytes are typical of documents produced by Windows software
        # (Word, Excel) in CP1252.
        cp1252_score += 2
      elsif b.between?(0x80, 0x9F)
        # Other bytes in the 0x80-0x9F range: slightly more common in CP1252
        # (far more widespread than macRoman in modern CSV files).
        cp1252_score += 1
      end
      # Bytes 0xA0-0xFF are identical in both encodings and ISO-8859-1,
      # they cannot help distinguish them.
    end

    return { encoding: "UTF-8", confidence: 1.0, has_bom: false } if high_byte_count.zero?

    if macroman_score > cp1252_score
      { encoding: "macRoman", confidence: 0.75, has_bom: false }
    elsif cp1252_score > 0
      { encoding: "Windows-1252", confidence: 0.70, has_bom: false }
    else
      # No distinctive signal: default to Windows-1252
      # (far more widespread than macRoman for current CSV files)
      { encoding: "Windows-1252", confidence: 0.50, has_bom: false }
    end
  end
end
