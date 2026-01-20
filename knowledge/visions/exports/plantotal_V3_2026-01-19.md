


---
BLOC 00 (ordre canon des sources de vérité corrigé)
BEGIN PLAN_TOTAL_V3 — BLOC 00 (PATCH PRIORITÉ CANON)
PLAN TOTAL — BRUCE — V3
Statut

Document : Plan Total (architecture + canon)

Version : V3

Principe : V3 décrit la structure et les règles du système BRUCE. Les tâches d’exécution et la progression restent dans la Checklist et le Handoff.

Règles de priorité (anti-contradictions) — CANON

En cas de divergence, l’ordre de vérité est :

Checklist (ce qui doit être exécuté / validé)

Handoff (ce qui est prévu pour la prochaine session)

État réel observé (ce qui tourne réellement, logs, faits mesurés)

Handbook / archives (références historiques, non-canoniques)

Toute phrase du Plan Total du type “référence absolue / remplace tous les autres fichiers / supprimer les autres documents” est considérée révoquée.

Si une divergence est détectée :

On enregistre un “Conflit” (Registre des conflits)

On tranche par règle de priorité

On conserve la traçabilité dans le Changelog d’intégration

MANIFEST DES BLOCS (contrôle d’intégrité V3)

BLOC 00 : Frontmatter + règles + manifest 

BLOC 01 : Vision et objectifs 

BLOC 02 : Architecture globale 

BLOC 03 : Pipeline d’ingestion canon 

BLOC 04 : Modèle d’artefacts Abrouse

BLOC 05 : Interfaces stables (MCP/Supabase) 

BLOC 06 : Orchestration et jobs idle 

BLOC 07 : Observabilité et traçabilité 

BLOC 08 : Runbook / pièges terrain 

BLOC 09 : Annexes (glossaire, conventions, changelog) 

BLOC 10 : Gouvernance attendu vs observé (NetBox → expected → observed → diff → events → actions)

BLOC 11 : Event schema v1 (classes + format canon JSON) 

Table des matières (mise à jour)

Vision et objectifs

Architecture globale

Pipeline d’ingestion canon

Artefacts Abrouse (modèle de données)

Interfaces stables (APIs, vues, conventions)

Orchestration (n8n, workers, budgets)

Observabilité (traces, logs, preuves)

Runbook (terrain)

Annexes (glossaire, conventions, changelog)

Gouvernance attendu vs observé (SRE loop)

Event schema v1

END PLAN_TOTAL_V3 — BLOC 00 (PATCH PRIORITÉ CANON)


---

### BEGIN PLAN_TOTAL_V3 — BLOC 01

## 1) Vision et objectifs (V3)

### 1.1 Mission

BRUCE est un système “local-first” qui vise à :

* Centraliser la connaissance (documents, logs, faits, décisions) sous forme **d’objets traçables**.
* Transformer en continu des données brutes en **artefacts utiles** (résumés, fiches, checklists, timelines, hypothèses, deltas de cohérence, packs de questions).
* Rester **contrôlable**, **auditable**, et **réparable** : rien d’essentiel ne doit dépendre d’un service tiers non maîtrisé.

### 1.2 Principes non négociables

1. **Local-first, cloud optionnel**

   * Le fonctionnement nominal doit être possible sans dépendre d’un service externe.
   * Les intégrations cloud (ex. Telegram) sont des “sorties” optionnelles, jamais la colonne vertébrale.

2. **Tout conserver en brut (source de vérité)**

   * Toute entrée (PDF, image, audio, export, JSON, logs) est archivée telle quelle (“raw”).
   * Les dérivés (texte extrait, chunks, embeddings, synthèses) sont des artefacts reconstruisibles.

3. **2 vitesses : conversation immédiate vs digestion “idle”**

   * “Immédiat” : répondre, chercher, naviguer, guider.
   * “Idle” : ingestion, extraction, indexation, consolidation, génération d’artefacts, vérifications.

4. **Aucune action autonome destructrice**

   * BRUCE ne supprime pas, ne modifie pas des systèmes, et ne “répare” pas seul.
   * Les actions concrètes passent par des workflows explicites (n8n/outils), avec approbation humaine quand requis.

5. **Preuves et traçabilité partout**

   * Tout artefact doit pouvoir pointer vers ses sources (documents, logs, snapshots) et indiquer ce qui est certain vs inféré.

6. **Le temps est une donnée de première classe**

   * Toute information importante doit être situable : date de production, période couverte, “avant/après”, et niveau de confiance temporel.

7. **Gestion explicite des divergences**

   * Quand 2 sources se contredisent : on enregistre un delta de cohérence (au lieu d’écraser) puis on traite via questions en attente.

### 1.3 Objectifs opérationnels

* **Unifier** l’ingestion multi-sources (dropzone SMB, exports, captures, logs, notes).
* **Indexer** de façon utile (texte, métadonnées, embeddings) sans perdre le brut.
* **Rendre consultable** : recherche, navigation, “packs de questions”, musée d’exhibits, glossaire vivant.
* **Mesurer et borner** : budgets de travail “idle”, états de jobs, traçage minimal robuste.
* **Standardiser l’intégration outils** : un point d’entrée unique côté assistant (MCP Gateway), et des outils changeables derrière.

### 1.4 Décisions V3 (verrouillées)

* **Archive canonique du brut lourd** : Supabase Storage (canon).
  TrueNAS sert de stockage/backup/infra, mais pas comme “source canon” du brut.
* **Ingestion fiable** : modèle “incoming → ready” (prioritaire), avec plan B “taille stable”.
* **Notifications** : ntfy comme canal principal (auto-hébergé) ; Telegram en option (miroir), jamais obligatoire.
* **Mémoire** : Supabase comme mémoire officielle (tables + embeddings + artefacts).
  Un moteur mémoire spécialisé reste une option future, non structurante.
* **Observabilité** : traçage minimal robuste d’abord (trace_id, statuts, liens preuves) ; outils dédiés ensuite si besoin réel.

### 1.5 Périmètre et séparation des documents (pour éviter les contradictions)

* **Plan Total V3 (ce document)** : architecture, conventions, objets, interfaces, règles, décisions durables.
* **Checklist** : ce qui doit être fait/validé (exécution).
* **Handoff** : ce qui est prévu pour la prochaine session (pilotage).
* **État observé** : la réalité (snapshots, logs, faits).
  En cas de divergence, appliquer l’ordre de priorité défini dans le BLOC 00.


### 1.6 Définitions rapides

* **Brut (raw)** : fichier original inchangé, archivé et référencé.
* **Artefact** : objet dérivé (résumé, timeline, exhibit, hypothèse, delta, etc.) avec liens vers preuves.
* **Job idle** : traitement asynchrone non urgent (ingestion, extraction, consolidation).
* **Questions en attente** : liste structurée des ambiguïtés/divergences à résoudre (avec priorités).

### END PLAN_TOTAL_V3 — BLOC 01

---

### BEGIN PLAN_TOTAL_V3 — BLOC 02

## 2) Architecture globale (V3)

### 2.1 Vue d’ensemble (couches)

BRUCE est structuré en 6 couches, avec des frontières nettes :

1. **Entrées (ingestion)**
   Dropzone SMB + collecteurs (snapshots, exports, notes, médias, logs).

2. **Socle de vérité (canon)**
   **Supabase Storage** pour le brut (raw) + **Postgres** pour les objets (métadonnées, artefacts, états, journaux).

3. **Traitements (jobs “idle” + opérations)**
   Extraction, OCR si nécessaire, chunking, embeddings, consolidation, génération d’artefacts, contrôles de cohérence.

4. **Orchestration / outils**
   n8n (workflows outillés) + workers (scripts/services) pour exécuter des tâches bornées et traçables.

5. **Interface “assistant”**
   OpenWebUI (ou autre UI) + LLM local (Ollama) pour l’interaction humaine, avec outils exposés via MCP.

6. **Observabilité & notifications**
   Traces minimales (trace_id, statuts, liens preuves) + alertes via ntfy (Telegram optionnel).

### 2.2 Composants principaux (rôle et responsabilités)

#### A) Supabase (canon)

* **Storage (canon raw)** : archive de tous les fichiers bruts (PDF, images, audio, exports, ZIP, etc.).
* **Postgres (canon objets)** : tables pour :

  * inventaire des fichiers (métadonnées, hash, provenance, catégorie, dates)
  * textes extraits + chunks
  * embeddings
  * artefacts (Exhibit, Hypothesis, CoherenceDelta, etc.)
  * états des jobs (queued/running/success/fail + raisons)
  * journaux d’événements (ingestion, anomalies, alertes envoyées)
* **Règle** : tout ce qui est “important” doit exister comme objet en base, pas seulement dans des logs.

#### B) MCP Gateway (point d’entrée unique “outils”)

* Expose des endpoints/outils “stables” pour l’assistant :

  * lecture/écriture contrôlée dans Supabase
  * déclenchement de jobs (via n8n/worker)
  * introspection (état, santé, dernier vu, derniers jobs)
* **Règle** : l’UI assistant ne parle pas directement à 10 services ; elle parle au MCP Gateway.

#### C) n8n (orchestration sûre, approbations)

* Héberge des workflows explicites :

  * ingestion (dropzone → archive → extraction → indexation)
  * enrichissement (artefacts)
  * notifications (ntfy + option Telegram)
  * demandes d’approbation (humain)
* **Règle** : toute action “réelle” (ex. lancer une tâche, déplacer des fichiers, écrire un artefact final) doit passer par workflow traçable.

#### D) Workers / services de traitement (jobs “idle”)

* Un ou plusieurs workers exécutent les tâches de fond :

  * watchers dropzone
  * extracteurs (texte/OCR)
  * chunkers + embeddings
  * consolidateurs (fusion, déduplication, familles vivantes)
  * générateurs d’artefacts (packs de questions, exhibits, rapports d’évolution)
* **Règle** : chaque exécution écrit un état en base + un `trace_id` commun du début à la fin.

#### E) UI & LLM local (interaction)

* **OpenWebUI** (ou équivalent) : interface utilisateur (chat, RAG, navigation).
* **Ollama** : moteur LLM local (modèle changeable).
* L’assistant utilise MCP pour agir (pas d’actions directes non contrôlées).

#### F) Dropzone SMB (porte d’entrée fichiers)

* Un partage SMB contient une structure simple :

  * `incoming/` : dépôts en cours
  * `ready/` : prêts à ingérer
  * catégories via sous-dossiers (dynamiques)
* L’aspirateur ne lit que `ready/` (ou plan B : taille stable).

#### G) Notifications (retour utilisateur)

* **ntfy** : canal standard (auto-hébergé).
* **Telegram** : miroir optionnel (non requis).

### 2.3 Flux de bout en bout (narratif)

1. Tu déposes un fichier dans la dropzone (incoming → ready).
2. Un job d’ingestion :

   * calcule un identifiant stable (hash/ID)
   * archive le brut dans Supabase Storage (canon)
   * écrit l’objet “file_record” en Postgres (métadonnées)
3. Un job “idle” d’extraction :

   * extrait le texte (et OCR si nécessaire)
   * segmente en chunks + ancres
   * calcule embeddings
4. Un job de consolidation :

   * déduit/associe à des “familles vivantes”
   * génère des artefacts (exhibit, pack de questions, timeline, etc.)
   * enregistre les divergences comme CoherenceDelta au lieu d’écraser
5. BRUCE notifie :

   * “ingéré + indexé”
   * “questions en attente” si ambiguïtés/conflits
6. En conversation, l’assistant :

   * recherche
   * cite des preuves (liens vers raw + chunks)
   * propose des actions via MCP → n8n/workers

### 2.4 Frontières et règles d’architecture (anti-dérive)

* **Canon brut** : Supabase Storage.
* **Canon objets** : Supabase Postgres.
* **Outils assistant** : uniquement via MCP Gateway.
* **Automatisation** : uniquement via n8n/workers (traçables).
* **Observabilité minimale** : `trace_id` + statuts jobs + liens preuves, systématiques.
* **Sécurité** : aucune action destructive autonome ; approbations si impact réel.
* **Extensibilité** : tout nouveau service doit s’intégrer via MCP (ou via n8n), pas en accès direct depuis l’UI.

### 2.5 Inventaire “ce qui est obligatoire vs optionnel”

**Obligatoire (V3)**

* Supabase (Postgres + Storage)
* MCP Gateway
* n8n
* Workers (ingestion/extraction/indexation/artefacts)
* ntfy
* Dropzone SMB

**Optionnel (accélérateurs)**

* Outils d’observabilité avancée (si besoin)
* Telegram (miroir)
* Évaluateurs qualité RAG (si besoin)
* Graph mémoire (si besoin)

### END PLAN_TOTAL_V3 — BLOC 02

---

### BEGIN PLAN_TOTAL_V3 — BLOC 03

## 3) Pipeline d’ingestion canon (dropzone → archive → extraction → indexation → artefacts)

### 3.1 Objectif du pipeline

Garantir qu’un fichier déposé (peu importe son type) devienne :

* un **raw canonique** archivé (inchangé) dans **Supabase Storage**
* un **objet référencé** en base (métadonnées + provenance)
* un **texte exploitable** (si applicable) + chunks + embeddings
* éventuellement des **artefacts** (packs de questions, exhibits, timelines, deltas, etc.)
* avec **états** + **trace_id** + **notifications**

### 3.2 Structure dropzone (SMB) et règles d’entrée

La dropzone SMB est la porte d’entrée unique pour les fichiers “humains” (PDF, images, scans, exports, ZIP, audio, etc.).

**Arborescence canon :**

* `incoming/` : dépôt en cours (jamais ingéré)
* `ready/` : dépôt terminé (ingérable)
* sous-dossiers libres sous `ready/` = **catégories dynamiques** (ex. `ready/Factures/`, `ready/Mecanique/`, `ready/Notes/`)

**Règle d’or :**

* L’aspirateur **ne lit que `ready/`**.

### 3.3 Anti-fichier-partiel (fiabilité d’ingestion)

**Mode principal (verrouillé V3)** : `incoming → ready`

* Un fichier n’est ingéré que lorsqu’il est déplacé dans `ready/`.

**Mode de secours** : “taille stable”

* Si `incoming→ready` n’est pas possible, un fichier dans `ready/` est considéré prêt uniquement si sa taille et sa date de modification restent stables sur une courte fenêtre.

### 3.4 Identité et déduplication (anti-collision)

Chaque fichier ingéré reçoit une **identité stable** qui sert à :

* éviter l’ingestion multiple du même contenu
* relier brut ↔ texte ↔ artefacts
* permettre la ré-ingestion/rebuild sans ambiguïté

**Règles :**

1. Calculer un **hash de contenu** (base de la déduplication).
2. Assigner un **file_id** stable (dérivé ou associé au hash).
3. Conserver le **nom original** et le **chemin dropzone** comme métadonnées (ne jamais les perdre).
4. Si collision de nom : le nom de stockage canonique change, **pas le file_id**.

### 3.5 Archivage canonique du brut (Supabase Storage)

**Décision V3** : le brut canonique est stocké dans **Supabase Storage**.

**Règles :**

* Le fichier brut est archivé **inchangé** (byte-identique).
* Le chemin de stockage canonique doit être **anti-collision** et **triable** (inclure date d’ingestion + file_id).
* Le fichier “disparaît” de la dropzone après ingestion (déplacé/archivé), afin d’éviter les doubles ingestions.
* TrueNAS peut recevoir une copie de sauvegarde (backup), mais ne remplace jamais le canon.

### 3.6 Enregistrement en base (métadonnées minimales obligatoires)

À l’ingestion, créer/mettre à jour un enregistrement canonique en Postgres (conceptuellement “file_record”), contenant au minimum :

* `file_id` (stable)
* `hash` (contenu)
* `original_filename`
* `original_dropzone_path`
* `category` (dérivée des sous-dossiers `ready/…`)
* `mime/type` (si détectable)
* `size_bytes`
* `ingested_at` (timestamp)
* `storage_bucket` + `storage_object_path` (lien vers le raw)
* `source` (dropzone, export, etc.)
* `trace_id` d’ingestion
* `status` (voir 3.8)

### 3.7 Extraction et indexation (pipeline “idle”)

Après archivage raw + file_record, déclencher des jobs “idle” selon le type :

1. **Extraction texte** (si applicable)

   * PDF texte : extraction directe
   * image/scan : OCR si nécessaire
   * audio : transcription si prévu (optionnel, non bloquant)

2. **Normalisation**

   * nettoyer le texte (sans altérer le raw)
   * conserver la version “texte brut extrait” pour audit

3. **Chunking + ancres**

   * découper en segments (chunks) avec identifiants stables
   * conserver la position/ancres (page/offset quand possible)

4. **Embeddings**

   * calculer embeddings sur chunks
   * stocker embeddings reliés à `file_id` + `chunk_id`

5. **Consolidation**

   * rattacher à des “familles vivantes” si applicable
   * détecter redondances / rapprochements
   * produire des “CoherenceDelta” si contradictions

6. **Génération d’artefacts**

   * SuggestedQuestionsPack (questions proposées)
   * Exhibit (curation)
   * Hypothesis / CausalChain / EvolutionReport, etc. (selon règles BLOC 04)

### 3.8 États, traçabilité, reprise (résilience)

Chaque étape écrit un **état** en base (conceptuellement “job_run”), incluant :

* `trace_id` (commun à la chaîne ou corrélé)
* `job_type` (ingest_raw, extract_text, chunk, embed, consolidate, generate_artifacts, notify)
* `input_refs` (file_id, chunk_ids)
* `status` : queued / running / success / failed / skipped
* `started_at`, `ended_at`
* `error_summary` (si failed)
* `output_refs` (storage path, text id, chunk ids, artifact ids)

**Règles de reprise :**

* Un job failed doit pouvoir être relancé **sans dupliquer** (idempotence).
* La déduplication par hash doit empêcher la ré-ingestion du même brut, sauf si explicitement demandé (mode “force reprocess”).
* Le brut n’est jamais supprimé automatiquement.

### 3.9 Points de contrôle (quality gates)

Avant de marquer un fichier “indexé” :

* Raw archivé et lisible (Storage OK)
* file_record présent (métadonnées OK)
* extraction texte : success ou skipped (si non applicable), mais jamais “silencieuse”
* chunks/embeddings : success ou skipped (selon type), avec explication
* au moins un signal utilisateur :

  * “indexé” (OK)
  * ou “questions en attente” (ambiguïtés/conflits)
  * ou “échec + raison claire”

### 3.10 Notifications (sortie utilisateur)

À minima :

* notification “ingestion réussie” (file_id + catégorie + statut indexation)
* notification “échec” (étape + raison courte + trace_id)
* notification “questions en attente” (si CoherenceDelta ou ambiguïtés)

Canal :

* ntfy (standard)
* Telegram (optionnel miroir)

### END PLAN_TOTAL_V3 — BLOC 03

---


### BEGIN PLAN_TOTAL_V3 — BLOC 04

## 4) Modèle d’artefacts Abrouse (objets canoniques)

### 4.1 Pourquoi des “artefacts”

BRUCE ne doit pas seulement “répondre en texte”. Il doit produire des **objets persistants**, traçables, versionnés, qui :

* pointent vers des **preuves** (raw + chunks)
* indiquent ce qui est **certain** vs **inféré**
* peuvent être **mis à jour** sans perdre l’historique
* alimentent la navigation, la recherche, et l’orchestration (jobs + notifications)

### 4.2 Contrat commun à tous les artefacts

Tout artefact, peu importe son type, respecte ce contrat minimal.

**Champs communs (obligatoires)**

* `artifact_id` : identifiant unique
* `artifact_type` : type (voir 4.3)
* `title` : titre court
* `summary` : résumé court
* `created_at` : timestamp
* `updated_at` : timestamp
* `status` : `draft` | `active` | `superseded` | `archived`
* `trace_id` : identifiant de traçage (corrélé aux jobs)
* `confidence` : `low` | `medium` | `high`
* `time_scope` : période visée (ex. date/intervalle) + précision (ex. “incertain” si doute)
* `source_refs` : références vers preuves (au minimum un lien)
* `tags` : liste de tags (contrôlée par conventions)
* `owner` : `bruce` ou `human` (qui a déclenché/validé)

**Références de preuves (`source_refs`)**
Chaque référence est un objet structuré :

* `ref_type` : `storage_raw` | `extracted_text` | `chunk` | `snapshot` | `event` | `external_link`
* `ref_id` : identifiant stable (ex. `file_id`, `chunk_id`, `snapshot_id`, etc.)
* `locator` : information de localisation si applicable (page, offset, horodatage)
* `note` : justification courte (“pourquoi cette preuve est utilisée”)

**Règles**

* Un artefact sans preuve n’est jamais `active` (reste `draft`).
* Les mises à jour **n’écrasent pas** : elles créent une nouvelle version logique (voir 4.4).

### 4.3 Catalogue des artefacts canoniques (V3)

#### A) Exhibit (musée / curation)

But : présenter un sujet avec **preuves organisées**, récit court, et points d’attention.

Champs spécifiques :

* `exhibit_kind` : `case` | `person` | `system` | `incident` | `topic`
* `claims` : liste de revendications structurées

  * chaque claim : `claim_text`, `confidence`, `source_refs`
* `timeline_refs` : liens vers events pertinents
* `open_questions` : questions restantes (peu nombreuses, bien formulées)

Création :

* par consolidation “idle” ou action humaine
* devient `active` quand au moins un claim est prouvé

#### B) CoherenceDelta (divergence enregistrée)

But : capturer une contradiction ou divergence entre sources sans écraser.

Champs spécifiques :

* `delta_kind` : `contradiction` | `ambiguity` | `drift` | `missing_data`
* `statement_a` : énoncé A + preuves
* `statement_b` : énoncé B + preuves
* `impact` : `low` | `medium` | `high`
* `resolution_status` : `open` | `needs_human` | `resolved`
* `resolution_note` : texte court (si résolu)
* `resolution_refs` : preuves de la résolution

Règle :

* un CoherenceDelta `open` doit alimenter les “questions en attente”.

#### C) Hypothesis (hypothèse explicite)

But : poser une hypothèse avec un niveau de confiance, et une trajectoire d’invalidation.

Champs spécifiques :

* `hypothesis_text`
* `supports` : preuves qui soutiennent
* `counter_evidence` : preuves contraires connues
* `test_plan` : comment réduire l’incertitude (actions non destructrices)
* `state` : `proposed` | `supported` | `weakened` | `rejected`

Règle :

* une hypothèse n’est jamais présentée comme un fait si `state != supported`.

#### D) CausalChain (cause → effet)

But : expliquer une chaîne de causalité (debug, incident, décision).

Champs spécifiques :

* `nodes` : liste ordonnée (cause/événement/effet), chaque nœud avec preuves
* `links` : liens entre nœuds avec type (`causes`, `enables`, `correlates_with`)
* `gap_notes` : où il manque des preuves (explicitement)

Règle :

* si un lien n’est pas prouvé, il doit être marqué comme `correlates_with` ou “incertain”.

#### E) SuggestedQuestionsPack (RAG inversé)

But : à partir d’un dépôt (documents, logs), proposer un ensemble de questions utiles.

Champs spécifiques :

* `pack_scope` : ce qui a été analysé (file_ids, catégories, période)
* `questions` : liste ordonnée

  * chaque question : `question_text`, `why_this_matters`, `source_refs`, `expected_artifacts` (types visés)
* `priority` : `low` | `medium` | `high`

Règle :

* doit être court, actionnable, et orienté “prochaine meilleure question”.

#### F) Promise (engagement suivi)

But : enregistrer une promesse “à faire plus tard” (par BRUCE ou par humain) et la suivre.

Champs spécifiques :

* `promise_text`
* `promiser` : `bruce` | `human`
* `due_hint` : date ou “dès que possible” (si inconnu)
* `dependency_refs` : éléments requis
* `followup_status` : `open` | `in_progress` | `done` | `blocked`
* `completion_refs` : preuves de complétion

Règle :

* toute promesse doit être reliée à un `trace_id` ou à une discussion/événement.

#### G) WorkBudget (budget de travail idle)

But : borner le travail asynchrone pour éviter la dérive.

Champs spécifiques :

* `budget_scope` : global / catégorie / pipeline / job_type
* `budget_limits` : limites (temps, nombre de jobs, volume)
* `window` : période d’application (ex. quotidien)
* `policy` : `pause` | `defer` | `notify` (quoi faire quand limite atteinte)

Règle :

* un job “idle” qui dépasse les limites doit se terminer proprement (`defer`) et notifier.

#### H) GlossaryEntry (glossaire vivant)

But : stabiliser le vocabulaire du homelab (services, conventions, noms).

Champs spécifiques :

* `term`
* `definition`
* `aliases`
* `examples` : courts
* `owner_systems` : systèmes concernés (Supabase, MCP, n8n, TrueNAS, etc.)

Règle :

* le glossaire est utilisé par les générateurs de résumés et la documentation.

#### I) EvolutionReport (archéologie d’un sujet)

But : rapport sur l’évolution d’un sujet (architecture, incident, décision) dans le temps.

Champs spécifiques :

* `subject_ref` : objet concerné (service, famille, exhibit, etc.)
* `changes` : liste datée de changements (avec preuves)
* `current_state` : état actuel (prouvé)
* `lessons_learned` : points concrets

Règle :

* doit distinguer “constaté” vs “supposé”.

#### J) Scenario (projection contrôlée)

But : simuler un futur proche, explicitement incertain, pour planifier.

Champs spécifiques :

* `scenario_text`
* `assumptions` : liste d’hypothèses
* `risks` : liste de risques
* `signals_to_watch` : ce qui invalide/valide le scénario
* `recommended_actions` : actions non destructrices + prérequis

Règle :

* un Scenario est toujours `confidence=low` ou `medium` (jamais présenté comme factuel).

### 4.4 Versionning et remplacement (sans perte)

Quand un artefact change :

* l’ancien passe à `status=superseded`
* le nouveau devient `status=active`
* on crée un lien :

  * `supersedes_id` (nouveau → ancien)
  * et/ou `superseded_by_id` (ancien → nouveau)

Règle :

* on ne “corrige” pas en silence ; on remplace proprement.

### 4.5 Familles vivantes (objet de regroupement canon)

BRUCE regroupe les éléments liés (documents, incidents, sujets) sous des “familles vivantes”.

Champs minimaux :

* `family_id`
* `family_name`
* `family_type` : `topic` | `system` | `person` | `project` | `incident`
* `member_refs` : file_ids, artifact_ids, snapshot_ids
* `merge_history` : historiques des fusions/splits
* `governance` : règles simples (qui peut fusionner/split, conditions)

Règle :

* une famille peut être fusionnée ou subdivisée, mais la trace doit rester (merge_history).

### 4.6 Questions en attente (liste structurée)

Les questions en attente sont une vue/objet alimenté par :

* CoherenceDelta `open`
* Hypothesis `proposed` avec test_plan non exécuté
* Scenarios nécessitant des signaux
* Manques de preuves (artefacts `draft` bloqués)

Champs minimaux :

* `question_id`
* `question_text`
* `reason` (delta/hypothesis/missing_data)
* `priority`
* `refs` (preuves)
* `next_action` (non destructrice)
* `status` : open / answered / deferred

### END PLAN_TOTAL_V3 — BLOC 04

---

### BEGIN PLAN_TOTAL_V3 — BLOC 05

## 5) Interfaces stables (MCP, conventions d’appel, introspection, formats “observed snapshots”)

### 5.1 Objectif

Stabiliser des **interfaces** et des **formats** qui ne changent pas au gré des implémentations, afin que :

* l’UI assistant (OpenWebUI) et les outils parlent toujours pareil
* les collecteurs/ingestors puissent évoluer sans casser le reste
* l’observabilité “fonctionnelle” (dernier vu, résumés Docker, etc.) soit consultable de manière uniforme

### 5.2 Conventions d’appel (standard BRUCE)

Pour tout appel d’outil via MCP / automation :

**Headers**

* `Authorization: Bearer <token>` (ou mécanisme équivalent)
* `Content-Type: application/json`

**Body**

* corps **JSON brut** (pas “form”, pas “url-encoded”)
* un objet JSON, même minimal : `{}`

**Règles**

* Un endpoint doit répondre avec un format stable (pas de texte libre).
* Les erreurs doivent être courtes, structurées, et inclure un identifiant de corrélation (`trace_id` ou `request_id`).


5.2.1 Contrat “façade OpenAI-compatible” (exigence canon)

Le MCP Gateway doit exposer une façade OpenAI-compatible, au minimum :

models

chat/completions

But : permettre à l’UI (OpenWebUI) et aux automations (n8n) d’être configurées une seule fois, tout en gardant la liberté de changer les briques derrière (LLM, mémoire, outils).




### 5.3 Endpoints MCP “stables” (introspection)

Ces endpoints existent pour que l’assistant (et toi) puissent répondre rapidement à :

* “qu’est-ce qui a été vu récemment”
* “où en est Docker sur chaque host”
* “est-ce que les snapshots arrivent”

**Endpoints d’introspection (canon V3)**

* `GET /bruce/introspect/last-seen`
  But : dernier “vu” par host (time + état global).
* `GET /bruce/introspect/observed/hosts`
  But : liste des hosts observés + dernières métriques utiles.
* `GET /bruce/introspect/observed/docker/latest`
  But : dernier snapshot Docker par host.
* `GET /bruce/introspect/observed/docker/summary`
  But : synthèse Docker multi-host (services/containers, anomalies, etc.).

**Règles**

* Ces endpoints doivent rester compatibles même si les tables/vues internes changent.
* Ils doivent retourner : `data` + `meta` (incluant `generated_at` et éventuellement `trace_id`).

### 5.4 Vues Supabase “stables” (introspection côté base)

Le côté Postgres peut exposer des vues stables pour :

* dashboards
* requêtes rapides
* vérification manuelle

**Vues canoniques (cibles V3)**

* `public.bruce_last_seen`
  But : dernier timestamp d’observation par host.
* `public.docker_latest_per_host`
  But : dernier snapshot Docker par host (données minimales utiles).
* `public.docker_summary`
  But : résumé “compréhensible” Docker (par host + agrégé).

**Règle**

* Les vues sont des “interfaces SQL” : on peut recalculer leur logique interne, mais leur **schéma de sortie** doit rester stable.

### 5.5 Format canon : observed snapshots (structure JSON)

Les collecteurs écrivent des “snapshots observés” avec une structure stable.

**Structure canon minimale**

```json
{
  "host_id": "furymcp",
  "captured_at": "2026-01-13T14:33:00Z",
  "collector": "docker",
  "payload": {
    "snapshot": {
      "docker_ps": []
    }
  }
}
```

**Règles**

* Le “contenu observé” est dans : `payload.snapshot.*`
* Pour Docker, la clé canon est : `payload.snapshot.docker_ps`
* Le système ne doit pas dépendre de clés alternatives (pas de “payload.containers” dans le canon V3).

### 5.6 Docker : `docker_ps` peut être “array” OU “object” (règle de normalisation)

Selon certains hosts/collecteurs, `payload.snapshot.docker_ps` peut être :

* un **array** de lignes (format préféré)
* ou un **object** (structure non uniforme)

**Règle canon V3**

* Le format “final” utilisé par les vues / résumés / contrôles doit être un **array**.

**Normalisation (principe)**

* Si `docker_ps` est déjà un array : utiliser tel quel.
* Si `docker_ps` est un object : le convertir en array de lignes.

  * chaque entrée devient une ligne, en conservant les champs importants.
  * si l’object contient des sous-objets par container, aplatir au minimum :

    * `name`, `image`, `status`, `created`, `ports` (si dispo), `labels` (si dispo)
* La normalisation doit être **idempotente** (la relancer ne doit pas changer le résultat).

**Exemple : docker_ps (array)**

```json
{
  "payload": {
    "snapshot": {
      "docker_ps": [
        { "name": "mcp-gateway", "image": "mcp-gateway:latest", "status": "running" },
        { "name": "n8n", "image": "n8n:latest", "status": "running" }
      ]
    }
  }
}
```

**Exemple : docker_ps (object) — après normalisation**

```json
{
  "payload": {
    "snapshot": {
      "docker_ps": [
        { "name": "mcp-gateway", "image": "mcp-gateway:latest", "status": "running" }
      ]
    }
  }
}
```

### 5.7 Contrat de réponse standard (API MCP)

Tout endpoint MCP qui renvoie des données doit suivre un contrat simple :

```json
{
  "ok": true,
  "meta": {
    "generated_at": "2026-01-13T14:33:10Z",
    "trace_id": "abc123"
  },
  "data": {}
}
```

En cas d’erreur :

```json
{
  "ok": false,
  "meta": {
    "generated_at": "2026-01-13T14:33:10Z",
    "trace_id": "abc123"
  },
  "error": {
    "code": "BAD_REQUEST",
    "message": "Description courte",
    "details": {}
  }
}
```

### 5.8 Règles de stabilité (compatibilité)

* On préfère ajouter des champs plutôt que d’en retirer.
* On n’introduit jamais un changement cassant sans “versioning” explicite (`v1`, `v2`) OU sans couche d’adaptation au MCP.
* Les formats et endpoints ci-dessus sont considérés “contrats”.

### END PLAN_TOTAL_V3 — BLOC 05

---

### BEGIN PLAN_TOTAL_V3 — BLOC 06

## 6) Orchestration et jobs “idle” (n8n, workers, budgets, approbations)

### 6.1 Objectif

Organiser l’exécution des tâches BRUCE pour qu’elles soient :

* **prévisibles** (workflow clair)
* **bornées** (WorkBudget)
* **traçables** (trace_id + états)
* **sûres** (approbations humaines sur actions à impact)
* **réparables** (replay / relance idempotente)

### 6.2 Séparation des rôles (n8n vs workers)

#### n8n = orchestrateur

* Déclenche des jobs
* Enchaîne des étapes
* Gère les branches “succès/échec”
* Gère les notifications
* Gère les demandes d’approbation

#### Workers = exécutants

* Effectuent les tâches lourdes ou techniques :

  * ingestion
  * extraction/OCR
  * chunking
  * embeddings
  * consolidation
  * génération d’artefacts
* Écrivent les états en base (job_run)
* Respectent WorkBudget
* Ne prennent pas de décisions destructrices

**Règle**

* n8n orchestre, les workers calculent.

### 6.3 Typologie des jobs

**Jobs événementiels**

* Déclenchés par un événement (fichier “ready”, snapshot reçu, action utilisateur)
* Priorité : moyenne à haute (selon événement)

**Jobs “idle” (de fond)**

* Déclenchés quand le système est disponible
* Priorité : basse à moyenne
* Exemples :

  * consolidation
  * génération d’artefacts
  * packs de questions
  * rapports d’évolution
  * nettoyage/normalisation non destructrice
  * contrôle de cohérence

**Jobs manuels**

* Déclenchés explicitement par toi (ex. “reprocess file_id”, “build exhibit”, “generate report”)

### 6.4 États de jobs (contrat minimal)

Chaque job écrit en base :

* `job_run_id`
* `trace_id`
* `job_type`
* `input_refs`
* `status` : queued / running / success / failed / deferred / skipped
* `started_at`, `ended_at`
* `error_summary` (si failed)
* `output_refs`

**Règle**

* Un job sans “status final” est un bug (pas de silence).

### 6.5 Trace_id : corrélation end-to-end

Chaque chaîne (ex. ingestion complète d’un fichier) possède un `trace_id` commun, utilisé par :

* n8n (workflow run)
* workers (job runs)
* artefacts produits
* notifications envoyées

**But**

* retrouver toute l’histoire d’un traitement en 1 recherche.

### 6.6 WorkBudget (anti-runaway)

Les jobs “idle” doivent respecter un budget global et des budgets ciblés.

**Budgets recommandés (conceptuels)**

* Budget global quotidien (temps total, nombre de jobs, volume de fichiers)
* Budget par catégorie (ex. “Mecanique” plus prioritaire que “Divers”)
* Budget par job_type (ex. embeddings limités)

**Politique quand budget atteint**

* `pause` : ne pas lancer de nouveaux jobs idle
* `defer` : mettre en attente (deferred) et re-tenter plus tard
* `notify` : notifier (ntfy) qu’un budget limite est atteint

**Décision V3**

* Politique par défaut : `defer + notify` (on ne bloque pas brutalement, on reporte et on t’informe)

### 6.7 Déclencheurs (triggers) standard

**Trigger dropzone**

* Surveillance de `ready/`
* À détection :

  * créer un event “file_ready”
  * lancer workflow n8n “ingest_file”

**Trigger snapshots**

* À réception d’un snapshot observé (docker, proxmox, truenas, etc.) :

  * écrire l’event
  * éventuellement lancer consolidation/alerts

**Trigger user**

* Commandes explicites via assistant :

  * “reprocess”
  * “generate exhibit”
  * “build questions pack”
  * “show pending questions”

### 6.8 Pattern “approbation humaine” (sécurité)

Certaines actions doivent être “proposées”, jamais exécutées sans validation.

**Exemples d’actions à approbation**

* changer une configuration système
* redémarrer un service
* appliquer une correction automatique
* supprimer/déplacer des données hors pipeline d’archive
* exécuter une commande sur une machine (si impact)

**Mécanique**

1. BRUCE produit une **proposition** (artefact ou message) :

   * quoi faire
   * pourquoi
   * risques
   * plan de rollback
2. n8n envoie une demande d’approbation (ntfy / UI)
3. toi tu acceptes/refuses
4. seulement si accepté : exécution via workflow dédié
5. enregistrement du résultat (job_run + preuves)

**Règle**

* Refus = enregistré, pas ignoré.

### 6.9 Idempotence et “replay”

Pour être fiable, chaque job doit être relançable sans dégâts.

**Règles**

* ingestion : déduplication par hash (pas de double raw)
* extraction/chunking/embeddings :

  * “upsert” par file_id/chunk_id
  * possibilité de “force rebuild” explicite
* génération d’artefacts :

  * nouvelle version (supersedes) au lieu d’écraser

### 6.10 Registre des événements (event log)

Tout ce qui “arrive” dans BRUCE doit être enregistré comme événement :

* `event_id`
* `event_type` : file_ready, file_ingested, job_failed, questions_pending, snapshot_received, approval_requested, approval_granted, approval_denied, etc.
* `occurred_at`
* `refs`
* `trace_id`

**But**

* permettre la timeline, l’audit, et les EvolutionReports.

### 6.11 Notifications orchestrées (sorties)

n8n est responsable de :

* notifier les succès/échecs importants
* notifier budgets atteints
* notifier “questions en attente”
* notifier demandes d’approbation

Canal :

* ntfy (standard)
* Telegram (optionnel miroir)

### END PLAN_TOTAL_V3 — BLOC 06

---

### BEGIN PLAN_TOTAL_V3 — BLOC 07

## 7) Observabilité et traçabilité (minimal robuste + options)

### 7.1 Objectif

Avoir une observabilité “qui aide réellement” sans complexifier inutilement :

* savoir ce qui fonctionne / ce qui est brisé
* comprendre pourquoi (raison courte + trace_id)
* retrouver rapidement les preuves (raw, chunks, snapshots)
* éviter les “échecs silencieux”

### 7.2 Principes (V3)

1. **Tout traitement a un trace_id**

   * Un traitement sans trace_id = traitement non-auditable.

2. **États persistés en base (pas seulement des logs)**

   * Les “job_run” et “events” sont la vérité d’observabilité.

3. **Erreurs courtes, actionnables**

   * Une erreur doit dire : “où”, “quoi”, “pourquoi probable”, “quoi faire ensuite”.

4. **Pas d’outil obligatoire externe**

   * Le minimal robuste doit fonctionner avec Supabase + logs + ntfy.

### 7.3 Cibles d’observabilité (ce qu’on doit pouvoir répondre en 10 secondes)

* Dernière observation de chaque host (last-seen)
* Dernier snapshot docker (par host)
* Dernier job ingestion/extraction/embeddings (statut)
* Liste des jobs failed (avec raisons)
* Liste des “questions en attente” (source : deltas/hypothèses)
* Budgets atteints (WorkBudget)
* État global “pipeline ingestion” (healthy / degraded / down)

### 7.4 Modèle minimal (données d’observabilité)

#### A) last_seen (host health simple)

Chaque host/collecteur met à jour :

* `host_id`
* `last_seen_at`
* `collector` (docker, proxmox, truenas, etc.)
* `status_hint` (ok/degraded/down)
* `note` (court)
* `trace_id` (si lié à un job)

#### B) job_run (exécution)

Déjà défini dans BLOC 06 : états, erreurs, outputs.

#### C) event_log (ce qui est arrivé)

Déjà défini dans BLOC 06 : événement + refs + trace.

#### D) issues/anomalies (option minimal)

Une anomalie est une entrée simple :

* `issue_id`
* `issue_type` (missing_snapshot, job_fail, budget_reached, coherence_delta_open, etc.)
* `severity` (low/medium/high)
* `first_seen_at`, `last_seen_at`
* `refs` (host/job/file)
* `status` (open/ack/resolved)
* `resolution_note` (si résolu)

**Règle**

* Une anomalie doit pouvoir être “acknowledged” (ack) sans être supprimée.

### 7.5 Logs structurés (principe)

Les workers doivent logguer en JSON (ou équivalent structuré) au minimum :

* `timestamp`
* `level`
* `service` (worker_name)
* `trace_id`
* `job_type`
* `message`
* `context` (file_id, host_id, chunk_id, etc.)

**Règle**

* Le log est un complément ; l’état persistant en base reste la source de vérité.

### 7.6 Health checks (santé)

**Systèmes à checker**

* Supabase (DB + Storage reachable)
* MCP Gateway (répond)
* n8n (répond)
* workers (heartbeat)
* ntfy (répond)

**Principe**

* Un health check écrit un event “health_check” + met à jour last_seen/status_hint.

### 7.7 Alerting (ntfy standard)

**Catégories d’alertes**

* HIGH : ingestion bloquée, Supabase down, MCP down, jobs critiques en boucle
* MEDIUM : jobs failed ponctuels, budget atteint, snapshots absents
* LOW : informational (ingestion OK, indexation OK)

**Format**

* message court
* lien vers trace_id / job_run / file_record
* action recommandée (une phrase)

Telegram peut recevoir un miroir, mais ntfy est l’officiel.

### 7.8 “Observabilité fonctionnelle” Docker (exemple de lecture utile)

Objectif : savoir si les conteneurs attendus tournent et détecter les écarts.

Données sources :

* snapshots observés `payload.snapshot.docker_ps` (normalisé array)

Sorties :

* `docker_latest_per_host` : dernier snapshot par host
* `docker_summary` : synthèse (nombre running, stopped, anomalies, conteneurs manquants)

**Règle**

* Les résumés ne doivent pas dépendre de formats non canoniques.

### 7.9 Options futures (non obligatoires)

Si le volume/complexité l’exige, on peut ajouter :

* traçage distribué plus riche
* tableaux de bord avancés
* outillage d’évaluation RAG
* graph mémoire

**Règle V3**

* Toute option future doit rester “plug-in” : le minimal robuste continue de fonctionner sans.

### END PLAN_TOTAL_V3 — BLOC 07

---

### BEGIN PLAN_TOTAL_V3 — BLOC 08

## 8) Runbook (terrain) — pièges fréquents et règles pratiques

### 8.1 Objectif

Cette section existe pour éviter de perdre du temps sur des détails “terrain” qui reviennent souvent.
Elle ne remplace pas la Checklist, mais fixe des règles pratiques stables.

### 8.2 Règles Supabase (DDL / SQL)

* Les opérations **DDL** (CREATE VIEW, ALTER TABLE, etc.) doivent être exécutées via un **canal SQL approprié** (psql/connexion DB), pas via un endpoint/outillage qui n’accepte que du SQL “non-DDL”.
* Si un outil tente d’afficher un résultat dans un pager et que le pager n’est pas disponible, forcer un mode sans pager (ou utiliser un outil/terminal qui ne dépend pas du pager).

### 8.3 Règles d’appel n8n → MCP (la cause numéro 1 des erreurs “bizarres”)

* Toujours envoyer :

  * Header `Authorization: Bearer …`
  * Header `Content-Type: application/json`
* Toujours envoyer un body **JSON brut** (RAW JSON).
* Ne pas utiliser de body “form” ou “urlencoded”.
* Si ça échoue : logguer `trace_id`, endpoint, et corps (sans secrets) dans l’event_log.

### 8.4 Conventions “Docker / snapshots observés”

* Le canon V3 pour Docker est : `payload.snapshot.docker_ps`
* Ne pas compter sur des clés alternatives (ex. `payload.containers`).
* `docker_ps` peut arriver sous des formes différentes : on **normalise** en array avant de résumer (voir BLOC 05).

### 8.5 Contrainte “répertoire de travail” (composition Docker)

* Les commandes/automatisations qui pilotent la stack Docker doivent être exécutées depuis le répertoire canon de la stack (afin d’éviter les erreurs de contexte).
* Toute doc interne qui mentionne des actions Docker doit préciser le “workdir” attendu.

### 8.6 Édition de code dans un conteneur (pratique sûre)

* Partir du principe que les conteneurs n’ont pas les outils de confort (éditeurs, utilitaires).
* Pattern standard :

  1. copier le fichier vers l’hôte
  2. éditer sur l’hôte
  3. recopier dans le conteneur
  4. redémarrer proprement le service concerné
* Toujours faire un backup horodaté avant remplacement.

### 8.7 Outils manquants (ne pas se battre contre ça)

* Certains utilitaires peuvent être absents selon les images (ex. éditeurs, outils de recherche).
* Règle : ne pas dépendre d’un outil “non garanti” dans les procédures canon ; préférer des méthodes basiques et présentes partout.

### 8.8 Diagnostic minimal en cas de panne (ordre conseillé)

1. Vérifier “last seen” (hosts/collecteurs).
2. Vérifier santé Supabase (DB + Storage).
3. Vérifier MCP Gateway (répond).
4. Vérifier n8n (répond).
5. Vérifier workers (heartbeat + derniers job_run).
6. Vérifier notifications ntfy (répond).
7. Ouvrir la liste des jobs failed et traiter par `trace_id`.

### 8.9 Règle anti-perte

* Aucun brut n’est supprimé automatiquement.
* Toute correction se fait par remplacement versionné (artefacts) ou par nouvelle exécution idempotente (jobs).

### END PLAN_TOTAL_V3 — BLOC 08

---


### BEGIN PLAN_TOTAL_V3 — BLOC 09

## 9) Annexes

### 9.1 Glossaire (vivant)

Ce glossaire sert à stabiliser le vocabulaire BRUCE. Les termes peuvent évoluer, mais doivent rester cohérents.

* **BRUCE** : système local-first de mémoire, ingestion, consolidation et assistance, basé sur Supabase + MCP + n8n + workers.
* **Canon** : ce qui est la référence officielle (raw canon + objets canoniques).
* **Raw (brut)** : fichier original inchangé, archivé en Storage, source de vérité.
* **Artefact** : objet dérivé traçable (Exhibit, Hypothesis, etc.), lié à des preuves.
* **Dropzone** : partage SMB d’entrée de fichiers (`incoming/`, `ready/`).
* **Worker** : exécutant de jobs (ingestion/extraction/chunking/embeddings/artefacts).
* **Job idle** : job de fond non urgent, exécuté sous WorkBudget.
* **WorkBudget** : limites de travail (temps/volume/jobs) + politique (defer/notify).
* **Questions en attente** : liste structurée d’ambiguïtés/contradictions à résoudre.
* **CoherenceDelta** : divergence enregistrée entre sources (sans écraser).
* **Trace_id** : identifiant de corrélation end-to-end (workflow → jobs → artefacts → notifications).
* **MCP Gateway** : point d’entrée unique des outils pour l’assistant.
* **n8n** : orchestrateur des workflows (sécurité + approbations).
* **ntfy** : canal de notifications auto-hébergé (standard V3).

### 9.2 Conventions (résumé)

* Tout ce qui est important doit exister en base (objets/états), pas seulement en texte.
* Tout traitement a un `trace_id`.
* Les actions à impact passent par workflow avec approbation humaine si nécessaire.
* Le brut n’est jamais supprimé automatiquement.
* Les artefacts se versionnent (supersedes), pas d’écrasement silencieux.

### 9.3 Changelog d’intégration (V2 → V3, sans erratum)

Cette section documente ce qui a été absorbé et où, pour garder la traçabilité.

#### A) Erratums du Plan Total V2

* Les erratums ont été **intégrés** directement dans V3 :

  * suppression du besoin d’“erratum” en V3
  * clarification “Plan Total = blueprint” et séparation Plan/Checklist/Handoff/État observé : voir BLOC 00 et BLOC 01
  * stabilisation du pivot MCP/LLM/outils : voir BLOC 02 et BLOC 05

#### B) “Infos sup V1”

* Points intégrés dans V3 :

  * format canon snapshots Docker (`payload.snapshot.docker_ps`) + normalisation : BLOC 05
  * conventions d’appel n8n→MCP (Authorization + RAW JSON) : BLOC 05 et BLOC 08
  * règle DDL Supabase (canal approprié) : BLOC 08
* Points conservés comme “terrain” (mais pas structurants) :

  * pratiques d’édition dans conteneur, outils manquants, répertoire de travail : BLOC 08 (résumé)

#### C) “Abrouse consolidation 2026-01-13”

* Principes “non négociables” : BLOC 01
* Pipeline d’ingestion (dropzone → storage → extraction → artefacts) : BLOC 03
* Artefacts Abrouse (catalogue + contrat commun) : BLOC 04
* Concept “familles vivantes” + “questions en attente” : BLOC 04
* Décisions V3 (Storage canon, ntfy, budgets, etc.) : BLOC 01, BLOC 03, BLOC 06

### 9.4 Complétude du document (contrôle)

Le document V3 est “complet” lorsque le MANIFEST (BLOC 00) marque tous les blocs PRÉSENTS :

* BLOC 00 à BLOC 09 = PRÉSENTS

9.5 État confirmé (2026-01-13)

Ces faits sont considérés “déjà en place” ; toute section qui parle de les “implémenter” doit être lue comme obsolète ou déjà satisfaite :

public.observed_snapshots existe et est utilisée

Collecteurs observed en place (au minimum : Docker, Proxmox, TrueNAS)

TrueNAS collecté via SSH (midclt) et exposé via une vue de type public.truenas_state_latest

Observabilité Docker “lifecycle-aware” (planned/active/retired ou équivalent) pour éviter les faux positifs

MCP Gateway canon : http://192.168.2.230:4000

Sur la VM 192.168.2.230, mcp-gateway et furymcp sont des alias/identités d’un seul nœud canonique (éviter les doublons)

Exemples déjà déployés au moins sur Box2 :

box2-edge : 192.168.2.87

box2-observability : 192.168.2.154

### END PLAN_TOTAL_V3 — BLOC 09

---

### BEGIN PLAN_TOTAL_V3 — BLOC 10

10) Gouvernance attendu vs observé (NetBox → expected → observed → diff → events → actions)
10.1 Objectif

BRUCE ne sert pas seulement à ingérer des documents : il sert aussi à piloter un homelab de façon “SRE” :

savoir ce qui doit exister (attendu)

savoir ce qui existe réellement (observé)

comparer automatiquement

générer des événements structurés

déclencher des actions via n8n (avec garde-fous)

10.2 Schéma canon (boucle de gouvernance)

NetBox : source déclarative (attendu)

expected_state : représentation exploitable de l’attendu

Supabase : stockage canon (observé + événements + journal)

Diff Engine : calcule les divergences

Event Engine : traduit divergences en événements canoniques

n8n : actions/réactions

10.3 Phases (modèle de maturité)

Phase A+B : pipeline attendu (NetBox → expected_state → ingestion Supabase)

Phase C : pipeline observé (collecteurs → observed_snapshots)

Phase D : divergence automatique (Diff Engine)

Phase E : événements + réactions (Event Engine → n8n)

10.4 Journaux (3 niveaux)

Pour audit long terme, BRUCE doit conserver :

Journaux pipeline attendu (A+B) : réception NetBox → transformation → transport → ingestion

Journaux “observed” (C) : Docker/Proxmox/TrueNAS + snapshots observés (JSON/JSONL)

Journaux divergence (D) : comparaisons + deltas + événements générés

10.5 Règle d’intégration avec les artefacts Abrouse

Les divergences “infrastructure” produisent des events (voir BLOC 11).

Les contradictions “connaissance/documents” produisent des CoherenceDelta (BLOC 04).

Les deux peuvent alimenter “questions en attente” :

events severité haute → action/diagnostic prioritaire

coherence deltas → clarification / preuves manquantes

10.6 Principes d’action (n8n)

Un event canon (BLOC 11) peut déclencher :

notification (ntfy)

création d’un ticket interne (issue)

demande d’approbation

exécution d’un workflow de remédiation (si approuvé / si safe)

END PLAN_TOTAL_V3 — BLOC 10
BLOC 11 — Event schema v1 (classes + JSON canon de V2)

À coller après BLOC 10.

BEGIN PLAN_TOTAL_V3 — BLOC 11
11) Event schema v1 (classes officielles + format canon)
11.1 But

Un event BRUCE doit être :

machine-lisible (n8n peut réagir)

compréhensible (diagnostic court)

traçable (source + created_at + refs + trace_id si disponible)

11.2 Classes d’événements (typologie officielle)

SERVICE_MISSING

SERVICE_UNEXPECTED

PORT_MISMATCH

VM_DOWN

VM_UNDECLARED

DOCKER_UNREACHABLE

NODE_UNREACHABLE

CONFIG_DRIFT

SNAPSHOT_ERROR

RESOURCE_EXCEEDED

11.3 Format JSON canon (event)
{
  "id": "uuid",
  "hostname": "box2-daily",
  "service": "freshrss",
  "event_type": "SERVICE_MISSING",
  "expected": { "port": 8021, "role": "rss" },
  "observed": null,
  "severity": "high",
  "details": "Expected service freshrss on box2-daily but container not running.",
  "source": "docker",
  "created_at": "2025-12-22T03:14:52Z"
}

11.4 Sémantique des champs (règles)

expected : extrait de la source déclarative (NetBox/expected_state)

observed : extrait du collecteur/snapshot

severity : utilisé par n8n pour décider des réactions

details : diagnostic court (humain/IA)

source : docker / proxmox / truenas / autre

created_at : timestamp de l’event (pas seulement “quand on l’a vu”)

11.5 Relation avec l’observabilité V3

Un event est un “fait opérationnel”.

Les vues / résumés peuvent s’appuyer sur les events, mais ne doivent pas remplacer le stockage des events.

END PLAN_TOTAL_V3 — BLOC 11




