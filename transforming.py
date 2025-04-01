import os
import pdfplumber
import pandas as pd
from zipfile import ZipFile

def extract_table_from_pdf(pdf_path):
    table_data = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num in range(len(pdf.pages)):
            page = pdf.pages[page_num]
            table = page.extract_table()
            if table:
                for row in table:
                    table_data.append(row)

    return table_data

def save_to_csv(table_data, output_csv):
    print("Estrutura dos dados extraídos:")
    for line in table_data[:5]:
        print(line)
    
    if len(table_data) > 1:
        df = pd.DataFrame(table_data[1:], columns=table_data[0])
        print("Primeiras linhas do DataFrame:")
        print(df.head())
        df.to_csv(output_csv, index=False, encoding='utf-8')
        print(f"CSV salvo em {output_csv}")
    else:
        print("Não há dados suficientes para criar o CSV.")

def zip_csv(csv_filename, zip_filename):
    with ZipFile(zip_filename, 'w') as zipf:
        zipf.write(csv_filename, os.path.basename(csv_filename))
    print(f"Arquivo compactado em {zip_filename}")

def replace_abbreviations(input_csv, output_csv):
    df = pd.read_csv(input_csv)
    
    abbreviation_map = {
        "OD": "Odontologia",
        "AMB": "Ambulatório"
    }
    
    df.replace(abbreviation_map, inplace=True)
    
    df.to_csv(output_csv, index=False, encoding='utf-8')
    print(f"CSV com abreviações substituídas salvo em {output_csv}")

def main():
    pdf_path = "downloads_pdfs/Anexo_1.pdf"

    table_data = extract_table_from_pdf(pdf_path)
    
    if not table_data:
        print("Não foi possível extrair dados da tabela.")
        return
    
    output_csv = "rol_procedimentos.csv"
    save_to_csv(table_data, output_csv)
    
    updated_csv = "rol_procedimentos_atualizado.csv"
    replace_abbreviations(output_csv, updated_csv)
    
    zip_filename = "rol_procedimentos.zip"
    zip_csv(updated_csv, zip_filename)

if __name__ == "__main__":
    main()
