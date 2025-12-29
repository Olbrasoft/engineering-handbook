## API Endpoints

### Text Translation

```
POST https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to={targetLang}
```

**Required Headers**:
```
Ocp-Apim-Subscription-Key: YOUR_API_KEY
Ocp-Apim-Subscription-Region: westeurope  (or your region)
Content-Type: application/json
```

**Request Body**:
```json
[
  {
    "Text": "Hello world"
  }
]
```

**Query Parameters**:
- `api-version` (required) - API version (use `3.0`)
- `to` (required) - Target language code (e.g., `cs`, `de`, `fr`)
- `from` (optional) - Source language (auto-detected if omitted)
- `textType` (optional) - `plain` or `html`

**Example Request**:
```bash
curl -X POST 'https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=cs' \
  -H 'Ocp-Apim-Subscription-Key: YOUR_API_KEY' \
  -H 'Ocp-Apim-Subscription-Region: westeurope' \
  -H 'Content-Type: application/json' \
  -d '[{"Text":"Hello world"}]'
```

**Example Response**:
```json
[
  {
    "detectedLanguage": {
      "language": "en",
      "score": 1.0
    },
    "translations": [
      {
        "text": "Ahoj světe",
        "to": "cs"
      }
    ]
  }
]
```

### Detect Language

```
POST https://api.cognitive.microsofttranslator.com/detect?api-version=3.0
```

**Request Body**:
```json
[
  {
    "Text": "Hello world"
  }
]
```

**Response**:
```json
[
  {
    "language": "en",
    "score": 1.0,
    "isTranslationSupported": true,
    "isTransliterationSupported": false
  }
]
```

### Get Supported Languages

```
GET https://api.cognitive.microsofttranslator.com/languages?api-version=3.0&scope=translation
```

**No API key required** for this endpoint.

---

