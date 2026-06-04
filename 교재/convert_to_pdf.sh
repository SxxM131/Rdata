#!/bin/bash
# HTML → PDF 변환 스크립트 (Chrome headless + pypdf 병합)

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
INPUT_DIR="/Users/sxxm/Documents/GitHub/Rdata/교재"
TMP_DIR="$INPUT_DIR/_tmp_pdfs"
OUTPUT="$INPUT_DIR/교재_전체.pdf"

echo "=== 임시 폴더 생성 ==="
mkdir -p "$TMP_DIR"

# HTML 파일을 정렬된 순서로 변환
HTML_FILES=(
  "Chap2_section1.html"
  "Chap2_section2_3.html"
  "Chap2_section4_5.html"
  "Chap2_section6_9.html"
  "Chap3_section1_3.html"
  "Chap3_section4_6.html"
  "Chap3_x11.html"
  "Chap4.html"
  "Chap5_section1_2.html"
  "Chap5_section3_4.html"
  "Chap5_section5_6.html"
  "Chap5_section7_8.html"
  "Chap5_section9_10.html"
  "5_6보충.html"
  "Chap6.html"
  "Chap7_section1.html"
  "Chap7_section2.html"
  "Chap7_section3.html"
  "Chap7_section4.html"
  "Chap7_section5.html"
  "Chap7_section6.html"
  "Chap7_section7.html"
  "Chap7_section8.html"
  "Chap7_section9.html"
  "Chap8_section1.html"
  "Chap8_section2.html"
  "Chap8_section3.html"
  "Chap8_section4.html"
  "Chap8_section5.html"
  "Chap8_section6_7.html"
  "Chap9_section1.html"
  "Chap9_section2_4.html"
  "Chap9_section5.html"
  "Chap9_section6.html"
  "Chap9_section7.html"
  "Chap9_section8.html"
  "Chap9_section9.html"
  "Chap9_section10.html"
  "Chap10_section1_2.html"
  "Chap10_section3_4.html"
  "Chap10_section5_6.html"
  "Chap11_section1.html"
  "Chap11_section2.html"
  "Chap11_section3.html"
  "Chap11_section4.html"
  "Chap11_section5.html"
  "Chap11_section6.html"
  "Chap12_section1.html"
  "Chap12_section2.html"
  "Chap12_section3.html"
)

echo "=== Chrome headless로 HTML → PDF 변환 시작 ==="
i=1
for html_file in "${HTML_FILES[@]}"; do
  input="$INPUT_DIR/$html_file"
  output_pdf="$TMP_DIR/$(printf '%03d' $i)_${html_file%.html}.pdf"
  
  if [ -f "$input" ]; then
    echo "[$i/50] 변환 중: $html_file"
    "$CHROME" --headless=new \
      --disable-gpu \
      --no-sandbox \
      --run-all-compositor-stages-before-draw \
      --print-to-pdf="$output_pdf" \
      --print-to-pdf-no-header \
      --no-pdf-header-footer \
      "file://$input" 2>/dev/null
    echo "  → 완료: $output_pdf"
  else
    echo "  ⚠ 파일 없음: $input"
  fi
  
  i=$((i + 1))
done

echo ""
echo "=== PDF 병합 (pypdf) ==="
python3 - <<'PYEOF'
import os
import glob

tmp_dir = "/Users/sxxm/Documents/GitHub/Rdata/교재/_tmp_pdfs"
output = "/Users/sxxm/Documents/GitHub/Rdata/교재/교재_전체.pdf"

try:
    from pypdf import PdfWriter
    print("pypdf 사용")
except ImportError:
    try:
        from PyPDF2 import PdfMerger as PdfWriter
        print("PyPDF2 사용")
    except ImportError:
        print("pypdf/PyPDF2가 없습니다. pip install pypdf 실행 필요")
        exit(1)

pdf_files = sorted(glob.glob(os.path.join(tmp_dir, "*.pdf")))
print(f"병합할 PDF 파일 수: {len(pdf_files)}")

writer = PdfWriter()
for pdf in pdf_files:
    print(f"  추가: {os.path.basename(pdf)}")
    writer.append(pdf)

with open(output, "wb") as f:
    writer.write(f)

print(f"\n✅ 완료! 출력 파일: {output}")
PYEOF

echo ""
echo "=== 임시 파일 정리 ==="
rm -rf "$TMP_DIR"
echo "완료!"
