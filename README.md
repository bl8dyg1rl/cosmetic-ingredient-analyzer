# 🧴 Cosmetic Ingredient Analyzer

Aplicación móvil para analizar los ingredientes de productos cosméticos a partir de una fotografía de su lista de ingredientes.

El proyecto combina **OCR en el dispositivo, procesamiento de texto, una API REST y una base de datos PostgreSQL** para identificar ingredientes cosméticos y mostrar información relevante sobre sus funciones, tipos de piel y precauciones.

> 🚧 **Estado:** MVP en desarrollo

---

## 📱 ¿Qué hace?

La aplicación permite al usuario:

1. 📷 Tomar una fotografía de la lista de ingredientes de un producto cosmético.
2. 🔎 Extraer el texto mediante OCR directamente en el dispositivo.
3. 🧹 Detectar y extraer la sección de ingredientes.
4. ✏️ Revisar y corregir los ingredientes detectados.
5. 🧪 Consultar los ingredientes contra una base de conocimiento.
6. 📊 Visualizar información sobre cada ingrediente.

El sistema está diseñado para posteriormente incorporar un **agente de IA capaz de investigar ingredientes que todavía no estén registrados en la base de datos y almacenar la información obtenida como conocimiento reutilizable**.

---
## Imagenes
![Inicio](/assets/inicio.jpeg)



---

## 🏗️ Arquitectura

```text
┌──────────────────────┐
│      Flutter App     │
│                      │
│  📷 Camera           │
│  🔎 OCR              │
│  ✏️ Ingredient Edit  │
└──────────┬───────────┘
           │
           │ HTTP / REST
           ▼
┌──────────────────────┐
│      FastAPI         │
│                      │
│ Ingredient Parser    │
│ Ingredient Matching  │
│ API Endpoints        │
└──────────┬───────────┘
           │
           │ SQLAlchemy
           ▼
┌──────────────────────┐
│     PostgreSQL       │
│                      │
│ Ingredients          │
│ Functions            │
│ Skin Types           │
│ Precautions          │
│ Aliases              │
│ Products             │
│ Sources              │
└──────────────────────┘
```

### Flujo de análisis

```text
Fotografía
    ↓
Google ML Kit OCR
    ↓
Detección de "Ingredients:" / "Ingredientes:" / "INCI:"
    ↓
Limpieza y separación de ingredientes
    ↓
Corrección manual por el usuario
    ↓
FastAPI
    ↓
Búsqueda en PostgreSQL
    ↓
Información del ingrediente
```

---

## 🛠️ Tecnologías

### Frontend

* **Flutter**
* **Dart**
* `image_picker`
* `google_mlkit_text_recognition`
* `http`

El OCR se ejecuta directamente en el dispositivo Android utilizando **Google ML Kit**, por lo que la imagen no necesita ser enviada al backend para realizar el reconocimiento.

### Backend

* **Python**
* **FastAPI**
* **SQLAlchemy**
* **Pydantic**
* **Alembic**
* **psycopg**

### Base de datos

* **PostgreSQL**
* **Docker**

### Herramientas

* Git
* GitHub
* Docker Compose

---

## 📂 Estructura del proyecto

```text
cosmetic-ingredient-analyzer/
│
├── backend/
│   ├── alembic/
│   │   └── versions/
│   │
│   ├── app/
│   │   ├── db/
│   │   │   ├── database.py
│   │   │   └── dependencies.py
│   │   │
│   │   ├── models/
│   │   │   ├── ingredient.py
│   │   │   ├── ingredient_function.py
│   │   │   ├── ingredient_skin_type.py
│   │   │   ├── ingredient_precaution.py
│   │   │   ├── ingredient_alias.py
│   │   │   ├── product.py
│   │   │   ├── product_ingredient.py
│   │   │   └── source.py
│   │   │
│   │   ├── routers/
│   │   │   └── ingredients.py
│   │   │
│   │   ├── schemas/
│   │   │   ├── ingredient.py
│   │   │   └── product_analysis.py
│   │   │
│   │   ├── services/
│   │   │   ├── import_ingredients.py
│   │   │   ├── import_relationships.py
│   │   │   ├── import_aliases.py
│   │   │   ├── ingredient_parser.py
│   │   │   └── ...
│   │   │
│   │   └── main.py
│   │
│   └── import_data.py
│
├── frontend/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── data/
│   ├── ingredients.csv
│   ├── ingredient_functions.csv
│   ├── ingredient_skin_types.csv
│   ├── ingredient_precautions.csv
│   └── ingredient_aliases.csv
│
├── database/
│
├── tools/
│
├── docker-compose.yaml
├── alembic.ini
├── requirements.txt
├── .gitignore
└── README.md
```

---

## 🗄️ Modelo de datos

La base de datos está diseñada para separar la información de los ingredientes y permitir que el sistema pueda crecer posteriormente.

### `ingredients`

Información principal del ingrediente.

```text
id
inci_name
common_name
description
category
evidence_level
notes
```

### `ingredient_functions`

Funciones cosméticas asociadas a cada ingrediente.

```text
id
ingredient_id
function
```

### `ingredient_skin_types`

Tipos de piel para los que un ingrediente puede resultar relevante.

```text
id
ingredient_id
skin_type
```

### `ingredient_precautions`

Precauciones o consideraciones asociadas al ingrediente.

```text
id
ingredient_id
precaution_type
description
```

### `ingredient_aliases`

Permite reconocer nombres alternativos.

Por ejemplo:

```text
Vitamin C → Ascorbic Acid
Vitamin E → Tocopherol
Coenzyme Q10 → Ubiquinone
Aqua → Water
```

### `products`

Información de los productos cosméticos analizados.

### `product_ingredients`

Relaciona productos con sus ingredientes y permite conservar la posición del ingrediente dentro de la lista.

### `sources`

Permite registrar las fuentes utilizadas para la información de cada ingrediente.

---

## 🔎 OCR y procesamiento de ingredientes

El OCR se realiza localmente mediante Google ML Kit.

Después del reconocimiento, el parser busca encabezados comunes como:

```text
Ingredients:
Ingredientes:
INCI:
```

y utiliza únicamente el contenido posterior como lista de ingredientes.

También soporta diferentes separadores:

```text
Water, Glycerin, Niacinamide
```

```text
Water • Glycerin • Niacinamide
```

```text
Water
Glycerin
Niacinamide
```

El usuario puede modificar manualmente el texto detectado antes de enviarlo al backend.

---

## 🚀 Instalación

### Requisitos

Antes de ejecutar el proyecto necesitas:

* Python 3.11+
* Flutter
* Dart
* Docker
* PostgreSQL mediante Docker
* Android Studio / Android SDK para ejecutar la aplicación Android

---

## 1. Clonar el repositorio

```bash
git clone https://github.com/<YOUR_USERNAME>/cosmetic-ingredient-analyzer.git
cd cosmetic-ingredient-analyzer
```

---

## 2. Crear el entorno Python

Windows:

```powershell
python -m venv .venv
```

Activar:

```powershell
.venv\Scripts\Activate.ps1
```

Instalar dependencias:

```powershell
pip install -r requirements.txt
```

---

## 3. Configurar las variables de entorno

Crear un archivo `.env` en la raíz:

```env
DATABASE_URL=postgresql+psycopg://cosmetic_user:cosmetic_password@localhost:5432/cosmetic_db
```

> ⚠️ El archivo `.env` no debe subirse al repositorio.

---

## 4. Iniciar PostgreSQL

Desde la raíz del proyecto:

```powershell
docker compose up -d
```

Comprobar los contenedores:

```powershell
docker compose ps
```

---

## 5. Ejecutar las migraciones

Desde la raíz:

```powershell
cd backend
alembic upgrade head
cd ..
```

---

## 6. Cargar los datos iniciales

```powershell
python backend/import_data.py
```

Esto carga los ingredientes y sus relaciones desde los archivos CSV.

---

## 7. Ejecutar FastAPI

Desde la raíz:

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 --app-dir backend
```

La API estará disponible localmente en:

```text
http://127.0.0.1:8000
```

La documentación interactiva de FastAPI estará disponible en:

```text
http://127.0.0.1:8000/docs
```

---

## 8. Ejecutar Flutter

Desde `frontend/`:

```powershell
cd frontend
flutter pub get
flutter run
```

Para ejecutar la aplicación en un dispositivo Android físico, el teléfono debe tener habilitada la depuración USB y poder comunicarse con el equipo que ejecuta FastAPI.

---

## 🔐 Seguridad

Este proyecto utiliza variables de entorno para información sensible.

No se deben subir al repositorio:

```text
.env
.venv/
```

ni credenciales, claves privadas o archivos de configuración que contengan secretos.

---

## 🧪 Estado actual

### Implementado

* [x] Aplicación Flutter
* [x] Captura de fotografías
* [x] OCR con Google ML Kit
* [x] Extracción de la sección de ingredientes
* [x] Soporte para diferentes separadores
* [x] Edición manual de ingredientes detectados
* [x] API REST con FastAPI
* [x] PostgreSQL
* [x] SQLAlchemy
* [x] Migraciones con Alembic
* [x] Base de conocimiento de ingredientes
* [x] Funciones cosméticas
* [x] Tipos de piel
* [x] Precauciones
* [x] Aliases de ingredientes
* [x] Análisis de ingredientes mediante API
* [x] Docker Compose
* [x] Importación de datos mediante CSV

### Próximamente

* [ ] Matching aproximado para errores de OCR
* [ ] Sistema de confianza de coincidencias
* [ ] Análisis global del producto
* [ ] Clasificación por funciones cosméticas
* [ ] Perfil del producto
* [ ] Historial de productos
* [ ] Comparación entre productos
* [ ] Buscador de ingredientes
* [ ] Sistema de fuentes y evidencia más completo
* [ ] Agente de IA para investigar ingredientes desconocidos
* [ ] Actualización automática de la base de conocimiento
* [ ] Búsqueda semántica con embeddings / pgvector

---

## 🤖 Futuro sistema de IA

Una de las principales extensiones previstas es incorporar un agente de IA para los ingredientes que todavía no estén presentes en la base de conocimiento.

El flujo esperado sería:

```text
                 ┌─────────────────┐
                 │ Ingredient OCR  │
                 └────────┬────────┘
                          ↓
                 ┌─────────────────┐
                 │    PostgreSQL   │
                 └────────┬────────┘
                          ↓
                  ¿Ingrediente existe?
                    ↙           ↘
                  Sí             No
                  ↓               ↓
             Respuesta      AI Research Agent
                                  ↓
                           Web Research
                                  ↓
                         Structured Information
                                  ↓
                             PostgreSQL
                                  ↓
                              Respuesta
```

De esta manera, la base de conocimiento puede crecer progresivamente y la información investigada puede reutilizarse en futuros análisis.

---

## 🎯 Objetivo del proyecto

El objetivo es desarrollar una herramienta capaz de transformar una fotografía de una lista de ingredientes cosméticos en información estructurada y comprensible para el usuario.

El proyecto también sirve como laboratorio para integrar diferentes tecnologías de desarrollo de software, procesamiento de datos, OCR, APIs, bases de datos e inteligencia artificial.

---

## 📌 Disclaimer

La información proporcionada por la aplicación tiene fines **informativos y educativos sobre ingredientes cosméticos**.

El análisis no constituye diagnóstico médico, recomendación dermatológica ni tratamiento de enfermedades de la piel.

---

## 👩‍💻 Autor

**Luceth Argote**

Matemáticas Aplicadas y Ciencias de la Computación

Intereses: **Inteligencia Artificial · Ciencia de Datos · Machine Learning · NLP · Computer Vision**

[LinkedIn](https://www.linkedin.com/in/luceth-argote-a73039239/)

[GitHub](https://github.com/bl8dyg1rl)
