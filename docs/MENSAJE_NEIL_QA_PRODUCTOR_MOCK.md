# Mensaje Neil — Unificación mock en QA productor

**Para:** Neil  
**Tema:** Probar Unificación con **datos mock** en productor QA  
**Fecha:** 2026-09-15

---

Hola Neil,

Necesitamos **probar Unificación con datos mock en QA productor** (laboratorio).  
Esto es **aparte** del cierre con datos reales en consumidor / Data Sharing.

### Ambiente
| Pieza | Valor |
|-------|--------|
| Cluster | **Productor QA** (procesosbatch) |
| DB | **`dba_batch`** |
| Schema | **`bdm_stage`** |
| Escenarios | `bdm_stage.perf_persona_meta` (`scenario_code`) |

### Prerrequisito (grants)
Usuario de pruebas necesita en `bdm_stage`:  
**SELECT + INSERT + UPDATE + DELETE** (+ **EXECUTE** de SPs mock).  
Sin eso aparece `permission denied` y no se puede cerrar TC-R2-14 ni R3 mock.

---

### 1) Regla 2 — hallazgo TC-R2-14 (`R2_EMPATE`)

Ejecutar en este orden:

1. Script patch:  
   `docs/sql_qa_redshift_mock/02_patch_r2_empate_limpiar_absorciones.sql`  
   (o `sql/qa_redshift/02_patch_r2_empate_limpiar_absorciones.sql`)

2. Confirmar / desplegar SP Esc4 con empate:  
   `stg_regla2_e04_ganador … HAVING COUNT(*) = 1`  
   (rama `feature/unificacion-edf-views` · `_pgm`)

3. Volver a correr R2 (CALL regla2 / batch mock que usen en productor)

4. Revalidar:  
   `04_revalidar_r2_empate_tras_sp.sql`  
   o `04_validacion_tc_r1_r2_bdm_stage.sql`

**Esperado TC-R2-14:** **0 violaciones**

---

### 2) Regla 3 mock (sí se debe poder probar)

1. Sembrar geo sintético:  
   `docs/sql_qa_redshift_mock/mock_tc_r3_01_08_10.sql`

2. `CALL` de regla 3 sobre tablas mock (`bdm_stage`)

3. Validar TC-R3 — **no** debe quedar BLOCKED por falta de lat/long

---

### Importante
- Esto es **solo mock** en **productor**.
- El cierre con **datos reales** es en **consumidor** `dba_rncr_batch` (Data Sharing) — otro flujo.
- **No mezclar** en la misma corrida: `bdm_stage` + `edf_views` / `v_xpm_*`.

Scripts en Bitbucket: repo `_dt` · rama `feature/unificacion-edf-views` · carpeta `docs/sql_qa_redshift_mock/`.

Cuando termines, comparte resultado de TC-R2-14 y estado R3 mock.

Gracias,  
Andrés
