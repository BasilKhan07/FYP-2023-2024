import pytesseract
from pdf2image import convert_from_path

def extract_urdu_text_from_scanned_pdf(pdf_file_path):
    text = ""
    
    # Specify the path to the Poppler binaries explicitly
    poppler_path = r'D:\poppler-23.08.0\Library\bin'  # Replace with the actual path

    pages = convert_from_path(pdf_file_path, poppler_path=poppler_path)

    for page_num, page_image in enumerate(pages, start=1):
        # Perform OCR on each page's image
        page_text = pytesseract.image_to_string(page_image, lang="urd")

        # Append the extracted text to the result
        text += f"Page {page_num}:\n{page_text}\n\n"

    return text

# Replace 'your_scanned_pdf.pdf' with the path to your scanned PDF file containing Urdu text
pdf_file_path = './price list/1696301355.pdf'

urdu_text = extract_urdu_text_from_scanned_pdf(pdf_file_path)
with open('extracted_urdu_text.txt', 'w', encoding='utf-8') as file:
    file.write(urdu_text)