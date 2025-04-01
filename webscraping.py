import requests
from bs4 import BeautifulSoup
from zipfile import ZipFile
import os

url = "https://www.gov.br/ans/pt-br/acesso-a-informacao/participacao-da-sociedade/atualizacao-do-rol-de-procedimentos"

response = requests.get(url)

def get_pdf_links(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    pdf_links = []
    for a_tag in soup.find_all('a', href=True):
        if '.pdf' in a_tag['href'] and ('Anexo I' in a_tag.text or 'Anexo II' in a_tag.text):
            pdf_links.append(a_tag['href'])
    
    return pdf_links

def download_pdfs(pdf_links, download_folder):
    os.makedirs(download_folder, exist_ok=True)
    for i, link in enumerate(pdf_links, start=1):
        pdf_url = link if link.startswith('http') else 'https://www.gov.br' + link
        pdf_name = os.path.join(download_folder, f'Anexo_{i}.pdf')
        
        response = requests.get(pdf_url)
        with open(pdf_name, 'wb') as f:
            f.write(response.content)
        print(f'{pdf_name} baixado com sucesso!')

def zip_pdfs(download_folder, zip_filename):
    with ZipFile(zip_filename, 'w') as zipf:
        for root, _, files in os.walk(download_folder):
            for file in files:
                zipf.write(os.path.join(root, file), os.path.basename(file))
    print(f'Arquivos compactados em {zip_filename}')

def main():
    pdf_links = get_pdf_links(url)
    
    if not pdf_links:
        print('Nenhum arquivo PDF encontrado.')
        return
    
    download_folder = 'downloads_pdfs'
    zip_filename = 'anexos.zip'
    
    download_pdfs(pdf_links, download_folder)
    zip_pdfs(download_folder, zip_filename)

if __name__ == "__main__":
    main()