# JSON Schema V1

Le backend supporte trois familles de réponse :
1. `bird_identified` (succès)
2. `image_unusable` (succès)
3. `ApiErrorResponse` (échec)

La validation est assurée côté code avec Pydantic.
