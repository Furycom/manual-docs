# CONTRADICTIONS — Plan Total MASTER_CLEAN
Date (UTC): 2026-01-20

## Cible
- Contradictions connues autour de: observed_snapshots / collecteurs / état réel vs legacy.

## Extraits (avec contexte)
### observed_snapshots
1496:public.observed_snapshots existe et est utilisée
1553:Phase C : pipeline observé (collecteurs → observed_snapshots)
1755:- La table **`public.observed_snapshots`** existe et est utilisée.
3224:                  observed_snapshots
3943:### 9.3.1 — Table observed_snapshots (à créer)
3988:4. Insertion dans Supabase (observed_snapshots)  
4113:2. Créer table observed_snapshots
4117:6. Ajouter observed_snapshots à Supabase
4133:| Supabase | Table observed_snapshots   | Élevée       |
4523:observed_snapshots
4752:## 12.1.4 — Table `observed_snapshots` (à créer dans Phase C)
4755:CREATE TABLE IF NOT EXISTS observed_snapshots (
5017:2. Créer observed_snapshots
5074:- La table `public.observed_snapshots` existe et est utilisée en production.
5103:- La table **`public.observed_snapshots`** existe déjà et est utilisée en production.  
5104:  Donc, toute section qui dit “Créer observed_snapshots” est désormais **fausse**.
5108:  - **TrueNAS** : collecteur maintenant en place via SSH + `midclt`, insertion dans `observed_snapshots` avec `source_id='truenas'`, et vue **`public.truenas_state_latest`**.
5113:- “Créer observed_snapshots”
6588:                  observed_snapshots
7307:### 9.3.1 — Table observed_snapshots (à créer)
7352:4. Insertion dans Supabase (observed_snapshots)  
7477:2. Créer table observed_snapshots
7481:6. Ajouter observed_snapshots à Supabase
7497:| Supabase | Table observed_snapshots   | Élevée       |
7887:observed_snapshots
8116:## 12.1.4 — Table `observed_snapshots` (à créer dans Phase C)
8119:CREATE TABLE IF NOT EXISTS observed_snapshots (
8381:2. Créer observed_snapshots

### Indices de contradiction (create vs exists / déjà fait vs à faire)
#### Lignes contenant “existe / utilisé / déjà”
1496:public.observed_snapshots existe et est utilisée
1755:- La table **`public.observed_snapshots`** existe et est utilisée.
5074:- La table `public.observed_snapshots` existe et est utilisée en production.
5103:- La table **`public.observed_snapshots`** existe déjà et est utilisée en production.  

#### Lignes contenant “créer / à créer / implémenter”
3943:### 9.3.1 — Table observed_snapshots (à créer)
4113:2. Créer table observed_snapshots
4752:## 12.1.4 — Table `observed_snapshots` (à créer dans Phase C)
5017:2. Créer observed_snapshots
5104:  Donc, toute section qui dit “Créer observed_snapshots” est désormais **fausse**.
5113:- “Créer observed_snapshots”
7307:### 9.3.1 — Table observed_snapshots (à créer)
7477:2. Créer table observed_snapshots
8116:## 12.1.4 — Table `observed_snapshots` (à créer dans Phase C)
8381:2. Créer observed_snapshots
