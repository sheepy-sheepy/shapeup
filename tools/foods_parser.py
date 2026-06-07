import requests
from bs4 import BeautifulSoup
import time
import re

class HealthDietParser:
    def __init__(self):
        self.base_url = "https://health-diet.ru"
        self.categories_url = "https://health-diet.ru/base_of_food/"
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        self.all_products = []
        self.seen_names = set()
        
    def get_categories(self):
        response = requests.get(self.categories_url, headers=self.headers)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        categories = []
        for link in soup.find_all('a', href=True):
            href = link.get('href', '')
            text = link.text.strip()
            if '/base_of_food/' in href and len(text) > 3:
                if 'kalorii' not in href and 'tablica' not in href:
                    categories.append({
                        'name': text,
                        'url': self.base_url + href if href.startswith('/') else href
                    })
        return categories
    
    def parse_category(self, category_url):
        try:
            response = requests.get(category_url, headers=self.headers, timeout=10)
            soup = BeautifulSoup(response.text, 'html.parser')
            
            table = soup.find('table', {'class': 'uk-table'})
            if not table:
                return []
            
            products = []
            for row in table.find_all('tr')[1:]:
                cols = row.find_all('td')
                if len(cols) >= 5:
                    name_cell = cols[0]
                    name_link = name_cell.find('a')
                    name = name_link.text.strip() if name_link else name_cell.text.strip()
                    
                    if not name:
                        continue
                    
                    if '[' in name or ']' in name:
                        continue
                    if "'" in name or '"' in name:
                        continue
                    if re.match(r'^[\d]+\.', name) or re.match(r'^[A-ZА-Я][a-zа-я]+', name):
                        bad_starts = ['Кусок', 'Порция', 'Ломтик', 'Глоток', 'Стакан', 'Чашка', 'Тарелка']
                        if any(name.startswith(bad) for bad in bad_starts):
                            continue
                    if re.search(r'[A-Z]{2,}', name):
                        continue
                    
                    brands = ['KFC', 'McDonald', 'Subway', 'Черкизово', 'Ростик', 'Campina', 'Danone', 
                             'Nestle', 'Mars', 'Lay\'s', 'Ашан', 'Бондюэль', 'Крошка', 'Макдоналдс', 
                             'Пятерочка', 'Роллтон', 'Яшкино', 'Coca-Cola']
                    if any(brand.lower() in name.lower() for brand in brands):
                        continue
                    
                    if re.match(r'^[\d]+\s*(г|кг|мл|л|шт|кус|порц)', name.lower()):
                        continue
                    
                    if name not in self.seen_names:
                        calories = self._parse_number(cols[1].text)
                        proteins = self._parse_number(cols[2].text)
                        fats = self._parse_number(cols[3].text)
                        carbs = self._parse_number(cols[4].text)
                        
                        if calories > 0 or proteins > 0 or fats > 0 or carbs > 0:
                            cleaned_name = self._clean_name(name)
                            
                            if len(cleaned_name) > 3 and not cleaned_name[0].isdigit():
                                products.append({
                                    'name': cleaned_name,
                                    'calories': calories,
                                    'proteins': proteins,
                                    'fats': fats,
                                    'carbs': carbs
                                })
                                self.seen_names.add(name)
            return products
        except:
            return []
    
    def _parse_number(self, text):
        try:
            text = text.strip().replace(',', '.').replace(' ', '')
            numbers = re.findall(r'(\d+\.?\d*)', text)
            return float(numbers[0]) if numbers else 0.0
        except:
            return 0.0
    
    def _clean_name(self, name):
        name = ' '.join(name.split())
        name = name.replace(' ', ' ').replace('​', '')
        name = re.sub(r'\(\d+\)', '', name)
        name = name.strip('"\'')
        name = re.sub(r'[*_\-=+]', '', name)
        return name.strip()
    
    def _format_csv_field(self, value, is_first_column=False):
        if is_first_column:
            if ',' in value or '"' in value:
                value = value.replace('"', '""')
                return f'"{value}"'
            return value
        else:
            return value
    
    def parse_all(self, filename='foods.csv'):
        categories = self.get_categories()
        print(f"Найдено {len(categories)} категорий")
        
        for i, cat in enumerate(categories, 1):
            print(f"Обработка {i}/{len(categories)} {cat['name'][:50]}")
            products = self.parse_category(cat['url'])
            self.all_products.extend(products)
            time.sleep(0.5)
        
        with open(filename, 'w', newline='', encoding='utf-8') as f:
            f.write('name,calories,proteins,fats,carbs\n')
            
            for p in self.all_products:
                name = p['name']
                if ',' in name:
                    name = f'"{name}"'
                
                f.write(f'{name},{p["calories"]},{p["proteins"]},{p["fats"]},{p["carbs"]}\n')
        
        print(f"\nСохранено {len(self.all_products)} продуктов в {filename}")

if __name__ == "__main__":
    parser = HealthDietParser()
    parser.parse_all('foods.csv')